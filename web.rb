#!/usr/bin/env ruby
# encoding: UTF-8

require "erb"
require "haml"
require "net/ssh/multi"
require "rubygems"
require "sinatra"
require "sinatra/content_for2"
require "sinatra/redis"
require "json"

set :server, :rainbows

# run once at startup
configure do
  config = YAML::load( File.open( "settings.yml" ) )
  redis_url = ENV["REDISTOGO_URL"] || config["redis_url"]
  uri = URI.parse(redis_url)
  redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end

# run once before each request
before do
  @page_title = "★ Realtime Monitoring ★"
end

get "/" do
  haml :index
end

get "/stream" do
  headers "Content-Type" => "text/event-stream", "Cache-Control" => "no-cache"

  stream do |out|
    redis.psubscribe( "global.impressions", "global.clicks" ) do |on|
      on.psubscribe do |event, total|
        puts "Subscribed to ##{event} (#{total} subscriptions)"
      end

      on.pmessage do |pattern, event, message|
        out << "data: #{message}\n"
      end
    end

    on.punsubscribe do |event, total|
      puts "Unsubscribed from ##{event} (#{total} subscriptions)"
    end
  end

end

get "/track/*.json" do
  content_type :json
  subject = params[:splat][0]

  case subject
  when "impressions", "clicks", "hashtag", "keyword", "screen_name"
    puts "got valid subject #{subject}!"
    redis.set "cfg:track", subject
  else
    puts "Now you're just making shit up!"
  end

  { :track => redis.get("cfg:track") }.to_json
end

get "/flip/?" do
  haml :flip
end

error 404 do
  haml :error
end

helpers do
  def img_path( uri )
    return "" unless uri
    uri = uri.match("^/images/") ? uri : "/images/" + uri
    :development ? uri : "http://cache#{cache_server}.jm3.net#{uri}"
  end
end
