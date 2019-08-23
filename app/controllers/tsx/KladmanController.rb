require 'geocoder'
module TSX
  module Controllers
    module Kladman

      def admin_menu
        not_permitted if !hb_client.is_admin?(@tsx_bot) and !hb_client.is_operator?(@tsx_bot)
        reply_simple 'admin/menu'
        reply_inline 'admin/botstat'
      end

      def add_kladman(data = nil)
        not_permitted if !hb_client.is_admin?(@tsx_bot)
        handle('add_kladman')
        if !data
          reply_message "#{icon('pencil2')} Введите номер клиента кладчика."
        else
          raise TSX::TSXException.new("#{icon('no_entry_sign')} Нет такого номера клиента.") if Client[data.to_i].nil?
          @tsx_bot.add_operator(Client[data.to_i], Client::HB_ROLE_KLADMAN)
          reply_message "#{icon('ok')} Кладчик добавлен."
        end
      end


    end
  end
end