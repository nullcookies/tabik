require_relative './requires'
logger = CronLogger.new

proxies = "193.228.55.157:8000:Fz9ohe:PWYW7Z
193.228.55.54:8000:Fz9ohe:PWYW7Z
193.228.54.219:8000:Fz9ohe:PWYW7Z
193.228.55.51:8000:Fz9ohe:PWYW7Z
193.228.54.155:8000:Fz9ohe:PWYW7Z
193.228.54.134:8000:Fz9ohe:PWYW7Z
193.228.55.77:8000:Fz9ohe:PWYW7Z
193.228.54.240:8000:Fz9ohe:PWYW7Z
193.228.55.134:8000:Fz9ohe:PWYW7Z
193.228.55.236:8000:Fz9ohe:PWYW7Z
185.167.161.179:8000:kHPrRm:tMorSX
185.157.79.19:8000:kHPrRm:tMorSX
185.157.79.91:8000:kHPrRm:tMorSX
185.157.78.99:8000:kHPrRm:tMorSX
185.167.162.36:8000:kHPrRm:tMorSX
176.107.185.207:8000:kHPrRm:tMorSX
185.157.77.128:8000:kHPrRm:tMorSX
185.247.208.221:8000:kHPrRm:tMorSX
193.228.53.159:8000:kHPrRm:tMorSX
91.229.78.152:8000:kHPrRm:tMorSX
193.42.106.224:8000:B2zRWD:KP1jz4
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
