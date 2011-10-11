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
    c = redis.rpop("log-stream")
    out << "data: #{c}\n"
  end
end

get "/settings" do
  haml :settings
end

error 404 do
  haml :error
end

helpers do
  def img( uri )
    return "" unless uri
    "<img src=\"#{img_path(uri)}\" />"
  end

  def img_path( uri )
    return "" unless uri
    uri = uri.match("^/images/") ? uri : "/images/" + uri
    :development ? uri : "http://cache#{cache_server}.jm3.net#{uri}"
  end
end
