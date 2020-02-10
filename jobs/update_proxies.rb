require_relative './requires'
logger = CronLogger.new

proxies = "213.166.75.233:9905:TG48Yg:9xR0on
213.166.72.85:9155:TG48Yg:9xR0on
213.166.75.80:9092:TG48Yg:9xR0on
213.166.74.220:9379:TG48Yg:9xR0on
213.166.74.37:9439:TG48Yg:9xR0on
213.166.75.58:9973:TG48Yg:9xR0on
213.166.75.149:9933:TG48Yg:9xR0on
213.166.73.91:9164:TG48Yg:9xR0on
213.166.74.48:9851:TG48Yg:9xR0on
213.166.72.125:9123:TG48Yg:9xR0on
213.166.73.63:9778:TG48Yg:9xR0on
213.166.74.189:9069:TG48Yg:9xR0on
213.166.73.85:9589:TG48Yg:9xR0on
213.166.75.44:9876:TG48Yg:9xR0on
213.166.75.84:9766:TG48Yg:9xR0on
213.166.72.199:9562:TG48Yg:9xR0on
213.166.74.97:9400:TG48Yg:9xR0on
213.166.72.27:9171:TG48Yg:9xR0on
213.166.73.160:9426:TG48Yg:9xR0on
213.166.73.22:9175:TG48Yg:9xR0on
213.166.72.12:9474:TG48Yg:9xR0on
185.232.169.39:9944:w6n5c5:78rWQB
185.232.171.3:9689:w6n5c5:78rWQB
185.232.171.80:9676:w6n5c5:78rWQB".split("\n")

proxies.each do |proxy_string|
  logger.noise "Updating proxies from file ... "
  proxy = proxy_string.split(":")
  Prox.create(host: proxy[0], port: proxy[1], status: Prox::ONLINE, login: proxy[2], password: proxy[3], provider: "proxy6")
  logger.say("Proxy #{proxy.first}:#{proxy.last} added to proxy pool")
end

Prox.flush
DB.disconnect
logger.noise "Finished."
