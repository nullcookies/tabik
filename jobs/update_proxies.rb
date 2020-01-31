require_relative './requires'
logger = CronLogger.new

proxies = "107.152.153.105:9030:VzTTMv:tBXxPH
104.227.102.208:9081:VzTTMv:tBXxPH
104.227.96.138:9365:VzTTMv:tBXxPH
104.227.102.171:9608:VzTTMv:tBXxPH
104.227.96.224:9159:VzTTMv:tBXxPH
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
