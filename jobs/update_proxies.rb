require_relative './requires'
logger = CronLogger.new

proxies = "193.203.48.51:34870:WPKZEuwjii:9xeZbwULPU
193.203.48.122:34870:WPKZEuwjii:9xeZbwULPU
91.226.212.24:34870:WPKZEuwjii:9xeZbwULPU
91.217.91.17:34870:WPKZEuwjii:9xeZbwULPU
91.217.90.25:34870:WPKZEuwjii:9xeZbwULPU
91.226.212.232:34870:WPKZEuwjii:9xeZbwULPU
2.57.150.250:34870:WPKZEuwjii:9xeZbwULPU
2.57.150.245:34870:WPKZEuwjii:9xeZbwULPU
2.56.136.102:34870:WPKZEuwjii:9xeZbwULPU
2.56.136.130:34870:WPKZEuwjii:9xeZbwULPU".split("\n")

proxies.each do |proxy_string|
  logger.noise "Updating proxies from file ... "
  proxy = proxy_string.split(":")
  Prox.create(host: proxy[0], port: proxy[1], status: Prox::ONLINE, login: proxy[2], password: proxy[3], provider: "proxy6")
  logger.say("Proxy #{proxy.first}:#{proxy.last} added to proxy pool")
end

Prox::flush
DB.disconnect
logger.noise "Finished."
