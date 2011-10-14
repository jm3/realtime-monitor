#!/usr/bin/env ruby
# encoding: UTF-8

# Gemfile:
# source "http://rubygems.org"
# 
# gem "em-synchrony"
# gem "eventmachine"
# gem "foreman"
# gem "haml"
# gem "hiredis", "~> 0.3.1"
# gem "net-ssh-multi"
# gem "rack" , "1.3.3"
# gem "rainbows"
# gem "redis", "~> 2.2.0", :require => ["redis/connection/synchrony", "redis"]
# gem "sinatra", "1.3", :require => ["sinatra/base"]
# gem "sinatra-content-for2"
# gem "sinatra-redis"
# gem "sinatra-synchrony"

require "eventmachine"
require "fiber"
require "rack/fiber_pool"
require "redis"
require "redis/connection/synchrony"
require "rubygems"
require "sinatra/base"
require "sinatra/content_for2"

# rackup -s thin app.rb
#
# curl http://localhost:9292/foo
# curl http://localhost:9292/bar
#
# redis-cli publish foo "hello"
# redis-cli publish bar "hola"

class App < Sinatra::Base
  use Rack::FiberPool

EM.run { EM.watch(1) } 


  get "/:channel" do |channel|
    redis = Redis.connect
    redis.subscribe(channel) do |on|
      on.message do |channel, message|
        redis.unsubscribe
        body "#{channel}: #{message}"
      end
    end
  end

  helpers do
    def yield_content_in_module(key, mod, localvar=:c, *args)
      content_blocks[key.to_sym].map do |content|
        if respond_to?(:block_is_haml?) && block_is_haml?(content)
          mod "#{mod.to_s}", :locals => {localvar => capture_haml(*args, &content)}
        else
          content.call
        end
      end.join
    end
  end

end
