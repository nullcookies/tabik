require_relative './requires'
require 'colorize'
require 'watir'

logger = CronLogger.new
# DB.logger = logger

bot = Bot[548]

proxy_object = Selenium::WebDriver::Proxy.new(
    http: '104.227.102.56:9602',
    ssl:  '104.227.102.56:9602'
)

profile = Selenium::WebDriver::Firefox::Profile.new
profile['browser.download.dir'] = '/home/nickolas/Downloads/w/'
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
sleep(10)
browser.button(:value => "Войти").click
browser.input(:id => 'sign-in-phone').send_keys('380999714391')
browser.input(:id => 'password').send_keys('ZzZ6085249')
browser.button(:class => ['button', 'relative']).click
puts "Logged in"
sleep(5)
browser.goto 'https://easypay.ua/profile/wallets'
puts "Went to wallets"
browser.button(:class => 'dots').click
browser.a(text: 'История').click
browser.scroll.to [0, 200]
puts "Scrolled to the middle of the screen"
browser.span(:class => ['profile-history__filter-more', 'ng-star-inserted']).wait_until(&:present?).click
puts "Trying to save history"
sleep(30)
browser.close


DB.disconnect
logger.noise "Finished."
