require_relative './requires'
logger = CronLogger.new

proxies = "193.31.101.57:9913:ucfxYN:XdQf22
193.31.102.94:9189:ucfxYN:XdQf22
193.31.103.236:9812:ucfxYN:XdQf22
212.81.38.251:9376:ucfxYN:XdQf22
212.81.36.98:9108:ucfxYN:XdQf22
212.81.37.92:9975:ucfxYN:XdQf22
212.81.38.215:9846:ucfxYN:XdQf22
".split("\n")

proxies.each do |proxy_string|
  logger.noise "Updating proxies from file ... "
  proxy = proxy_string.split(":")
  Prox.create(host: proxy[0], port: proxy[1], status: Prox::ONLINE, login: proxy[2], password: proxy[3], provider: "proxy6")
  logger.say("Proxy #{proxy.first}:#{proxy.last} added to proxy pool")
end

Prox::flush
DB.disconnect
logger.noise "Finished."
