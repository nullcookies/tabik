require_relative './requires'
logger = CronLogger.new

proxies = "138.59.204.196:9351:g8typ5:EkLZqZ
138.59.204.157:9237:g8typ5:EkLZqZ
138.59.204.134:9087:g8typ5:EkLZqZ
138.59.204.121:9528:g8typ5:EkLZqZ
138.59.204.11:9982:g8typ5:EkLZqZ
104.227.102.171:9608:VzTTMv:tBXxPH
213.166.74.31:9700:TG48Yg:9xR0on
213.166.75.246:9125:TG48Yg:9xR0on
213.166.72.33:9999:TG48Yg:9xR0on
193.31.100.158:9520:fcP7WS:BGVY6Q
193.31.101.35:9644:fcP7WS:BGVY6Q
193.31.101.40:9617:fcP7WS:BGVY6Q
193.31.102.207:9186:fcP7WS:BGVY6Q
138.59.205.18:9146:g8typ5:EkLZqZ
138.59.204.211:9821:g8typ5:EkLZqZ
138.59.204.192:9289:g8typ5:EkLZqZ
138.59.204.154:9294:g8typ5:EkLZqZ
138.59.204.132:9201:g8typ5:EkLZqZ
138.59.204.118:9420:g8typ5:EkLZqZ
138.59.204.38:9256:g8typ5:EkLZqZ
138.59.204.17:9983:g8typ5:EkLZqZ
213.166.72.39:9556:TG48Yg:9xR0on
213.166.72.226:9725:TG48Yg:9xR0on
213.166.73.67:9362:TG48Yg:9xR0on
213.166.74.13:9966:TG48Yg:9xR0on
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
