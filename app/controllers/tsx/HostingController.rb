require 'geocoder'
module TSX
  module Controllers
    module Hosting

      def start_hosting
        hosting_not_permitted if hb_client[:master].nil?
        reply_simple 'hosting/menu'
      end

      def hosting_rules
        reply_simple 'hosting/rules'
      end

      def hosting_tarrifs
        hosting_not_permitted if hb_client[:master].nil?
        reply_simple 'hosting/tarrifs'
      end

      def hosting_add_kladman(data = nil)
        handle('hosting_add_kladman')
        if !data
          reply_message "#{icon('pencil2')} Введите номер клиента нового сотрудника."
        else
          client = Client[data]
          raise TSXException.new("Нет такого клиента `#{data}`") if client.nil?
          sset('hosting_new_kladman', client)
          hosting_kladman_bot
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
          kladman = sget('hosting_new_kladman')
          puts kladman.inspect
          raise TSXException.new("Нет такого бота `#{data}`") if bot.nil?
          kladman.update(master: bot.id)
          bot.add_operator(kladman, Client::HB_ROLE_KLADMAN)
          reply_message "Кладман #{icon('id')} *#{kladman.id}* добавлен в бот *#{bot.id}*"
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
            Ledger.create(
              debit: Client::__salary.id,
              credit: hb_client.id,
              amount: price.salary,
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