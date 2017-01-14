#!/usr/bin/env ruby
# encoding: UTF-8

require "redis"
require "sinatra"
require "sinatra/redis"
require "net/ssh/multi"
require "yaml"

config = YAML::load( File.open( "settings.yml" ) )

redis_url = ENV["REDISTOGO_URL"] || config["redis_url"]
uri = URI.parse(redis_url)
redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

@ssh_user      = config["ssh_user"] || ENV["USER"]
@num_servers   = config["num_servers"]
@server_domain = config["server_domain"]

# always reset in case we were left in a fcked state:
redis.set "cfg:track", "impressions"

def do_tail( session, file )
  subject = redis.get("cfg:track") || "impressions"
  session.open_channel do |channel|
    channel.on_data do |ch, data|
      host = channel[:host].gsub( /#{@server_domain}/, "" )
      data = data.gsub( / - - /, " " ).gsub( / \+0000/, "" )
      redis.publish "global.clicks", "#{host} #{data}" and print "*Pc* " if( subject == "clicks" and data.match( %r{/clicks/} ))
      redis.publish "global.impressions", "#{host} #{data}" and print "Pi " if( subject == "impressions" and data.match( %r{/impressions/} ))
    end
    channel.exec "tail -f #{file}"
  end
end

def stream_data
  Net::SSH::Multi.start do |session|
    1.upto(@num_servers) do |i|
      puts "Attaching listener to api#{i}.#{@server_domain}"
      session.use "#{@ssh_user}@api#{i}.#{@server_domain}"
    end
    do_tail session, "/var/log/nginx/api.#{@server_domain}-access.log"
    session.loop
  end
end

while true do
  puts "publishing events..."
  stream_data
end

