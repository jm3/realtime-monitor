#!/usr/bin/env ruby
# encoding: UTF-8

require 'erb'
require 'haml'
require 'net/ssh'
require 'rubygems'
require 'sinatra'
require 'sinatra/bundles'
require 'sinatra/content_for2'

stylesheet_bundle(:all, ['home-grid'])

enable(:compress_bundles)  # => false (compress CSS and Javascript using packr and rainpress)
enable(:cache_bundles)     # => false (set caching headers)

def do_tail( session, file )
  session.open_channel do |channel|
    channel.on_data do |ch, data|
      puts "[#{file}] -> #{data}"
    end
    channel.exec "tail -f #{file}"
  end
end

# run once at startup
configure do
  ssh_connection_obj_placeholder = "i am foo"
  @config = {
    :persistent_ssh_connection => ssh_connection_obj_placeholder,
    :log => "/var/log/nginx/api.140proof.com-access.log"
  }
  @config[:persistent_ssh_connection] = "i am bar"

  Net::SSH.start( 'argon.140proof.com', 'jm3' ) do |session|
    do_tail session, @config[:log] # is called once
    session.loop
  end
end

# run once before each request
before do
  @page_title = '★ Realtime Monitoring ★ - '
end

get '/' do
  puts @config["persistent_ssh_connection"]
  haml :index
end

get '/config' do
  @page_title = '★ config ★'
  haml :config
end

get '/', :agent => /iPhone/ do
  @meta = '<meta name="viewport" content="width = 320" />'
  @iphone = true
  haml :index
end

get '/iphone/?' do
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
    uri = uri.match('^/images/') ? uri : '/images/' + uri
    :development ? uri : "http://cache#{cache_server}.jm3.net#{uri}"
  end

end
