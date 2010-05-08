require 'rubygems'
require 'sinatra'

set :run, false
set :views, File.join(File.dirname(__FILE__), 'views')
set :env, (ENV['RACK_ENV'] ? ENV['RACK_ENV'].to_sym : :production)

require 'toopaste'
run Sinatra::Application
