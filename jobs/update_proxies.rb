require_relative './requires'
logger = CronLogger.new

proxies = "138.59.206.57:9465:g8typ5:EkLZqZ
138.59.206.24:9931:g8typ5:EkLZqZ
138.59.205.239:9093:g8typ5:EkLZqZ
138.59.205.176:9060:g8typ5:EkLZqZ
138.59.205.151:9786:g8typ5:EkLZqZ
138.59.205.110:9271:g8typ5:EkLZqZ
138.59.205.60:9771:g8typ5:EkLZqZ
138.59.205.22:9493:g8typ5:EkLZqZ
138.59.204.216:9071:g8typ5:EkLZqZ
138.59.204.196:9351:g8typ5:EkLZqZ
138.59.204.157:9237:g8typ5:EkLZqZ
138.59.204.134:9087:g8typ5:EkLZqZ
138.59.204.121:9528:g8typ5:EkLZqZ
138.59.204.11:9982:g8typ5:EkLZqZ
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
138.59.205.222:9335:g8typ5:EkLZqZ
138.59.205.174:9150:g8typ5:EkLZqZ
138.59.205.137:9064:g8typ5:EkLZqZ
138.59.205.102:9411:g8typ5:EkLZqZ
138.59.205.48:9406:g8typ5:EkLZqZ
138.59.205.18:9146:g8typ5:EkLZqZ
138.59.204.211:9821:g8typ5:EkLZqZ
138.59.204.192:9289:g8typ5:EkLZqZ
138.59.204.154:9294:g8typ5:EkLZqZ
138.59.204.132:9201:g8typ5:EkLZqZ
138.59.204.118:9420:g8typ5:EkLZqZ
138.59.204.38:9256:g8typ5:EkLZqZ
138.59.204.17:9983:g8typ5:EkLZqZ
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
