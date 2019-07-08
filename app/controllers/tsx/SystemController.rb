require 'geocoder'
module TSX
  module Controllers
    module System

      def ask_token(data = nil)
        handle('ask_token')
        if !data
          reply_message "#{icon('pencil2')} Введите Telegram API токен."
        else
          begin
            bot_name = sget('meine_new_bot')
            hook = 'https://tabik98.herokuapp.com/hook/'
            token = @payload.text
            url = hook + token
            puts "Webhook: #{url}"
            from_bot = Telegram::Bot::Api.new(token)
            from_bot.setWebhook(url: url)
            puts from_bot.getWebhookInfo.inspect.colorize(:cyan)
            newbot = register_bot(bot_name, token)
            reply_message "#{icon('white_check_mark')} Бот #{newbot.nickname_md} в работе."
          rescue Telegram::Bot::Exceptions::ResponseError => ex
            raise TSXException.new("#{icon('warning')} `#{ex.message}`")
          end
        end
      end

      def bot_admin(data = nil)
        handle('bot_admin')
        if !data
          reply_message "#{icon('pencil2')} Введите имя бота."
        else
          sset('meine_bot', data)
          ask_client_id
        end
      end

      def ask_client_id(data = nil)
        handle('ask_client_id')
        if !data
          reply_message "#{icon('pencil2')} Введите номер клиента."
        else
          bot = Bot[sget('meine_bot')]
          client = Client[data]
          bot.add_operator(client, Client::HB_ROLE_ADMIN)
          reply_message "#{icon('white_check_mark')} Админ добавлен."
        end
      end

      def new_bot(data = nil)
        handle('new_bot')
        if !data
          reply_message "#{icon('pencil2')} Введите имя бота."
        else
          sset('meine_new_bot', data)
          ask_token
        end
      end

      def register_bot(data, token)
        botname = data
        if Bot.find(tele: "#{botname}").nil?
          bene = Client.create(
              tele: '1',
              username: "__bot_#{botname}"
          )
          under = data.include?('_') ? 1 : 0
          bot = Bot.create(
              tele: botname,
              token: token,
              title: botname,
              underscored_name: under,
              serp_type: Bot::SERP_PRODUCT_FIRST,
              web_klad: 0,
              status: Bot::ACTIVE,
              activated: 0
          )
          bot.set_var('country', 2)
          Team.create(
              bot: bot.id,
              client: bene.id,
              role: Client::HB_ROLE_SELLER
          )
          unhandle
          return bot
        else
          TSXException.new("#{icon('warning')} Такой бот уже есть.")
        end
      end

    end
  end
end