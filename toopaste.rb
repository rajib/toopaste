#!/usr/local/bin/ruby -rubygems
require 'sinatra'
require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'syntaxi'
require 'yaml'

# load YML content
content = File.new("config/settings.yml").read
settings = YAML::load content


configure :development do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/toopaste.sqlite3")
end

configure :production do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/toopaste.production.sqlite3")
end

class Snippet
  include DataMapper::Resource

  property :id,         Serial # primary serial key
  property :title,      String, :required => true, :length => 32
  property :body,       Text,   :required => true
  property :created_at, DateTime
  property :updated_at, DateTime

  validates_present :body
  validates_length :body, :minimum => 1

  Syntaxi.line_number_method = 'floating'
  Syntaxi.wrap_at_column = 80
  #Syntaxi.wrap_enabled = false

  def formatted_body
    replacer = Time.now.strftime('[code-%d]')
    html = Syntaxi.new("[code lang='ruby']#{self.body.gsub('[/code]',
    replacer)}[/code]").process
    "<div class=\"syntax syntax_ruby\">#{html.gsub(replacer, 
    '[/code]')}</div>"
  end
end

DataMapper.auto_upgrade!
#File.open('toopaste.pid', 'w') { |f| f.write(Process.pid) }

# HTTP authentication required before actual operation
use Rack::Auth::Basic do |username, password|
  [username, password] == [settings['username'], settings['password']]
end

# new
get '/' do
  erb :new
end

# create
post '/' do
  @snippet = Snippet.new(:title => params[:snippet_title],
                         :body  => params[:snippet_body])
  if @snippet.save
    redirect "/#{@snippet.id}"
  else
    redirect '/'
  end
end

# show
get '/:id' do
  @snippet = Snippet.get(params[:id])
  if @snippet
    erb :show
  else
    redirect '/'
  end
end
