require "rubygems"
require "bundler"
Bundler.setup
require "./web.rb"

run Sinatra::Application
