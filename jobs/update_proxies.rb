require_relative './requires'
logger = CronLogger.new

proxies = "185.232.169.39:9944:w6n5c5:78rWQB
185.232.171.3:9689:w6n5c5:78rWQB
185.232.171.80:9676:w6n5c5:78rWQB
".split("\n")

proxies.each do |proxy_string|
  logger.noise "Updating proxies from file ... "
  proxy = proxy_string.split(":")
  Prox.create(host: proxy[0], port: proxy[1], status: Prox::ONLINE, login: proxy[2], password: proxy[3], provider: "proxy6")
  logger.say("Proxy #{proxy.first}:#{proxy.last} added to proxy pool")
end

Prox.flush
DB.disconnect
logger.noise "Finished."
