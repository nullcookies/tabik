require_relative './requires'
logger = CronLogger.new

logger.noise "Scheduled messages sending ... "
mess = Spam.find(auto: 1)
if mess.nil?
  logger.say "Nothing to send"
  exit
end
diff = (Time.now - mess.sent) / 60
to_wait = mess.period - diff
if to_wait > 0
  logger.say "It's not time to send yet."
  logger.say "We need to wait #{to_wait} minutes"
  exit
end
mess.sent = Time.now
mess.save
tsx_bot = Bot[mess.bot]
from_bot = Telegram::Bot::Api.new(tsx_bot.token)
logger.noise "Message from @#{tsx_bot.tele}"
logger.noise "Recipients: #{I18n::t("spam.kinds.#{mess.kind}")}"
clients = Client.where(bot: mess.bot)
logger.noise "Recipient count: #{clients.count}"
clients.each do |c|
  begin
    from_b = Bot[c.bot]
    logger._say "Sending to #{from_b.tele} / #{c.username} ... "
    from_bot = Telegram::Bot::Api.new(from_b.token)
    if mess.kind == Spam::BOT_REFERALS
      v = render_md('admin/referal_optin', locals: {send_from: from_b, send_to: c, seller_bot: from_b})
      from_bot.send_message(
          chat_id: c.tele,
          text: v.body,
          parse_mode: :markdown
      )
    else
      from_bot.send_message(
          chat_id: c.tele,
          text: mess.text,
          parse_mode: :markdown
      )
    end
    logger.answer('success', :green)
    [200, {}, ['MESSAGE SENT']]
  rescue Telegram::Bot::Exceptions::ResponseError => e
    logger.answer('user blocked bot', :red)
    # c.role = Client::HB_ROLE_ARCHIVED
    c.save
    [200, {}, ['FAILED TO SEND']]
  end
end

DB.disconnect
logger.noise "Finished."