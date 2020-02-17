require_relative './requires'
logger = CronLogger.new

proxies = "138.59.205.60:9771:g8typ5:EkLZqZ
138.59.205.22:9493:g8typ5:EkLZqZ
138.59.204.216:9071:g8typ5:EkLZqZ
104.227.96.224:9159:VzTTMv:tBXxPH
138.59.206.57:9465:g8typ5:EkLZqZ
138.59.206.24:9931:g8typ5:EkLZqZ
138.59.205.239:9093:g8typ5:EkLZqZ
138.59.204.44:9269:g8typ5:EkLZqZ
138.59.207.231:9924:g8typ5:EkLZqZ
138.59.207.180:9823:g8typ5:EkLZqZ
138.59.207.152:9783:g8typ5:EkLZqZ
138.59.207.86:9995:g8typ5:EkLZqZ
138.59.207.73:9587:g8typ5:EkLZqZ
138.59.207.18:9392:g8typ5:EkLZqZ
138.59.206.223:9688:g8typ5:EkLZqZ
138.59.206.157:9609:g8typ5:EkLZqZ
138.59.206.138:9284:g8typ5:EkLZqZ
138.59.206.75:9392:g8typ5:EkLZqZ
138.59.206.52:9918:g8typ5:EkLZqZ
138.59.206.11:9668:g8typ5:EkLZqZ
213.166.73.144:9063:TG48Yg:9xR0on
213.166.75.214:9118:TG48Yg:9xR0on
213.166.75.5:9115:TG48Yg:9xR0on
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
