#!/usr/bin/env ruby
# encoding: UTF-8

require "redis"
require "sinatra"
require "sinatra/redis"
require "net/ssh/multi"

redis_url = ENV["REDISTOGO_URL"] || "redis://localhost:6379"
uri = URI.parse(redis_url)
redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

@ssh_user = "jm3"
@num_servers = 14

def do_tail( session, file )
  session.open_channel do |channel|
    channel.on_data do |ch, data|
      host = channel[:host].gsub( /\.140proof\.com/, '' )
      redis.publish "global.clicks", "#{host} #{data}" and print "*Pc* " if data.match( %r{/clicks/} )
      redis.publish "global.impressions", "#{host} #{data}" and print "Pi " if data.match( %r{/impressions/} )
    end
    channel.exec "tail -f #{file}"
  end
end

def stream_data
  Net::SSH::Multi.start do |session|
    1.upto(@num_servers) do |i|
      puts "Attaching listener to api#{i}.140proof.com"
      session.use "#{@ssh_user}@api#{i}.140proof.com"
    end
    do_tail session, "/var/log/nginx/api.140proof.com-access.log" # is called once
    session.loop
  end
end

while true do
  puts "publishing events..."
  stream_data
end

