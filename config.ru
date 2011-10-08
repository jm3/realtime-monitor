require "rubygems"
require "bundler"
Bundler.setup
require "./site.rb"

run Sinatra::Application
