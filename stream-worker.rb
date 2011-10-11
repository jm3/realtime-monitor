#!/usr/bin/env ruby
# encoding: UTF-8

require "redis"
require "sinatra"
require "sinatra/redis"
require "net/ssh/multi"

redis_url = ENV["REDISTOGO_URL"] || "redis://localhost:6379"
uri = URI.parse(redis_url)
redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

def do_tail( session, file )
  session.open_channel do |channel|
    channel.on_data do |ch, data|
      puts redis.lpush "log-stream", "#{channel[:host]} #{data}"
    end
    channel.exec "tail -f #{file}"
  end
end

def stream_data
  Net::SSH::Multi.start do |session|
    session.use "jm3@argon.140proof.com"
    session.use "jm3@neon.140proof.com"
    do_tail session, "/var/log/nginx/api.140proof.com-access.log" # is called once
    session.loop
  end
end

while true do
  puts "publishing events..."
  stream_data
end

