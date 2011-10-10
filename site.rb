#!/usr/bin/env ruby
# encoding: UTF-8

require "erb"
require "haml"
require "net/ssh/multi"
require "rubygems"
require "sinatra"
require "sinatra/content_for2"


def do_tail( session, file )
  session.open_channel do |channel|
    channel.on_data do |ch, data|
      @stack << "channel[:host]} #{data}"
      puts @stack.size
      puts "#{channel[:host]} #{data}"
    end
    channel.exec "tail -f #{file}"
  end
end

def stream_data
  Net::SSH::Multi.start do |session|
    session.use "#{@config[:user]}@argon.140proof.com"
    session.use "#{@config[:user]}@neon.140proof.com"
    do_tail session, @config[:log] # is called once
    session.loop
  end
end

# run once at startup
configure do
  @stack = []
  @config = {
    :log => "/var/log/nginx/api.140proof.com-access.log",
    :user => "jm3"
  }
  stream_data
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
    #out << @stack[0]
    #sleep 0.5
    out << "data: Foo\n"
  end
end

get "/config" do
  @page_title = "★ config ★"
  haml :config
end

get "/", :agent => /iPhone/ do
  @meta = '<meta name="viewport" content="width = 320" />'
  @iphone = true
  haml :index
end

get "/iphone/?" do
  @meta = '<meta name="viewport" content="width = 320" />'
  @iphone = true
  haml :index
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
