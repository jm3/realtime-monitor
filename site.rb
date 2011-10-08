#!/usr/bin/env ruby
# encoding: UTF-8

require 'erb'
require 'haml'
require 'rubygems'
require 'sinatra'
require 'sinatra/bundles'
require 'sinatra/content_for2'

ASSET_PREFIX = :development ? '' : 'http://cache1.jm3.net'

# re-open stylesheet_bundle_link_tag to add CDN support:
module Sinatra
  module Bundles
    module Helpers
      alias :old_stylesheet_bundle_link_tag :stylesheet_bundle_link_tag 
      def stylesheet_bundle_link_tag(bundle, media = nil)
        old_stylesheet_bundle_link_tag(
          bundle, media = nil
        ).gsub( /'/, '"' ).gsub( /href="\/stylesheets/, "href=\"#{ASSET_PREFIX}/stylesheets").gsub( /\?[0-9]+/, '' )
      end
    end
  end
end

stylesheet_bundle(:all, ['home-grid'])

enable(:compress_bundles)  # => false (compress CSS and Javascript using packr and rainpress)
enable(:cache_bundles)     # => false (set caching headers)

before do
  @page_title = 'Founder, App Engineer, Product Designer.'
end

get '/' do
  @page_title = '★ John Manoogian III (jm3) ★ - ' + @page_title
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
