require_relative './requires'
require 'colorize'

logger = CronLogger.new
DB.logger = logger

def get_today_transactions(bot)
  qiwi = Qiwi.find(bot: bot.id, active: Qiwi::ACTIVE)
  today = Date.today.strftime('Y-m-d')
  yest = Date.yesterday.strftime('Y-m-d')
  puts qiwi.inspect
  puts "CHECKIN TRANSACTIONS"
  url = "https://edge.qiwi.com/payment-history/v2/persons/#{qiwi.phone}/payments?rows=50&startDate=2019-07-01T00%3A00%3A00%2B03%3A00&endDate=2019-09-30T23%3A59%3A59%2B03%3A00"
  puts url
  conn = Faraday.new
  res = conn.get do |req|
    req.url url
    req.headers['Accept'] = "application/json"
    req.headers['Authorization'] = "Bearer #{qiwi.token}"
  end
  data = JSON.parse(res.body)['data']
  data.each do |t|
    if !t['comment'].nil?
      puts "Payment with amount #{t['sum']['amount']} found with comment: #{t['comment']}"
      Easypay.create(wallet: qiwi.id, bot: bot.id, code: t['comment'], amount: t['sum']['amount'])
    end
  end
end

threads = []
Bot.select(:bot__id).join(:vars, :vars__bot => :bot__id).where(:bot__listed => 1, :bot__status => 1, :vars__country => 3).each do |bot|
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
