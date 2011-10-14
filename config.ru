require "rubygems"
require "bundler"
Bundler.setup
require "./web.rb"

# unless File.basename( $0 ).match( /rainbows/ )
#   puts "realtime monitor MUST be run under a websockets compatible webserver like Rainbows"
#   exit 1
# end

run App
