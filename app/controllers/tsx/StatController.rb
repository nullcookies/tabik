module TSX
  module Controllers
    module Stat

      def stat_choose_city(data = nil)
        not_permitted if !hb_client.is_admin?(@tsx_bot)
        handle('stat_choose_product')
        cities = Client::cities_by_country(Country.find(code: 'UA'), @tsx_bot.id)
        reply_update 'admin/stat/choose_city', cities: cities
      end

      def stat_choose_product(data = nil)
        not_permitted if !hb_client.is_admin?(@tsx_bot)
        handle('stat_show_stat')
        if data
          city = City[data]
          sset('stat_city', city)
        else
          city = sget('stat_city')
        end
        products = Client::products_by_city(city, @tsx_bot.id)
        reply_update 'admin/stat/choose_product', products: products, city: city
      end

      def stat_show_stat(data = nil)
        @product = Product[data]
        @city = sget('stat_city')
        @districts = Client::districts_by_city_and_product(@product, @tsx_bot.id, @city)
        rest = rest_string(@product, @districts)
        reply_update 'admin/stat/show_rest', rest: rest, product: @product, city: @city
      end

      def back_to_products(data = nil)
        reply_update 'admin/botstat'
      end

      def stat_last_ten(data = nil)
        last_items = Item.
            where(status: [Item::SOLD], bot: @tsx_bot.id).
            order(Sequel.desc(:item__sold)).limit(10)
        last = last_ten(last_items)
        reply_update 'admin/stat/last_ten', last: last
      end

      def back_to_stat(data = nil)
        reply_update 'admin/botstat'
      end

    end
  end
end