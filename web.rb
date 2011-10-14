#!/usr/bin/env ruby
# encoding: UTF-8

require "fiber"
require "rack/fiber_pool"
require "sinatra/base"

require "redis"
require "redis/connection/synchrony"

# rackup -s thin app.rb
#
# curl http://localhost:9292/foo
# curl http://localhost:9292/bar
#
# redis-cli publish foo "hello"
# redis-cli publish bar "hola"

class App < Sinatra::Base

  use Rack::FiberPool

  # run once at startup
  configure do
  end

  # run once before each request
  before do
  end

  get "/:channel" do |channel|
    redis = Redis.connect
    redis.subscribe(channel) do |on|
      on.message do |channel, message|
        redis.unsubscribe
        body "#{channel}: #{message}"
      end
    end
  end

  get "/" do
    haml :index
  end

  get "/stream" do
    headers "Content-Type" => "text/event-stream", "Cache-Control" => "no-cache"
  end

  error 404 do
    haml :error
  end

  helpers do
  end

end
