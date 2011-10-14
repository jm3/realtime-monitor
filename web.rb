#!/usr/bin/env ruby
# encoding: UTF-8

require "em-synchrony"
require "redis"
require "redis/connection/synchrony"
require "rubygems"
require "sinatra"
require "sinatra/base"
require "sinatra/content_for2"
require "sinatra/redis"
require "sinatra/synchrony"

class App < Sinatra::Base
  register Sinatra::Synchrony

  get "/" do
    haml :index
  end

  get "/stream" do
    headers "Content-Type" => "text/event-stream", "Cache-Control" => "no-cache"
    redis = Redis.connect
    channel = "global.impressions"
    redis.subscribe(channel) do |on|
      on.message do |channel, message|
        redis.unsubscribe
        body "data: #{channel}: #{message}\n"
      end
    end

    #stream do |out|
    #  out << "data: event: message\n"
    # end

    # EM.synchrony do
    #   r = Redis.new
    #   body "data: #{channel}: #{message}\n"
    # end

    # stream(:keep_open) do |out|
    #   EventMachine::PeriodicTimer.new(1) { out << "data: #{Time.now}\n" }
    # end

  end

end

