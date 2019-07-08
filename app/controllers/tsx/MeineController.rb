require 'geocoder'
module TSX
  module Controllers
    module Meine

      def admin_menu
        not_permitted if !hb_client.is_admin?(@tsx_bot)
        reply_simple 'admin/menu'
        reply_inline 'admin/botstat'
      end

      def bot_icons(data = nil)
        reply_update 'admin/icons'
      end

      def show_bot_icons(data = nil)
        reply_inline 'admin/icons'
      end

      def enter_icon_main(data = nil)
        handle('enter_icon_main')
        if !data
          reply_message "#{icon('pencil2')} Введите текстовоя значение для иконки кнопки *Главная*."
        else
          @tsx_bot.update(icon: data)
          show_bot_icons
        end
      end

      def enter_icon_geo(data = nil)
        handle('enter_icon_geo')
        if !data
          reply_message "#{icon('pencil2')} Введите текстовоя значение для иконки кнопок *Городов* и *Районов*."
        else
          @tsx_bot.update(icon_geo: data)
          show_bot_icons
        end
      end

      def enter_icon_discount(data = nil)
        handle('enter_icon_discount')
        if !data
          reply_message "#{icon('pencil2')} Введите текстовоя значение для иконки *скидок*."
        else
          @tsx_bot.update(icon_old: data)
          show_bot_icons
        end
      end

      def enter_icon_back(data = nil)
        handle('enter_icon_back')
        if !data
          reply_message "#{icon('pencil2')} Введите текстовоя значение для иконки кнопки *Назад*."
        else
          @tsx_bot.update(icon_back: data)
          show_bot_icons
        end
      end


      def enter_avatar
        not_permitted if !hb_client.is_admin?(@tsx_bot)
        handle('save_bot_avatar')
        reply_message "#{icon('pencil2')} Пришлите *прямую ссылку* на аватар бота. Нужна прямая ссылка на файл с изображением. Проверьте самостоятельно предварительно в бровзере, чтобы открывалась картинка."
      end

      def save_bot_avatar(data = nil)
        @tsx_bot.update(avatar: @payload.text)
        admin_interface
      end

      def bot_buttons(data = nil)
        handle('view_button')
        buttons = Button.where(bot: @tsx_bot.id)
        reply_update 'admin/bot_buttons', buttons: buttons
      end

      def show_bot_buttons(data = nil)
        handle('view_button')
        buttons = Button.where(bot: @tsx_bot.id)
        reply_inline 'admin/bot_buttons', buttons: buttons
      end

      def view_button(data = nil)
        button = Button[data]
        sset('meine_button', button)
        reply_update 'admin/view_button', button: button
      end

      def delete_bot_button(data = nil)
        sget('meine_button').delete
        bot_buttons
      end

      def enter_bot_title(data = nil)
        handle('enter_bot_title')
        if !data
          reply_message "#{icon('pencil2')} Введите название бота. Это название будет видно на главной."
        else
          @tsx_bot.update(title: @payload.text)
          admin_interface
        end
      end

      def enter_bot_support(data = nil)
        handle('enter_bot_support')
        if !data
          reply_message "#{icon('pencil2')} Введите контакты службы поддержки через запятую *без собак и пробелов*, если их несколько. Например `support` или `support1,support2`"
        else
          @tsx_bot.update(support: @payload.text)
          admin_interface
        end
      end

      def enter_discount_period(data = nil)
        handle('enter_discount_period')
        if !data
          reply_message "#{icon('pencil2')} Введите, через *сколько дней* клады продаются со скидкой. Вводите только цифру."
        else
          sset('meine_discount_period', data)
          enter_discount_percent
        end
      end

      def enter_discount_percent(data = nil)
        handle('enter_discount_percent')
        if !data
          reply_message "#{icon('pencil2')} Введите скиду в процентах. Вводите только цифру."
        else
          @tsx_bot.update(discount: data, discount_period: sget('meine_discount_period'))
          admin_choose_product_for_prices
        end
      end

      def enter_button_title(data = nil)
        handle('enter_button_title')
        if !data
          reply_message "#{icon('pencil2')} Введите наименование кнопки. Можно использовать emoji. Например #{icon('family')} *Отзывы*"
        else
          sset('meine_button_title', @payload.text)
          enter_button_body
        end
      end

      def enter_button_body(data = nil)
        handle('enter_button_body')
        if !data
          reply_message "#{icon('pencil2')} Введите текст в свободной форме, который будет показан при нажатии на кнопку."
        else
          sset('meine_button_body', @payload.text)
          save_button
        end
      end

      def save_button(data = nil)
        Button.create(
          bot: @tsx_bot.id,
          title: sget('meine_button_title'),
          body: sget('meine_button_body'),
          status: 1
        )
        show_bot_buttons
      end

      def back_to_wallets(data = nil)
        handle('view_wallet')
        reply_update 'admin/choose_wallet'
      end

      def admin_interface(data = nil)
        reply_inline 'admin/interface'
      end

      def view_admin_interface(data = nil)
        reply_update 'admin/interface'
      end

      def enter_qnt(data = nil)
        handle('enter_qnt')
        if !data
          reply_message "#{icon('pencil2')} Введите фасовку. Например `2г`, `0.25г`, `Коробка`."
        else
          pr = Price.find(qnt: data, product: sget('meine_product').id, bot: @tsx_bot.id)
          raise TSXException.new("#{icon('warning')} Такая фасовка уже есть.") if !pr.nil?
          sset('meine_qnt', data)
          enter_qnt_price
        end
      end

      def enter_qnt_price(data = nil)
        handle('enter_qnt_price')
        if !data
          reply_message "#{icon('pencil2')} Введите цену. Цена не может быть меньше 100грн."
        else
          begin
            Integer(data)
            raise TSXException.new("#{icon('warning')} Цена не может быть меньше 100грн.") if data.to_i < 100
            sset('meine_qnt_price', data)
            save_qnt
          rescue
            raise TSXException.new("#{icon('warning')} Цена должна быть цифрой.")
          end
        end
      end

      def save_qnt
        qnt = sget('meine_qnt')
        price = sget('meine_qnt_price')
        product = sget('meine_product')
        Price.create(
          product: product.id,
          qnt: qnt,
          price: @tsx_bot.cnts(price),
          bot: @tsx_bot.id
        )
        admin_view_product_prices(product.id)
      end

      def enter_keeper(data = nil)
        handle('enter_keeper')
        if !data
          reply_message "#{icon('pencil2')} Введите *номер кошелька*, который будут видеть покупатели."
        else
          sset('meine_keeper', data)
          enter_wallet
        end
      end

      def enter_wallet(data = nil)
        handle('enter_wallet')
        if !data
          reply_message "#{icon('pencil2')} Введите *номер внутреннего кошелька* Easypay. Пример /easypaywallet"
        else
          sset('meine_wallet', data)
          enter_phone
        end
      end

      def enter_phone(data = nil)
        handle('enter_phone')
        if !data
          reply_message "#{icon('pencil2')} Введите *номер телефона* для входа в Easypay."
        else
          sset('meine_phone', data)
          enter_password
        end
      end

      def enter_password(data = nil)
        handle('enter_password')
        if !data
          reply_message "#{icon('pencil2')} Введите *пароль* для входа в Easypay."
        else
          sset('meine_password', data)
          save_wallet
        end
      end

      def save_wallet(data = nil)
        unhandle
        Wallet.create(
          bot: @tsx_bot.id,
          active: 0,
          keeper: sget('meine_keeper'),
          wallet: sget('meine_wallet'),
          phone: sget('meine_phone'),
          password: sget('meine_password'),
        )
        admin_wallets
      end

      def activate_wallet
        wall = sget('meine_wallet').id
        Wallet.where(bot: @tsx_bot.id).update(active: 0)
        Wallet[wall].update(active: 1)
        view_wallet(wall)
      end

      def today_payments(data = nil)
        wallet = sget('meine_wallet')
        payments = Easypay.where(wallet: wallet.id).limit(20).order(Sequel.desc(:created))
        reply_update 'admin/today_payments', payments: payments, wallet: wallet
      end

      def admin_wallets(data = nil)
        handle('view_wallet')
        reply_inline 'admin/choose_wallet'
      end

      def view_wallet(data = nil)
        wallet = Wallet[data]
        sset('meine_wallet', wallet)
        reply_update 'admin/view_wallet', wallet: wallet
      end

      def sure_delete(data = nil)
        wallet = sget('meine_wallet')
        reply_update 'admin/sure_delete', wallet: wallet
      end

      def delete_wallet(data = nil)
        wallet = sget('meine_wallet')
        sget('meine_wallet').delete
        back_to_wallets
      end

      def do_not_delete
        back_to_wallets
      end

      def admin_choose_product_for_prices(data = nil)
        not_permitted if !hb_client.is_admin?(@tsx_bot)
        handle('admin_set_prices')
        if !@tsx_bot.discount.nil? and !@tsx_bot.discount_period.nil?
          discount_string = "Скидки #{icon(@tsx_bot.icon_old)} *#{@tsx_bot.discount}%* через *#{dney(@tsx_bot.discount_period)}*"
        else
          discount_string = "Скидки *не установлены*"
        end
        products = Product.available_by_bot(@tsx_bot)
        reply_inline 'admin/choose_product_for_prices', products: products, discount_string: discount_string
      end

      def back_to_bot_products(data = nil)
        not_permitted if !hb_client.is_admin?(@tsx_bot)
        handle('admin_set_prices')
        products = Product.available_by_bot(@tsx_bot)
        reply_update 'admin/choose_product_for_prices', products: products
      end

      def admin_choose_all_products(data = nil)
        not_permitted if !hb_client.is_admin?(@tsx_bot)
        products = Product.available.paginate(1, 18)
        sset('admin_products_page', products.current_page)
        reply_update 'admin/all_products', products: products, page: 1
      end

      def admin_view_next_products_page(data = nil)
        not_permitted if !hb_client.is_admin?(@tsx_bot)
        page = sget('admin_products_page')
        sset('admin_products_page', page.to_i + 1)
        products = Product.available.paginate(page.to_i + 1, 18)
        reply_update 'admin/all_products', products: products, page: page
      end

      def admin_view_prev_products_page(data = nil)
        not_permitted if !hb_client.is_admin?(@tsx_bot)
        page = sget('admin_products_page')
        sset('admin_products_page', page.to_i - 1)
        products = Product.available.paginate(page.to_i - 1, 18)
        reply_update 'admin/all_products', products: products, page: page
      end

      def admin_set_prices(data = nil)
        not_permitted if !hb_client.is_admin?(@tsx_bot)
        handle('enter_new_price')
        product = Product[data]
        prices = Price.where(product: product.id, bot: @tsx_bot.id).distinct(:price__qnt)
        sset('meine_product', product)
        reply_update 'admin/product_prices', product: product, prices: prices
      end

      def admin_view_product_prices(data = nil)
        not_permitted if !hb_client.is_admin?(@tsx_bot)
        handle('enter_new_price')
        product = Product[data]
        prices = Price.where(product: product.id, bot: @tsx_bot.id).distinct(:price__qnt)
        sset('meine_product', product)
        reply_inline 'admin/product_prices', product: product, prices: prices
      end

      def enter_new_price(data = nil)
        not_permitted if !hb_client.is_admin?(@tsx_bot)
        product = sget('meine_product')
        handle('update_product_price')
        sset('meine_price', Price[data])
        reply_message "#{icon('pencil2')} Введите новую цену. Обратите внимание, что во избежание накруток топа, цена за клад *не может быть меньше 100грн*."
      end

      def update_product_price(data = nil)
        not_permitted if !hb_client.is_admin?(@tsx_bot)
        price = sget('meine_price')
        begin
          Integer(data)
          raise TSXException.new("#{icon('warning')} Цена не может быть меньше 100грн.") if data.to_i < 100
          price.update(price: @tsx_bot.cnts(data))
        rescue
          raise TSXException.new("#{icon('warning')} Цена должна быть цифрой.")
        end
        admin_view_product_prices(sget('meine_product').id)
      end

      def change_prices
        handle('admin_save_prices')
        product = sget('meine_product')
        reply_simple 'admin/enter_prices', product: product
      end

      def admin_team
        not_permitted if !hb_client.is_admin?(@tsx_bot)
        reply_inline 'admin/team'
      end

      def admin_uploads
        not_permitted if !hb_client.is_admin?(@tsx_bot)
        handle('choose_district')
        cities = City.where(country: @tsx_bot.get_var('country'))
        reply_inline 'admin/choose_city', city: cities
      end

      def choose_district(data = nil)
        not_permitted if !hb_client.is_admin?(@tsx_bot)
        handle('choose_product')
        city = City[data]
        sset('meine_city', city)
        districts = District.where(city: city.id).paginate(1, 9)
        sset('admin_districts_page', districts.current_page.to_i + 1)
        reply_update 'admin/choose_districts', districts: districts, city: city
      end

      def next_districts(data = nil)
        page = sget('admin_districts_page')
        sset('admin_districts_page', page.to_i + 1)
        city = sget('meine_city')
        districts = District.where(city: city.id).paginate(page.to_i + 1, 9)
        reply_update 'admin/choose_districts', districts: districts, city: city
      end

      def prev_districts(data = nil)
        page = sget('admin_districts_page')
        sset('admin_districts_page', page.to_i - 1)
        city = sget('meine_city')
        districts = District.where(city: city.id).paginate(page.to_i - 1, 9)
        reply_update 'admin/choose_districts', districts: districts, city: city
      end

      def choose_product(data = nil)
        not_permitted if !hb_client.is_admin?(@tsx_bot)
        handle('choose_prices')
        district = District[data]
        sset('meine_district', district)
        products = Product.available_by_bot(@tsx_bot)
        reply_update 'admin/choose_product', products: products
      end

      def choose_prices(data = nil)
        not_permitted if !hb_client.is_admin?(@tsx_bot)
        handle('enter_klads')
        ps = Product[data]
        sset('meine_product', ps)
        prcs = Price.where(product: ps.id, bot: @tsx_bot.id)
        reply_update 'admin/choose_prices', prices: prcs
      end

      def enter_klads(data = nil)
        not_permitted if !hb_client.is_admin?(@tsx_bot)
        handle('save_klads')
        price = Price[data]
        sset('meine_price', price)
        city = sget('meine_city')
        product = sget('meine_product')
        district = sget('meine_district')
        reply_simple 'admin/enter_klads', price: price, city: city, district: district, product: product
      end

      def admin_cancel_upload
        sdel('meine_price')
        sdel('meine_product')
        sdel('meine_district')
        sdel('meine_city')
        unhandle
        admin_menu
      end

      def save_klads(data = nil)
        not_permitted if !hb_client.is_admin?(@tsx_bot)
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
                bot: @tsx_bot.id,
                created: Time.now,
                status: Item::ACTIVE
            )
            puts "uploading FILES #{it.id}"
            lines = lines + "#{icon('large_orange_diamond')} Клад *##{it.id}* добавлен.\n\r"
          rescue
            puts "duplicate item"
            lines = lines + "#{icon('no_entry_sign')} Клад не добавлен. Дубликат.\n\r"
          end
        end
        puts lines
        reply_message "#{icon('white_check_mark')} *Готово*\n\r\n\rОбратите внимание, что в систему невозможно добавить дубликат клада. Все ссылки должны быть уникальными. Ниже отчет о загрузке кладов.\n\r\n\r#{lines}"
        admin_cancel_upload
      end

      def admin_spam(data = nil)
        not_permitted if !hb_client.is_admin?(@tsx_bot)
        handle('edit_spam')
        reply_inline 'admin/spam'
      end

      def admin_back_to_spam(data = nil)
        not_permitted if !hb_client.is_admin?(@tsx_bot)
        sdel('admin_spam')
        admin_spam
      end

      def admin_resend_spam(data = nil)
        not_permitted if !hb_client.is_admin?(@tsx_bot)
        sget('admin_spam').update(status: Spam::NEW)
        admin_back_to_spam
      end

      def admin_delete_spam(data = nil)
        not_permitted if !hb_client.is_admin?(@tsx_bot)
        sget('admin_spam').delete
        admin_back_to_spam
      end

      def admin_edit_spam(data = nil)
        not_permitted if !hb_client.is_admin?(@tsx_bot)
        edit_spam(sget('admin_spam').id)
      end

      def edit_spam(data = nil)
        not_permitted if !hb_client.is_admin?(@tsx_bot)
        handle('edit_spam')
        spam = Spam[data]
        sset('admin_spam', spam)
        reply_update 'admin/single_spam', spam: spam
      end

      def admin_create_spam(data = nil)
        not_permitted if !hb_client.is_admin?(@tsx_bot)
        if !data
          handle('admin_create_spam')
          reply_simple 'admin/create_spam'
        else
          Spam.create(
            text: @payload.text,
            status: Spam::NEW,
            bot: @tsx_bot.id
          )
          reply_simple 'admin/menu'
          admin_spam
        end
      end

      def admin_cancel_spam(data = nil)
        admin_menu
      end

      def debts
        not_permitted if !hb_client.is_admin?(@tsx_bot)
        not_permitted if !@tsx_bot.is_chief?
        @list = Bot.select(:bot__id).join(:vars, :vars__bot => :bot__id).where('(vars.sales > 0)')
        handle('clearbot')
        reply_inline 'admin/debts'
      end

      def add_to_admins
        @tsx_bot.add_operator(sget('admin_edit_client'), Client::HB_ROLE_ADMIN)
        show_user
      end

      def del_from_admins
        Team.find(client: sget('admin_edit_client').id).delete
        show_user
      end

      def show_user(data = nil)
        if !data
          user = sget('admin_edit_client')
        else
          user = Client[data]
        end
        not_permitted if user.bot != @tsx_bot.id and !user.is_admin?(@tsx_bot)
        sset('admin_edit_client', user)
        spend = user.buy_trades([Trade::FINALIZED, Trade::FINISHED, Trade::DISPUTED])
        if !data
          puts "UPDATING!!!!!!"
          reply_update 'welcome/user_page', user: user, spend: spend
        else
          reply_inline 'welcome/user_page', user: user, spend: spend
        end
      end

      def unban
        sget('admin_edit_client').update(banned: 0)
        sset('admin_edit_client', Client[sget('admin_edit_client').id])
        show_user
      end

      def ban
        sget('admin_edit_client').update(banned: 1)
        sset('admin_edit_client', Client[sget('admin_edit_client').id])
        show_user
      end

      def admin_add_cash
        not_permitted if !hb_client.is_admin?(@tsx_bot)
        handle('do_add_cash')
        reply_message "#{icon('pencil2')} Введите сумму в гривнах. Максимальная сумма *1000грн.*"
      end

      def do_add_cash(data)
        not_permitted if !hb_client.is_admin?(@tsx_bot)
        raise TSXException.new("#{icon('warning')} Максимальная сумма пополнения 1000грн.") if data.to_i > 1000
        cl = sget('admin_edit_client')
        cents = @tsx_bot.cnts(data.to_i)
        cl.cashin(cents, Client::__cash, Meth::__debt, hb_client)
        reply_message "Сумма *#{data}грн.* зачилена на счет клиенту /#{cl.id}"
        unhandle
      end

      def clearbot(data)
        b = Bot[data]
        answer_callback "Зачислено :)"
        reply_message "#{icon(@tsx_bot.icon_success)} Выплата *#{@tsx_bot.amo(b.not_paid)}* от бота *#{b.title}* зачислена."
        b.clear
      end

    end
  end
end