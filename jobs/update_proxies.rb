require_relative './requires'
logger = CronLogger.new

proxies = "45.93.69.35:8000:c6VJBy:LJWLZa
185.233.81.74:9273:ytPVcu:NnRsgv
138.59.206.59:9623:xNRK6j:1Ea69N
138.59.206.38:9124:xNRK6j:1Ea69N
138.59.206.23:9175:xNRK6j:1Ea69N
138.59.206.7:9115:xNRK6j:1Ea69N
138.59.205.238:9615:xNRK6j:1Ea69N
138.59.205.224:9415:xNRK6j:1Ea69N
138.59.205.197:9660:xNRK6j:1Ea69N
138.59.205.176:9926:xNRK6j:1Ea69N
138.59.205.162:9801:xNRK6j:1Ea69N
138.59.205.148:9825:xNRK6j:1Ea69N
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
