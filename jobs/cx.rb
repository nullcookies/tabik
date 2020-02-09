require_relative './requires'
logger = CronLogger.new

logger.noise "Checking new stories ... "
stories = eval(Faraday.get('https://hacker-news.firebaseio.com/v0/newstories.json?print=pretty').body)
stories.each do |story|
  puts "https://hacker-news.firebaseio.com/v0/item/#{story}.json?print=pretty"
  story_body = Faraday.get("https://hacker-news.firebaseio.com/v0/item/#{story}.json?print=pretty").body
  res = JSON.parse(story_body)
  url = res['url']
  next if url.nil?
  puts "Story URL: #{url}"
  matched = url.match(/https:\/\/github.com\/(\w*\/\w*)/)
  if !matched.nil?
    repo = matched.captures.first
    puts "Got GitHub repo in the story: #{repo}".colorize(:green)
    uri = URI.parse("https://www.codexia.org/submit?platform=github&coordinates=#{repo}")
    puts uri
    request = Net::HTTP::Post.new(uri)
    request["X-Codexia-Token"] = "6P5M3zTsZ5dkh3Gjzr4pFV4AQ2FWjbiqFWJoC1pUm6QRCgG2LpDKZC3bWmUzzGAo75"
    req_options = { use_ssl: uri.scheme == "https" }
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    puts response
    break
  end
end
DB.disconnect
logger.noise "Finished."