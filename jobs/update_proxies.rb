require_relative './requires'
logger = CronLogger.new

proxies = "185.233.200.36:9185:F38Mv1:rAhzWb
185.233.203.3:9789:F38Mv1:rAhzWb
185.233.201.113:9335:F38Mv1:rAhzWb
185.233.202.95:9614:F38Mv1:rAhzWb
193.31.102.31:9740:F38Mv1:rAhzWb
185.233.81.74:9273:ytPVcu:NnRsgv
138.59.206.59:9623:xNRK6j:1Ea69N
138.59.206.23:9175:xNRK6j:1Ea69N
138.59.206.7:9115:xNRK6j:1Ea69N
138.59.205.238:9615:xNRK6j:1Ea69N
138.59.205.197:9660:xNRK6j:1Ea69N".split("\n")

proxies.each do |proxy_string|
  logger.noise "Updating proxies from file ... "
  proxy = proxy_string.split(":")
  Prox.create(host: proxy[0], port: proxy[1], status: Prox::ONLINE, login: proxy[2], password: proxy[3], provider: "proxy6")
  logger.say("Proxy #{proxy.first}:#{proxy.last} added to proxy pool")
end

Prox::flush
DB.disconnect
logger.noise "Finished."
