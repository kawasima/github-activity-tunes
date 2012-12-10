require 'rubygems'
require 'bundler'

Bundler.setup
$LOAD_PATH.unshift ENV['APP_ROOT'] || File.expand_path('..', __FILE__)
$LOAD_PATH.unshift File.join($LOAD_PATH.first, 'lib')

Encoding.default_external = 'utf-8' if RUBY_VERSION >= '1.9'

#require 'ruby-debug' if ENV['RACK_ENV'] == 'development'

require 'app'

run Rack::URLMap.new('/github-activity-tunes' => Sinatra::Application)
