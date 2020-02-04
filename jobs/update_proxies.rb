require_relative './requires'
logger = CronLogger.new

proxies = "107.152.153.66:9814:8M4CyU:sGoWfT
138.128.19.137:9275:8M4CyU:sGoWfT
138.128.19.204:9804:8M4CyU:sGoWfT
104.227.102.234:9845:8M4CyU:sGoWfT
104.227.102.8:9310:8M4CyU:sGoWfT
138.128.19.102:9898:8M4CyU:sGoWfT
104.227.102.35:9972:8M4CyU:sGoWfT
107.152.153.175:9997:8M4CyU:sGoWfT
107.152.153.25:9825:8M4CyU:sGoWfT
104.227.96.103:9927:8M4CyU:sGoWfT
107.152.153.62:9611:8M4CyU:sGoWfT
138.128.19.253:9654:8M4CyU:sGoWfT
138.128.19.214:9149:8M4CyU:sGoWfT
104.227.102.227:9893:8M4CyU:sGoWfT
138.128.19.224:9450:8M4CyU:sGoWfT
107.152.153.200:9411:8M4CyU:sGoWfT
107.152.153.232:9300:8M4CyU:sGoWfT
104.227.96.191:9160:8M4CyU:sGoWfT
138.128.19.24:9399:8M4CyU:sGoWfT
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
