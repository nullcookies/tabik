require 'telegram/bot'
require 'telegram/bot/exceptions'
require 'net/http/persistent'
require 'raven'
require 'colorize'

class TABTimeout < Timeout::Error; end
class BotController < TSX::ApplicationController

  def brec(bot, action, params = '', cl)
    recd('bot', cl, bot, action, params)
  end

  def recd(init = 'unknown', cl, b, action, params)
    Rec.create(
        initiator: init.to_s,
        client: cl.nil? ? '' : cl.id,
        bot: b.nil? ? '' : b.id,
        action: action,
        params: params,
        logged: Time.now
    )
  end

  post '/hook/*' do
  	# [200, {}, ["----------------------- SUCCESS"]]
	  # # return
    begin
      mess = ''
      token = params[:splat].first
      @bot = Telegram::Bot::Client.new(token)
      @tsx_bot = Bot.find(token: token)
      @tsx_host = request.host
      parse_update(request.body)
      setup_sessa
      raise TSX::TSXException.new("#{icon('warning')} Возникла проблема при регистрации вашего никнейма. Обратитесь в поддержку.") if !hb_client
      raise TSX::TSXException.new("#{icon('warning')} Бот на техобслуживании.") if @tsx_bot.inactive?
      raise TSX::TSXException.new("#{icon('warning')} Вы забанены. Удачи.") if hb_client.banned?
      show_typing
      call_handler
      log_update
    rescue Telegram::Bot::Exceptions::ResponseError => re
      hb_client.status = Client::CLIENT_BANNED
      hb_client.save
      mess = re.message
      puts mess.colorize(:red)
    rescue TSX::TSXException => ex
      reply_message ex.message
    rescue => ex
      puts ex.message.colorize(:red)
      puts ex.backtrace.join("\n\t")
      puts mess.colorize(:red)
    end
    [200, {}, ["----------------------- SUCCESS"]]
  end

  def no_command
    reply_simple 'errors/no_command'
  end

  def no_such_view view
    reply_simple 'errors/no_such_view', view_file: view
  end

end
