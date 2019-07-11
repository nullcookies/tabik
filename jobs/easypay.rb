require_relative './requires'
require 'colorize'

DB = Sequel.connect('postgres://aijsnlqeczrjde:0841bee8fe4b53474a43e815c5b19952c74b7c8b428bacc73943388d678a274d@ec2-174-129-226-232.compute-1.amazonaws.com:5432/d2i3n5oehr5m5n')

logger = CronLogger.new
# DB.logger = logger

def easypay_login(bot)
  i = 0
  num = 3
  logged = false
  while i < num  do
    i += 1
    puts "#{bot.title}:  Trying to solve reCaptcha #{i} try ..."
    client = AntiCaptcha.new('7766d57328e2d81745bc87bcf2d6f765')
    options = {
        website_key: '6LefhCUTAAAAAOQiMPYspmagWsoVyHyTBFyafCFb',
        website_url: 'https://partners.easypay.ua/auth/signin'
    }
    begin
      solution = client.decode_nocaptcha!(options)
      resp = solution.g_recaptcha_response
    rescue AntiCaptcha::Error => ex
      puts "#{bot.title}: AntiCaptcha timeout. Next try.".red
      puts ex.message
      next
    end
    puts "#{bot.title}: Got AntiCaptcha endresponse: #{resp}".green
    web = Mechanize.new
    web.keep_alive = false
    web.read_timeout = 10
    web.open_timeout = 10
    web.user_agent = "Mozilla/5.0 Gecko/20101203 Firefox/3.6.13"
    proxy = Prox.get_active
    web.agent.set_proxy(proxy.host, proxy.port, proxy.login, proxy.password)
    puts "#{bot.title}: Retrieving main page".white
    easy = web.get('https://partners.easypay.ua/auth/signin')
    login = bot.payment_option('login', Meth::__easypay)
    password = bot.payment_option('password', Meth::__easypay)
    puts "#{bot.title}: Trying to login with #{login}/#{password}".white
    begin
      # exit
      logged = easy.form do |f|
        f.login = login.to_s
        f.password = password.to_s
        f.gresponse = resp
      end.submit
    rescue => e
      puts "#{bot.title}: Not logged to Easypay.".colorize(:red)
      puts e.message
      puts e.backtrace.join("\t\n")
      next
    end
    if logged.title != "EasyPay - Вход в систему"
      puts "#{bot.title}: Logged to Easypay.".colorize(:green)
      logged = true
      return web
    else
      puts "#{bot.title}: Not logged with response. Next try.".colorize(:red)
    end
  end
  false if !logged
end

def easypay_login_nocaptcha(bot)
  i = 0
  num = 5
  logged = false
  web = Mechanize.new
  web.keep_alive = false
  web.read_timeout = 10
  web.open_timeout = 10
  web.user_agent = "Mozilla/5.0 Gecko/20101203 Firefox/3.6.13"
  proxy = Prox.get_active
  web.agent.set_proxy(proxy.host, proxy.port, proxy.login, proxy.password)
  puts "#{bot.title}: Retrieving main page".white
  easy = web.get('https://partners.easypay.ua/auth/signin')
  login = bot.payment_option('login', Meth::__easypay)
  password = bot.payment_option('password', Meth::__easypay)
  puts "#{bot.title}: Trying to login with #{login}/#{password}".white
  begin
    # exit
    logged = easy.form do |f|
      f.login = login.to_s
      f.password = password.to_s
      # f.gresponse = resp
    end.submit
  rescue => e
    puts "#{bot.title}: Not logged to Easypay.".colorize(:red)
    return false
  end
  if logged.title != "EasyPay - Вход в систему"
    puts "#{bot.title}: Logged to Easypay.".colorize(:green)
    logged = true
    return web
  else
    puts "#{bot.title}: Not logged with response. Next try.".colorize(:red)
  end
  false if !logged
end

def get_today_transactions(web, bot)
  puts "#{bot.title}: Checking all payments for the current day".white
  wallet = bot.payment_option('wallet', Meth::__easypay)
  st = web.get("https://partners.easypay.ua/wallets/buildreport?walletId=#{wallet}&month=#{Date.today.month}&year=#{Date.today.year}")
  tab = st.search(".//table[@class='table-layout']").children
  puts "#{bot.title}: TAB COUNT: #{tab.count}"
  Easypay.where(bot: bot.id).delete
  tab.each do |d|
    i = 1
    to_match = ''
    amount = ''
    d.children.each do |td, td2|
      puts td.inspect
      if i == 2
        to_match << td.inner_text
      end
      if i == 6
         amount = td.inner_text
      end
      if i == 10
        to_match << td.inner_text
      end
      i = i + 1
    end
    puts to_match.red
    matched = "#{to_match}".match(/.*(\d{2}:\d{2})\D*(\d+)/)
    if matched
      dat =  "#{to_match}".match(/(\d{2}.\d{2}.\d{4}).*/)
      if Date.parse(dat.captures.first) < Date.today - 1.days
        puts "TODAY IS FINISHED. NOT SAVING THE REST".red
        return false
      end
      code = "#{matched.captures.first}#{matched.captures.last}"
      wallet = Wallet.find(bot: bot.id, active: 1)
      p = Easypay.where("bot = #{bot.id} and wallet = '#{wallet.id}' and code = '#{code}' and amount = '#{amount}'")
      if p.count == 0
        puts "Adding payment #{amount} with code #{code}".colorize(:blue)
        Easypay.create(wallet: wallet.id, bot: bot.id, code: code, amount: amount)
      else
        puts "Code #{code} already saved in database"
      end
    else
      puts "NOT MATCHED".red
    end
  end
end

threads = []
Bot.where(listed: 1, status: 1).each do |bot|
  threads << Thread.new {
    begin
      puts "BOT: #{bot.title}".blue
      web = easypay_login(bot)
      if !web
        puts "Was not logged #{bot.title}".colorize(:red)
      else
        get_today_transactions(web, bot)
      end
    rescue => e
      puts e.message
      puts e.backtrace.join("\t\n")
    end
  }
end
ThreadsWait.all_waits(threads) do |t|
  STDERR.puts "Thread #{t} has terminated."
end

DB.disconnect
logger.noise "Finished."
