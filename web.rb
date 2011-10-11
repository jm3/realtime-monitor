#!/usr/bin/env ruby
# encoding: UTF-8

require "erb"
require "haml"
require "net/ssh/multi"
require "rubygems"
require "sinatra"
require "sinatra/content_for2"
require "sinatra/redis"

set :server, :rainbows

# run once at startup
configure do
  #redis_url = ENV["REDISTOGO_URL"] || "redis://localhost:6379"
  #uri = URI.parse(redis_url)
  #set :redis, Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
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
    redis.subscribe("log-stream" ) do |on|
      on.subscribe do |event, total|
        puts "Subscribed to ##{event} (#{total} subscriptions)"
      end

      on.message do |pattern, event, message|
        out << "data: #{event}\n"
        print "e"
      end
    end

    on.unsubscribe do |event, total|
      puts "Unsubscribed from ##{event} (#{total} subscriptions)"
    end
  end

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
