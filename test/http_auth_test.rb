require 'rubygems'
require 'sinatra'
require 'test/unit'
require 'rack/test'
require 'base64'
require 'yaml'
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'toopaste'))

set :views, File.join(File.dirname(__FILE__), '..', 'views')
set :environment, :test

class ApplicationTest < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def app
    Sinatra::Application
  end

  def test_without_authentication
    get '/'
    assert_equal 401, last_response.status
  end

  def test_with_bad_credentials
    get '/', {}, {'HTTP_AUTHORIZATION' => encode_credentials('go', 'away')}
    assert_equal 401, last_response.status
  end

  def test_with_proper_credentials
    get '/', {}, {'HTTP_AUTHORIZATION'=> encode_credentials('changeme', 'changeme')} # [:TODO] @USERNAME and @PASSWORD is returning nil
    assert_equal 200, last_response.status                                           # need to fix it.
    assert_match "Paste a new code snippet below:", last_response.body
  end

  private

  def encode_credentials(username, password)
    "Basic " + Base64.encode64("#{username}:#{password}")
  end
end