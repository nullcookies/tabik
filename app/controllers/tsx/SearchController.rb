require 'pg'
require 'net/http'
require 'uri'

module TSX
  module Controllers
    module Search

      include TSX::Controllers::Plugin

      def start
        if @tsx_bot.tele == 'OptInfo'
          start_optset
        elsif @tsx_bot.tele == 'AutoHosting' or @tsx_bot.tele == 'Ahost1'
          start_hosting
        elsif @tsx_bot.tele == 'Roulette24'
          start_roulette
        else
          sdel('telebot_trading')
          sdel('telebot_buying')
          unfilter
          filename = @tsx_bot.avatar.nil? ? "http://pixelartmaker.com/art/ba207b21069c838.png" : @tsx_bot.avatar
          reply_logo filename, 'welcome/welcome', links: false, sh: hb_client.shop?, support_line: @tsx_bot.support_line
          an = Announce.find(bot: @tsx_bot.id)
          if !an.nil?
            reply_button an.text
          end
          serp
        end
        # play_game
      end

      def serp
        @tsx_bot.cities_first? ? serp_cities : serp_products
      end

      def serp_products
        sset('tsx_filter', Country[@tsx_bot.get_var('country')]) if !sget('tsx_filter')
        sset('tsx_filter_country', Country[@tsx_bot.get_var('country')])
        handle('add_filter')
        filt = sget('tsx_filter')
        city = sget('tsx_filter_city')
        items = Client::search_by_filters_product(filt, search_bots(@tsx_bot), city)
        if items.count == 0
          bts = [btn_main]
        else
          bts = buttons_by_filter
        end
        reply_simple "search/serp", list: items, buttons: bts, links: true
      end

      def serp_cities
        sset('tsx_filter', Country[@tsx_bot.get_var('country')])
        sset('tsx_filter_country', sget('tsx_filter'))
        handle('add_filter')
        filt = sget('tsx_filter')
        dist = sget('tsx_filter_district')
        items = Client::search_by_filters(filt, search_bots(@tsx_bot), dist)
        if items.count == 0
          bts = [btn_main]
        else
          bts = buttons_by_filter
        end
        reply_simple "search/serp", list: items, buttons: bts, links: true
      end

      def set_filters_back
        filter = sget('tsx_filter')
        if @tsx_bot.cities_first?
          if filter.instance_of?(Item)
            sset('tsx_filter', District)
          end
          if filter.instance_of?(District)
            sset('tsx_filter', Product)
          end
          if filter.instance_of?(Product)
            sset('tsx_filter', City[filter.city])
          end
        else
          if filter.instance_of?(Item)
            sset('tsx_filter', sget('tsx_filter_district'))
          end
          if filter.instance_of?(City)
            sset('tsx_filter', sget('tsx_filter_country'))
            sset('tsx_filter_country', Country[@tsx_bot.get_var('country')])
          end
          if filter.instance_of?(District)
            sset('tsx_filter', sget('tsx_filter_product'))
            sset('tsx_filter_product', sget('tsx_filter'))
          end
          if filter.instance_of?(Product)
            sset('tsx_filter', sget('tsx_filter_city'))
            sset('tsx_filter_product', sget('tsx_filter'))
          end
        end
      end

      def go_back
        set_filters_back
        serp
      end

      def buttons_by_filter
        filter = sget('tsx_filter')
        if filter.instance_of?(District)
          bts = [btn_back, btn_main]
        end
        if filter.instance_of?(Product)
          bts = [btn_back, btn_main]
        end
        if filter.instance_of?(City)
          bts = [btn_back, btn_main]
        end
        bts
      end


      def add_filter(data = nil)
        filter = sget('tsx_filter')
        if filter.instance_of?(Country)
          d = City.find(russian: data)
          sset('tsx_filter', City.find(russian: data)) if !d.nil?
          sset('tsx_filter_city', City.find(russian: data)) if !d.nil?
          serp
        end
        if filter.instance_of?(City)
          d = Product.find(russian: data)
          sset('tsx_filter', d) if !d.nil?
          sset('tsx_filter_product', d) if !d.nil?
          serp
        end
        if filter.instance_of?(Product)
          p = District.find(russian: data)
          if !p.nil?
            sset('tsx_filter', p)
            sset('tsx_filter_district', p)
            unhandle
            show_items
          else
            serp
          end
        end
      end

      def show_items
        items = Client::items_by_the_district(
            search_bots(@tsx_bot),
            sget('tsx_filter_product'),
            sget('tsx_filter_district')
        )
        handle('create_trade')
        reply_simple 'search/items_products', items: items, item_count: items.count, product: sget('tsx_filter_product'), district: sget('tsx_filter_district'), links: true
      end

      def create_trade(data)
        begin
          pending = hb_client.has_pending_trade?(@tsx_bot)
          puts pending.inspect
          if pending
            trade_item = Item[pending.item]
            trade_item.status = Item::ACTIVE
            trade_item.save
            pending.delete
            reply_message "#{icon(@tsx_bot.icon_info)} Предыдущий заказ отменен."
          end
          # matched = @payload.text.match(/(.*) за *.\d*.*/)
          # needed_price = Price.find(bot: @tsx_bot.id, qnt: matched.captures.first, product: sget('tsx_filter_product').id)
          # raise 'Wrong item id' if matched.nil?
          # puts "MATCH: #{matched.captures.first}"
          # district = sget('tsx_filter_district')
          # puts district
          # it = Item.where(:item__bot => @tsx_bot.id, status: Item::ACTIVE, prc: needed_price.id, created: (Date.today - @tsx_bot.discount_period.day) .. Date.today).order(Sequel.lit('RANDOM()')).first
          # puts "FOUND ITEM::::"
          # puts it.inspect.red
          if Trade.find(item: data).nil?
            it = Item[data]
            p = Price[it.prc]
            it.update(unlock: Time.now + RESERVE_INTERVAL.minute, status: Item::RESERVED)
            seller = @tsx_bot.beneficiary
            tr = Trade.create(
              buyer: hb_client.id,
              bot: @tsx_bot.id,
              seller: seller.id,
              item: it.id,
              status: Trade::PENDING,
              escrow: seller.escrow,
              amount: p.price,
              commission: (p.price.to_f * @tsx_bot.commission.to_f/100),
              random: rand(100000..900000).to_s
            )
            sset('buying_price', p)
            sbuy(it)
            strade(tr)
            botrec('Бронирование клада', it.id)
            trade_overview
          else
            reply_message "#{icon(@tsx_bot.icon_info)} Этот клад уже кто-то зарезервировал или купил. Выберите другой."
            it.update(unlock: nil)
          end
        rescue PG::InvalidTextRepresentation => resc
          puts resc.message
          puts resc.backtrace.join("\n\t").colorize(:red)
          reply_message "#{icon(@tsx_bot.icon_info)} Невозможно создать заказ. Попробуйте еще раз, пожалуйста."
          go_back
        rescue => ex
          reply_message "#{icon(@tsx_bot.icon_info)} Невозможно создать заказ. Попробуйте еще раз."
          puts ex.message
          puts ex.backtrace.join("\n\t").colorize(:red)
          go_back
        end
      end

      def pending_trade
        pending = hb_client.has_pending_trade?(@tsx_bot)
        if !pending
          reply_message "#{icon(@tsx_bot.icon_warning)} Заказ был отменен. Начните сначала."
          start
        else
          botrec('Выбран метод оплаты Easypay')
          sset('telebot_method', Country[@tsx_bot.get_var('country')].code == 'RU' ? 'qiwi' : 'easypay')
          strade(pending)
          sbuy(Item[pending.item])
          trade_overview
        end
      end

      def later
        start
      end

      def take_free
        not_permitted if !hb_client.is_admin?(@tsx_bot) and !hb_client.is_operator?(@tsx_bot)
        botrec('Администратор взял клад', _buy.id)
        just_take(_buy)
        _trade.delete
        _buy.delete
        start
      end

      def view_free
        not_permitted if !hb_client.is_admin?(@tsx_bot) and !hb_client.is_operator?(@tsx_bot)
        botrec('Администратор посмотрел клад', _buy.id)
        just_take(_buy)
        start
      end

      def view_easypay_trade
        sset('telebot_method', 'easypay')
        handle('process_payment')
        reply_update 'search/trade', trade: _trade, item: _buy, method: 'easypay'
        answer_callback "Выбран Easypay как средство платежа."
      end

      def view_qiwi_trade
        sset('telebot_method', 'qiwi')
        handle('process_payment')
        reply_update 'search/trade', trade: _trade, item: _buy, method: 'qiwi'
        answer_callback "Выбран Qiwi как средство платежа."
      end

      def view_bitobmen_trade
        sset('telebot_method', 'bitobmen')
        handle('process_payment')
        reply_update 'search/trade', trade: _trade, item: _buy, method: 'bitobmen'
        answer_callback "Выбран BitObmen как средство платежа."
      end

      def trade_overview(data = nil)
        handle('process_payment')
        if @tsx_bot.get_var('country') == 2
          sset('telebot_method', 'easypay')
        else
          sset('telebot_method', 'qiwi')
        end
        method = sget('telebot_method')
        buts = _trade.confirmation_buttons(hb_client, method)
        price = sget('buying_price')
        if price.picture.nil?
          reply_inline 'search/trade', trade: _trade, item: _buy, method: method
        else
          reply_logo price.picture, 'search/trade', trade: _trade, item: _buy, method: method
        end
        if method != 'qiwi'
          reply_simple 'search/confirm', buts: buts
        else
          reply_simple 'search/confirm_qiwi', buts: buts
        end
      end

      def process_payment(data)
        puts "METHOD: #{sget('telebot_method')}".colorize(:yellow)
        data.gsub!('\\', '')
        handle(sget('telebot_method'))
        send(sget('telebot_method'), data)
      end

      def cancel_trade
        reply_message "#{icon(@tsx_bot.icon_info)} Заказ отменен."
        botrec('Отмена заказа', _buy.id)
        can = Item[_buy.id]
        Item.where(id: can.id).update(status: Item::ACTIVE, unlock: nil)
        Trade.where(id: _trade.id).delete
        sdel('telebot_search_trading')
        start
      end

      def finalize_trade(code = 'с баланса', meth = nil)
        t = hb_client.has_pending_trade?(@tsx_bot)
        it = Item[t.item]
        t.finalize(it, code, meth, hb_client)
        botrec("Клад ##{t.item} оплачен кодом", code)
        handle('rank')
        send_item 'search/finalized', klad: it
      end

      def rate_trade
        t = hb_client.has_not_ranked_trade?(@tsx_bot)
        if !t.nil?
          item = Item[t.item]
          handle('rank')
          send_item 'search/finalized', klad: item
        else
          go_back
        end
      end

      def rank(data)
        t = hb_client.has_not_ranked_trade?(@tsx_bot)
        if !t.nil?
          if ["Хорошо", "Плохо"].include?(data)
            trade = Trade[t[:id]]
            seller = Client[trade.seller]
            buyer = Client[trade.buyer]
            begin
              rnk = RANKS.fetch(data.to_sym)
            rescue
              rnk = 3
            end
            seller.rank_seller(trade, rnk)
            trade.status = Trade::FINISHED
            trade.save
            reply_message "#{icon(@tsx_bot.icon_success)} Спасибо! Ваша оценка важна."
            unfilter
            botrec("Оценка за клад #{t.item} поставлена", rnk)
          end
        end
        start
      end

      def easypay(data)
        if callback_query?
          sset('telebot_method', data)
          trade_overview
        elsif data == 'Отменить'
          cancel_trade
        else
          botrec('[CHECK]')
          reply_message "#{icon(@tsx_bot.icon_wait)} Проверяем платеж *Easypay*. Вводите код через *10 минут* после оплаты."
          begin
            raise TSX::Exceptions::NoPendingTrade if !hb_client.has_pending_trade?(@tsx_bot)
            # raise TSX::Exceptions::NextTry if !hb_client.can_try?
            raise TSX::Exceptions::WrongFormat if @tsx_bot.check_easypay_format(data).nil?
            possible_codes = @tsx_bot.used_code?(data, @tsx_bot.id)
            handle('easypay')
            uah_price = @tsx_bot.amo_pure(_buy.discount_price_by_method(Meth::__easypay))
            code1 = Invoice.create(code: possible_codes.first, client: hb_client.id)
            code2 = Invoice.create(code: possible_codes.last, client: hb_client.id)
            seller = Client[_trade.seller]
            seller_bot = Bot[_buy.bot]
            uah_payment = @tsx_bot.check_easy_payment(@tsx_bot, [possible_codes.first, possible_codes.last], uah_price)
            rsp = eval(uah_payment.respond.inspect)
            puts "response from Tor processing server: #{rsp}".colorize(:blue)
            if rsp[:result] == 'error'
              puts "PAYMENT: #{rsp}"
              ex = eval("#{rsp[:exception]}.new(#{rsp[:amount].to_s})")
              raise ex
            else
              if hb_client.cashin(@tsx_bot.cnts(rsp[:amount].to_i), Client::__easypay, Meth::__easypay, Client::__tsx)
                puts "PAYMENT ACCEPTED: #{data}".colorize(:blue)
                botrec("Оплата клада #{_buy.id} зачислена. Коды пополнения: ", "#{code1.code}, #{code2.code}")
                reply_thread "#{icon(@tsx_bot.icon_success)} Оплата успешно зачислена.", hb_client
                finalize_trade(data, Meth::__easypay)
                # hb_client.allow_try
              end
            end
            botrec('[/CHECK]')
          rescue TSX::Exceptions::NextTry
            puts "PAYMENT TOO OFTEN, BOT #{@tsx_bot.title} #{data}".colorize(:yellow)
            reply_thread "#{icon(@tsx_bot.icon_warning)} Вы не можете так часто проверять код. Попробуйте *через #{minut(hb_client.next_try_in)}*.", hb_client
          rescue TSX::Exceptions::JustWait
            reply_thread "#{icon(@tsx_bot.icon_warning)} Пожалуйста попробуйте через 15 минут. Система обработки платежей на ремонте.", hb_client
          rescue TSX::Exceptions::PaymentNotFound
            hb_client.set_next_try(@tsx_bot)
            code1.delete
            code2.delete
            # hb_client.set_next_try(@tsx_bot)
            puts "PAYMENT NOT FOUND, BOT #{@tsx_bot.title}: #{data}".colorize(:yellow)
            reply_thread "#{icon(@tsx_bot.icon_warning)} Оплата не найдена. #{method_desc('easypay')}. Мы проверяем платежи каждые 10 минут. Если Вы уверены, что оплатили, попробуйте через пару минут.", hb_client
          rescue TSX::Exceptions::NotEnoughAmount => ex
            found_amount = ex.message.to_i
            puts "PAYMENT: NOT EMOUGH AMOUNT. FOUND JUST #{ex.message}".colorize(:red)
            reply_thread "#{icon(@tsx_bot.icon_warning)} Суммы не хватает, однако *#{@tsx_bot.amo(@tsx_bot.cnts(found_amount))}* зачислено Вам на баланс. Пополните бот необходимой суммой и нажмите *#{icon('dollar')} Оплатить с баланса* при покупке клада.", hb_client
            hb_client.cashin(@tsx_bot.cnts(found_amount.to_i), Client::__easypay, Meth::__easypay, Client::__tsx)
          rescue TSX::Exceptions::UsedCode => e
            hb_client.set_next_try(@tsx_bot)
            puts e.message
            puts "BAD PAYMENT: USED CODE #{data}".colorize(:yellow)
            reply_thread "#{icon(@tsx_bot.icon_warning)} Код уже был использован. Код пополнения Easypay должен иметь вид `00:0012345`. Если Вы уверены, что не использовали этот код, создайте запрос в службу поддержки.", hb_client
            puts "USED CODE".colorize(:yellow)
          rescue TSX::Exceptions::WrongFormat
            puts "WRONG FORMAT".colorize(:yellow)
            reply_thread "#{icon(@tsx_bot.icon_warning)} Неверный формат кода пополнения. Пожалуйста, прочитайте внимательно /payments и вводите сразу верный код пополнения.", hb_client
          rescue TSX::Exceptions::NoPendingTrade
            reply_thread "#{icon(@tsx_bot.icon_warning)} Заказ был отменен. Начните сначала.", hb_client
            start
          rescue => e
            puts "PAYMENT EXCEPTION: #{e.message}"
            botrec("PAYMENT General Exception", e.message)
            code1.delete if !code1.nil?
            code2.delete if !code2.nil?
            puts "PAYMENT EXCEPTION --------------------"
            puts "--------------------"
            puts "Ошибка соединения:  #{e.message}"
            # puts "PAYMENT EXCEPTION: #{e.backtrace.join("\t\n")}"
            puts "----------------------"
          end
        end
      end

      def pay_by_balance
        # reply_message 'платежи закрыты'
        meth = Meth.find(title: sget('telebot_method'))
        balance = hb_client.available_cash
        disc = _buy.discount_price_by_method(meth)
        puts "BALANCE: #{balance}"
        puts "DISCOUNT: #{disc}"
        if balance+25 >= disc
          botrec("Оплата клада #{_buy.id} с баланса")
          finalize_trade('с баланса', meth)
          reply_message "#{icon(@tsx_bot.icon_success)} Оплачено."
        else
          reply_message "#{icon(@tsx_bot.icon_success)} Вы не можете купить с баланса. У Вас мало денег."
        end
      end

      def qiwi(data = nil)
        if callback_query?
          sset('telebot_method', data)
          trade_overview
        elsif data == 'Отменить'
          cancel_trade
        else
          if !hb_client.has_pending_trade?(@tsx_bot)
            reply_message "#{icon(@tsx_bot.icon_warning)} Заказ был отменен. Начните сначала."
            start
          else
            begin
              handle('qiwi')
              @tsx_bot.used_qiwi_code?(_trade.random, @tsx_bot.id)
              uah_price = @tsx_bot.amo_pure(_buy.discount_price_by_method(Meth::__easypay))
              reply_message "#{icon(@tsx_bot.icon_wait)} Проверяем платеж *Qiwi*."
              @amount = @tsx_bot.check_qiwi_payment(@tsx_bot, _trade.random, uah_price)
              rsp = eval(@amount.respond.inspect)
              if rsp[:result] == 'error'
                puts "PAYMENT: #{rsp}"
                ex = eval("#{rsp[:exception]}.new(#{rsp[:amount].to_s})")
                raise ex
              else
                if hb_client.cashin(@tsx_bot.cnts(rsp[:amount].to_i), Client::__easypay, Meth::__bitobmen, Client::__tsx)
                  puts "PAYMENT ACCEPTED: #{data}".colorize(:blue)
                  Invoice.create(code: _trade.random, client: hb_client.id)
                  reply_thread "#{icon(@tsx_bot.icon_success)} Оплата успешно зачислена.", hb_client
                  finalize_trade(_trade.random, Meth::__easypay)
                  # hb_client.allow_try
                end
              end
            rescue TSX::Exceptions::UsedCode => e
              reply_thread "#{icon(@tsx_bot.icon_warning)} Этот заказ уже закрыт. Если Вы уверены, что это ошибка, задайте вопрос службе поддержки.", hb_client
              puts "USED CODE".colorize(:yellow)
            rescue TSX::Exceptions::PaymentNotFound
              puts "PAYMENT NOT FOUND, BOT #{@tsx_bot.title}: #{data}".colorize(:yellow)
              reply_thread "#{icon(@tsx_bot.icon_warning)} Оплата *не найдена*. Подробнее /payments.", hb_client
            rescue TSX::Exceptions::NotEnoughAmount => ex
              found_amount = ex.message.to_i
              puts "PAYMENT: NOT EMOUGH AMOUNT. FOUND JUST #{ex.message}".colorize(:red)
              Invoice.create(code: _trade.random, client: hb_client.id)
              _trade.update(random: rand(100000..900000))
              reply_thread "#{icon(@tsx_bot.icon_warning)} Суммы не хватает, однако *#{@tsx_bot.amo(@tsx_bot.cnts(found_amount))}* зачислено Вам на баланс. Пополните бот необходимой суммой и нажмите *#{icon('dollar')} Оплатить с баланса* при покупке клада.", hb_client
              hb_client.cashin(@tsx_bot.cnts(found_amount.to_i), Client::__easypay, Meth::__easypay, Client::__tsx)
            end
          end
        end
      end

      def bitobmen(data)
        if callback_query?
          sset('telebot_method', data)
          trade_overview
        elsif data == 'Отменить'
          cancel_trade
        else
          if !hb_client.has_pending_trade?(@tsx_bot)
            reply_message "#{icon(@tsx_bot.icon_warning)} Заказ был отменен. Начните сначала."
            start
          else
            begin
              handle('bitobmen')
              uah_price = @tsx_bot.amo_pure(_buy.discount_price_by_method(Meth::__easypay))
              reply_message "#{icon(@tsx_bot.icon_wait)} Проверяем платеж *BitObmen*."
              raise TSX::Exceptions::NoBitObmenEmail if @tsx_bot.bitemail.nil?
              @amount = @tsx_bot.check_bitobmen(@tsx_bot, data, uah_price)
              rsp = eval(@amount.respond.inspect)
              if rsp[:result] == 'error'
                puts "PAYMENT: #{rsp}"
                ex = eval("#{rsp[:exception]}.new(#{rsp[:amount].to_s})")
                raise ex
              else
                if hb_client.cashin(@tsx_bot.cnts(rsp[:amount].to_i), Client::__easypay, Meth::__bitobmen, Client::__tsx)
                  puts "PAYMENT ACCEPTED: #{data}".colorize(:blue)
                  botrec("Оплата клада #{_buy.id} зачислена. Коды пополнения: ", "#{code1.code}, #{code2.code}")
                  reply_thread "#{icon(@tsx_bot.icon_success)} Оплата успешно зачислена.", hb_client
                  finalize_trade(data, Meth::__easypay)
                  # hb_client.allow_try
                end
              end
            rescue TSX::Exceptions::NoBitObmenEmail
              reply_thread "#{icon(@tsx_bot.icon_warning)} *BitObmen* не настроен для этого магазина. Обратитесь в службу поддержки.", hb_client
            rescue TSX::Exceptions::PaymentNotFound
              puts "PAYMENT NOT FOUND, BOT #{@tsx_bot.title}: #{data}".colorize(:yellow)
              reply_thread "#{icon(@tsx_bot.icon_warning)} Оплата *не найдена*. #{method_desc('bitobmen')}.", hb_client
            rescue TSX::Exceptions::NotEnoughAmount => ex
              found_amount = ex.message.to_i
              puts "PAYMENT: NOT EMOUGH AMOUNT. FOUND JUST #{ex.message}".colorize(:red)
              reply_thread "#{icon(@tsx_bot.icon_warning)} Суммы не хватает, однако #{@tsx_bot.amo(@tsx_bot.cnts(found_amount))} зачислено Вам на баланс. #{method_desc('easypay')} Помощь /payments.", hb_client
              hb_client.cashin(@tsx_bot.cnts(found_amount.to_i), Client::__easypay, Meth::__easypay, Client::__tsx)
            end
          end
        end
      end

      def cancel
        reply_message "#{icon('no_entry_sign')} Отменено успешно."
        serp
      end

      def abuse(data = nil)
        if !data
          handle('abuse')
          reply_message "#{icon('oncoming_police_car')} *Написать жалобу*\nНапишите жалобу в свободной форме. *Обязательно!* укажите, *на какой конкретно бот* жалоба и коротко суть.", btn_cancel
        else
          # Bot::chief.say(Client[286922].tele, "Новая жалоба на бот #{@tsx_bot.nickname_md} от `@#{hb_client.username}`: #{@payload.text}")
          reply_message "#{icon(@tsx_bot.icon_success)} Мы получили Вашу жалобу и обязательно примем меры. Спасибо за отзыв!"
          serp
        end
      end

      def redeem_voucher(data = nil)
        voucher = data
        hb_client.cashin(voucher.amount, Client::__easypay, Meth::__easypay, Client::__tsx)
        reply_message "#{icon('moneybag')} *Поздравляем!* Вы обналичили ваучер на сумму *#{@tsx_bot.amo(voucher.amount)}* Эти деньги *зачислены Вам на баланс*. Вы можете их тратить. Приятных покупок!"
        voucher.delete
        start
      end

    end
  end
end