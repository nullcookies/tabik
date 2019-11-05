require 'geocoder'
module TSX
  module Controllers
    module Hosting

      def start_hosting
        hosting_not_permitted if hb_client[:master].nil?
        bot = Bot[hb_client[:master]]
        puts bot.inspect
        puts hb_client.is_admin?(bot)
        if hb_client.is_admin?(bot)
          puts "I AM ADMIN!!!!!!!!!!!!!!!"
          hosting_admin_menu
          kladmans = bot.kladmans
          handle('kladman_card')
          reply_inline 'hosting/menu_admin', master: bot, kladmans: kladmans
        else
          staff = Staff.find(client: hb_client.id)
          reply_simple 'hosting/menu', staff: staff
        end
      end

      def kladman_card(data = nil)
        client = Client[data]
        staff = Staff.find(client: data.to_i)
        puts "KLADMANS: #{client.inspect}".colorize(:red)
        sset('hosting_kladman', client)
        reply_update 'hosting/card', kladman: client, staff: staff
      end

      def show_kladman_card(data)
        staff = Staff.find(client: data.id)
        sset('hosting_kladman', data)
        reply_inline 'hosting/card', kladman: data, staff: staff
      end

      def klad_not_found(data = nil)
        Ledger.create(
            debit: sget('hosting_kladman').id,
            credit: Client::__fine.id,
            amount: FINE,
            details: "Штраф за ненаход",
            status: Ledger::CLEARED,
            created: Time.now
        )
        answer_callback "Штраф начислен."
        kladman_card(sget('hosting_kladman').id)
      end

      def back_to_kladmans
        handle('kladman_card')
        bot = Bot[hb_client[:master]]
        kladmans = bot.kladmans
        reply_update 'hosting/menu_admin', master: bot, kladmans: kladmans
      end

      def hosting_admin_menu
        reply_simple 'hosting/admin_buttons'
      end

      def hosting_rules
        reply_simple 'hosting/rules'
      end

      def hosting_tarrifs
        hosting_not_permitted if hb_client[:master].nil?
        reply_simple 'hosting/tarrifs'
      end

      def kladman_pay_out(data = nil)
        handle('kladman_pay_out')
        if !data
          reply_message "#{icon('pencil2')} Сколько выплатить?"
        else
          kladman = sget('hosting_kladman')
          Ledger.create(
              debit: kladman.id,
              credit: Client::__salarypaid.id,
              amount: @tsx_bot.cnts(data.to_i),
              details: "Выплата кладчику ##{kladman.id}",
              status: Ledger::CLEARED,
              created: Time.now
          )
          answer_callback "Выплачено."
          show_kladman_card(sget('hosting_kladman'))
        end
      end

      def kladman_add_debt(data = nil)
        handle('kladman_add_debt')
        if !data
          reply_message "#{icon('pencil2')} Сколько бавить в долг?"
        else
          kladman = sget('hosting_kladman')
          Ledger.create(
              debit: Client::__salary.id,
              credit: kladman.id,
              amount: @tsx_bot.cnts(data.to_i),
              details: "Добавить кладчику ##{kladman.id}",
              status: Ledger::PENDING,
              created: Time.now
          )
          answer_callback "Добавлено к выплате."
          show_kladman_card(sget('hosting_kladman'))
        end
      end

      def kladman_send_opt(data = nil)
        handle('kladman_send_opt')
        if !data
          reply_message "#{icon('pencil2')} Сколько кладов выдано?"
        else
          kladman = sget('hosting_kladman')
          rst = Staff.find(client: kladman.id)
          Staff.find(client: kladman.id).update(rest: rst.rest + data.to_i)
          reply_message "Выдано *#{data} кладов*."
          show_kladman_card(kladman)
        end
      end

      def kladman_transfer_opt(data = nil)
        handle('kladman_transfer_opt')
        if !data
          bot = Bot[hb_client[:master]]
          kladmans = bot.kladmans
          reply_inline 'hosting/choose_kladmans', kladmans: kladmans
        else
          sset('hosting_transfer_to', data)
          handle('transfer_klads')
          reply_message "#{icon('pencil2')} Сколько передать кладов *#{Client[data].username}*?"
        end
      end

      def transfer_klads(data = nil)
        from = sget('hosting_kladman')
        to = Client[sget('hosting_transfer_to').to_i]
        staff_from = Staff.find(client: from.id)
        staff_to = Staff.find(client: to.id)
        rest_from = staff_from.rest
        rest_to = staff_to.rest
        staff_from.update(rest: rest_from - data.to_i)
        staff_from.update(to: rest_to + data.to_i)
        show_kladman_card(from)
      end

      def hosting_add_kladman(data = nil)
        handle('hosting_add_kladman')
        if !data
          reply_message "#{icon('pencil2')} Введите номер клиента нового сотрудника."
        else
          begin
            Integer(data)
            client = Client[data]
            raise TSXException.new("#{icon('warning')} Нет такого клиента") if client.nil?
            sset('hosting_new_kladman', client)
            hosting_kladman_bot
          rescue
            raise TSXException.new("#{icon('warning')} Номер клиента может быть только цифрой")
          end
        end
      end

      def hosting_add_owner(data = nil)
        handle('hosting_add_owner')
        if !data
          reply_message "#{icon('pencil2')} Введите номер клиента владельца бота."
        else
          begin
            Integer(data)
            client = Client[data]
            raise TSXException.new("#{icon('warning')} Нет такого клиента") if client.nil?
            sset('hosting_new_kladman', client)
            hosting_owner_bot
          rescue
            raise TSXException.new("#{icon('warning')} Номер клиента может быть только цифрой")
          end
        end
      end

      def hosting_owner_bot(data = nil)
        handle('hosting_owner_bot')
        if !data
          reply_message "#{icon('pencil2')} Введите номер бота, в котором он будет владельцем."
        else
          bot = Bot[data]
          puts "HELLOOOO".colorize(:yellow)
          puts bot.inspect
          kladman = sget('hosting_new_kladman')
          puts kladman.inspect
          raise TSXException.new("Нет такого бота `#{data}`") if bot.nil?
          kladman.update(master: bot.id)
          Staff.create(client: kladman.id)
          bot.add_operator(kladman, Client::HB_ROLE_ADMIN)
          reply_message "Владелец бота #{icon('id')} *#{kladman.id}* добавлен в бот *#{bot.id}*"
        end
      end

      def hosting_kladman_bot(data = nil)
        handle('hosting_kladman_bot')
        if !data
          reply_message "#{icon('pencil2')} Введите номер бота, в котором он будет работать."
        else
          bot = Bot[data]
          puts "HELLOOOO".colorize(:yellow)
          puts bot.inspect
          sset('hosting_new_kladman_bot', bot)
          kladman = sget('hosting_new_kladman')
          puts kladman.inspect
          raise TSXException.new("Нет такого бота `#{data}`") if bot.nil?
          kladman.update(master: bot.id)
          hosting_kladman_salary
        end
      end

      def hosting_kladman_salary(data = nil)
        handle('hosting_kladman_salary')
        if !data
          reply_message "#{icon('pencil2')} Введите зарплату сотрудника за один клад."
        else
          b = sget('hosting_new_kladman_bot')
          kladman = sget('hosting_new_kladman')
          st = Staff.create(client: kladman.id, salary: @tsx_bot.cnts(data))
          b.add_operator(kladman, Client::HB_ROLE_KLADMAN)
          reply_message "Кладман #{icon('id')} *#{kladman.id}* добавлен в бот *#{b.id}*. Зарплата за один клад будет *#{b.amo(st.salary)}*"
        end
      end

      def show_kladman_tarrifs(data = nil)
        reply_inline 'hosting/change_trarrifs'
      end

      def hosting_uploads
        bot = Bot[hb_client[:master]]
        hosting_not_permitted if !hb_client.is_kladman?(bot)
        handle('hosting_choose_district')
        cities = bot.cities_list
        reply_inline 'hosting/choose_city', cities: cities
      end

      def hosting_choose_district(data = nil)
        bot = Bot[hb_client[:master]]
        handle('hosting_choose_product')
        city = City[data]
        sset('meine_city', city)
        districts = District.where(city: city.id).paginate(1, 18)
        sset('hosting_districts_page', districts.current_page.to_i)
        reply_update 'hosting/choose_districts', districts: districts, city: city
      end

      def hosting_next_districts(data = nil)
        page = sget('hosting_districts_page')
        sset('hosting_districts_page', page.to_i + 1)
        city = sget('meine_city')
        districts = District.where(city: city.id).paginate(page.to_i + 1, 18)
        reply_update 'hosting/choose_districts', districts: districts, city: city
      end

      def hosting_prev_districts(data = nil)
        page = sget('hosting_districts_page')
        sset('hosting_districts_page', page.to_i - 1)
        city = sget('meine_city')
        districts = District.where(city: city.id).paginate(page.to_i - 1, 18)
        reply_update 'hosting/choose_districts', districts: districts, city: city
      end

      def hosting_choose_product(data = nil)
        bot = Bot[hb_client[:master]]
        handle('hosting_choose_prices')
        district = District[data]
        sset('meine_district', district)
        products = Product.available_by_bot(bot)
        reply_update 'hosting/choose_product', products: products
      end

      def hosting_choose_prices(data = nil)
        bot = Bot[hb_client[:master]]
        handle('hosting_enter_klads')
        ps = Product[data]
        sset('meine_product', ps)
        prcs = Price.where(product: ps.id, bot: bot.id)
        reply_update 'hosting/choose_prices', prices: prcs
      end

      def hosting_enter_klads(data = nil)
        handle('hosting_save_klads')
        price = Price[data]
        sset('meine_price', price)
        city = sget('meine_city')
        product = sget('meine_product')
        district = sget('meine_district')
        reply_simple 'hosting/enter_klads', price: price, city: city, district: district, product: product
      end

      def hosting_cancel_upload
        sdel('meine_price')
        sdel('meine_product')
        sdel('meine_district')
        sdel('meine_city')
        unhandle
        start_hosting
      end

      def hosting_save_klads(data = nil)
        bot = Bot[hb_client[:master]]
        pics = @payload.text.split("\n")
        puts "uploading FILES 1"
        city = sget('meine_city')
        district = sget('meine_district')
        product = sget('meine_product')
        price = sget('meine_price')
        # price = params['price'].chomp
        # qnt = params['qnt'].chomp
        lines = ''
        pics.each do |line|
          begin
            it = Item.create(
                product: price.product,
                photo: line,
                full: nil,
                qnt: price.qnt,
                prc: price.id,
                price: price.price,
                city: city.id,
                district: district.id,
                client: hb_client.id,
                bot: bot.id,
                created: Time.now,
                status: Item::ACTIVE
            )
            staff = Staff.find(client: hb_client.id)
            Ledger.create(
              debit: Client::__salary.id,
              credit: hb_client.id,
              amount: staff.salary,
              details: "Зарплата за клад ##{it.id}: #{price.salary}",
              status: Ledger::PENDING,
              created: Time.now
            )
            puts "uploading FILES #{it.id}"
            lines = lines + "#{icon('large_orange_diamond')} Клад *##{it.id}* добавлен.\n\r"
          rescue => e
            puts e.message.colorize(:red)
            puts "duplicate item"
            lines = lines + "#{icon('no_entry_sign')} Клад не добавлен. Дубликат.\n\r"
          end
        end
        puts lines
        reply_message "#{icon('white_check_mark')} *Готово*\n\r\n\rОбратите внимание, что в систему невозможно добавить дубликат клада. Все ссылки должны быть уникальными. Ниже отчет о загрузке кладов.\n\r\n\r#{lines}"
        hosting_cancel_upload
      end

      def hosting_not_permitted
        reply_simple 'hosting/not_registered'
        [200, {}, ['']]
        halt
      end

    end
  end
end