require_relative './requires'
require 'colorize'
require 'watir'

logger = CronLogger.new
# DB.logger = logger
Selenium::WebDriver::Firefox::Binary.path='/usr/bin/firefox'
# Selenium::WebDriver.logger.level = :debug

DB.fetch("select * from wallet where bot = #{ARGV[0]} and (active = 1 or secondary = 1)") do |wallet|

  bot = Bot[wallet[:bot]]
  next if bot.checkeasy != 1
  puts "Processing bot:  #{bot.title} / wallet: #{wallet[:wallet]}".colorize(:blue)
  proxy = Prox.get_active
  # proxy_object = Selenium::WebDriver::Proxy.new(
  #     http: "#{proxy.host}:#{proxy.port}",
  #     ssl:  "#{proxy.host}:#{proxy.port}"
  # )
  browser = Watir::Browser.new(
      :firefox,
      headless: false
  )

  browser.window.resize_to(800, 600)

  browser.goto 'https://easypay.ua/'
  puts "Trying to login with login/password: #{wallet[:phone]}/#{wallet[:password]}"
  sleep(15)
  browser.button(:value => "Войти").click
  browser.input(:id => 'sign-in-phone').send_keys(wallet[:phone])
  browser.input(:id => 'password').send_keys(wallet[:password])
  browser.button(:class => ['button', 'relative']).click
  puts "Logged in"
  sleep(10)
  browser.goto 'https://easypay.ua/profile/wallets'
  puts "Went to wallets"
  browser.button(:class => 'dots').wait_until(&:present?)
  browser.button(:class => 'dots').click
  if browser.a(text: 'История').present?
    browser.a(text: 'История').click
  elsif browser.a(text: 'Історія').present?
    browser.a(text: 'Історія').click
  else
    puts "PROBLEM WITH LOGIN".colorize(:red)
    next
  end
  sleep(20)
  3.times {
    browser.scroll.to :bottom
    browser.div(:class => ['button', 'regular', 'expanded']).click
    sleep(5)
  }
  puts "Deleting old records"
  Easypay.where(bot: bot.id).delete
  puts "Saving payments to database"
  cnt = 0
  browser.table.rows.each do |row|
    cnt += 1
    next if cnt == 1
    row_array = Array.new
    row.cells.each do |cell|
      row_array << cell.text
    end

    next if row_array[1] == "Пополнение банковской карты VISA / MasterCard"

    if Date.parse(row_array[6]) < Date.today - 1.days
      puts "TODAY IS FINISHED. NOT SAVING THE REST".red
      break
    end

    txin = row_array[0]
    amount = row_array[3]
    time = row_array[6].chars.last(5).join
    code = "#{txin}#{time}"

    puts "ID: #{txin}"
    puts "amount: #{amount}"
    puts "time: #{time}"
    puts "CODE IS: #{code}".colorize(:yellow)
    puts "---"

    p = Easypay.where("bot = #{bot.id} and wallet = '#{wallet[:id]}' and code = '#{code}' and amount = '#{amount}'")
    if p.count == 0
      puts "Adding payment #{amount} with code #{code}".colorize(:blue)
      Easypay.create(wallet: wallet[:id], bot: bot.id, code: code, amount: amount)
    else
      puts "Code #{code} already saved in database"
    end

  end
  browser.close

end

DB.disconnect
logger.noise "Finished."
