require_relative './requires'
require 'colorize'

logger = CronLogger.new
DB.logger = logger

def get_today_transactions(bot)
  Easypay.where(bot: bot.id).delete
  qiwi = Qiwi.find(bot: bot.id, active: Qiwi::ACTIVE)
  today = Date.today.strftime('%Y-%m-%d')
  yest = Date.yesterday.strftime('%Y-%m-%d')
  puts qiwi.inspect
  puts today
  puts yest

  puts "CHECKIN TRANSACTIONS"
  url = "https://edge.qiwi.com/payment-history/v2/persons/#{qiwi.phone}/payments?rows=50&startDate=#{yest}T00%3A00%3A00%2B03%3A00&endDate=#{today}T23%3A59%3A59%2B03%3A00"
  puts url
  conn = Faraday.new(url: url, proxy: "https://#{qiwi.proxy}")
  res = conn.get do |req|
    req.headers['Accept'] = "application/json"
    req.headers['Authorization'] = "Bearer #{qiwi.token}"
  end
  data = JSON.parse(res.body)['data']
  data.each do |t|
    if !t['comment'].nil?
      cl = Client[t['comment']]
      if !cl.nil?
        paid = Ledger.where(details: "#{t['txnId']}")
        if paid.count == 0
          begin
            Ledger.create(debit: Client::__qiwi.id, credit: cl.id, amount: bot.cnts(t['sum']['amount']), status: Ledger::ACTIVE, created: Time.now, details: "#{t['txnId']}")
          rescue => e
            puts e.message
          end
          puts "saying to client tele: #{cl.tele}"
          from_bot = Telegram::Bot::Api.new(bot.token)
          from_bot.send_message(
              chat_id: cl.tele,
              text: "🤑 Ваш счет пополнен на #{t['sum']['amount']} рублей!",
              parse_mode: :markdown
          )
        end
      else
        puts "Payment with amount #{t['sum']['amount']} found with comment: #{t['comment']}".colorize(:blue)
        Easypay.create(wallet: qiwi.id, bot: bot.id, code: t['comment'], amount: t['sum']['amount'])
      end
    end
  end
end

threads = []
Bot.select(:bot__id).join(:vars, :vars__bot => :bot__id).where(:bot__status => 1, :vars__country => 3).each do |bot|
  threads << Thread.new {
    b = Bot[bot[:id]]
    puts "#{b.tele}"
    get_today_transactions(b)
  }
end

ThreadsWait.all_waits(threads) do |t|
  STDERR.puts "Thread #{t} has terminated."
end

DB.disconnect
logger.noise "Finished."
