require_relative './requires'
require 'colorize'
require 'watir'

logger = CronLogger.new
# DB.logger = logger
Selenium::WebDriver::Firefox::Binary.path='/usr/bin/firefox'
Selenium::WebDriver.logger.level = :debug

DB.fetch('select * from wallet where active = 1 or secondary = 1') do |wallet|

  bot = Bot[wallet[:bot]]
  next if bot.checkeasy != 1
  puts "Processing bot:  #{bot.title} / wallet: #{wallet[:wallet]}".colorize(:blue)
  proxy = Prox.get_active
  proxy_object = Selenium::WebDriver::Proxy.new(
      http: "#{proxy.host}:#{proxy.port}",
      ssl:  "#{proxy.host}:#{proxy.port}"
  )
  dir = "/code/wallets/#{bot.id}"
  wallet_dir = "#{dir}/#{wallet[:keeper]}"
  Dir.mkdir(dir) unless File.exists?(dir)
  Dir.mkdir(wallet_dir) unless File.exists?(wallet_dir)

  profile = Selenium::WebDriver::Firefox::Profile.new
  profile['browser.download.dir'] = dir
  profile['browser.download.folderList'] = 2
  profile['browser.helperApps.neverAsk.saveToDisk'] = "text/csv,application/zip,application/octet-stream,image/jpeg,application/vnd.ms-outlook,text/html,application/pdf"
  profile['browser.helperApps.alwaysAsk.force'] = "false"

  browser = Watir::Browser.new(
      :firefox,
      headless: true,
      profile: profile,
      proxy: proxy_object
  )

  browser.goto 'https://easypay.ua/'
  puts "Going to EasyPay.ua"
  sleep(15)
  browser.button(:value => "Войти").click
  browser.input(:id => 'sign-in-phone').send_keys('380999714391')
  browser.input(:id => 'password').send_keys('ZzZ6085249')
  browser.button(:class => ['button', 'relative']).click
  puts "Logged in"
  sleep(20)
  browser.goto 'https://easypay.ua/profile/wallets'
  puts "Went to wallets"
  browser.button(:class => 'dots').click
  browser.a(text: 'История').click
  sleep(20)
  browser.scroll.to [0, 200]
  puts "Scrolled to the middle of the screen"
  browser.span(:class => ['profile-history__filter-more', 'ng-star-inserted']).wait_until(&:present?).click
  puts "Trying to save history"
  sleep(50)
  browser.close

end

DB.disconnect
logger.noise "Finished."
