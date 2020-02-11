require_relative './requires'
logger = CronLogger.new

logger.noise "Checking new stories ... "
stories = eval(Faraday.get('https://hacker-news.firebaseio.com/v0/newstories.json?print=pretty').body)
stories.each do |story|
  # puts "https://hacker-news.firebaseio.com/v0/item/#{story}.json?print=pretty"
  story_body = Faraday.get("https://hacker-news.firebaseio.com/v0/item/#{story}.json?print=pretty").body
  res = JSON.parse(story_body)
  next if res.nil?
  url = res['url']
  next if url.nil?
  puts "Story URL: #{url}"
  matched = url.match(/https:\/\/github.com\/(\w*\/\w*)/)
  if !matched.nil?
    repo = matched.captures.first
    puts "Got GitHub repo in the story: #{repo}".colorize(:green)
    puts "Checking if repo does exist..."
    get_repo = Faraday.get("https://github.com/#{repo}")
    if get_repo.status != 200
      puts "Repo does not exist".colorize(:red)
      next
    else
      puts "Repo exists".colorize(:green)
    end
    puts "Checking stars..."
    git = Faraday.get("https://api.github.com/search/repositories?q=#{repo}").body
    github_info = JSON.parse(git)
    watchers = github_info['items'].first['watchers']
    puts "Repo got #{watchers} stars".colorize(:green)
    if watchers < 1000
      puts "Acceptable repo. Adding."
      uri = URI.parse("https://www.codexia.org/submit?platform=github&coordinates=#{repo}")
      request = Net::HTTP::Post.new(uri)
      request["X-Codexia-Token"] = "aVNWGabjqepRV4G2LJKe1psah4nGk7rNYJQcFrJ8NuEc"
      req_options = { use_ssl: uri.scheme == "https" }
      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end
      puts "Added to Codexia"
    else
      puts "This repo is too pupular. Skipping."
    end
  end
end
DB.disconnect
logger.noise "Finished."