require 'rack/test'
require 'sinatra/base'
require 'rspec'
require 'cgi'
require './lib/encrypted_cookie'

include Rack::Session


module Helper
  def unpack_cookie
    data = last_response.headers['Set-Cookie'][/rack.session=(.*?);/, 1]
    data = data.split('--').first
    str = CGI.unescape(data).unpack('m').first
  end
end


RSpec.configure do |conf|
  conf.include Rack::Test::Methods
  conf.include Helper
end

class EncryptedApp < Sinatra::Application
  disable :show_exceptions
  use Rack::Session::EncryptedCookie, :secret => 'foo' * 10, :time_to_live => 0.1
  get '/' do
    "session: " + session.inspect
  end
  get '/timeout/:value' do
    session[Rack::Session::EncryptedCookie::EXPIRES] = Time.now + params[:value].to_i
    "timeout set"
  end
  get '/set/:key/:value' do
    session[params[:key]] = params[:value]
    "all set"
  end
end

# this app has cookie integrity protection, but not encryption
class UnencryptedApp < Sinatra::Application
  disable :show_exceptions
  use Rack::Session::Cookie, :secret => 'foo' * 10
  get '/' do
    session[:foo] = 'bar'
    "session: " + session.inspect
  end
end

describe EncryptedCookie do
  it 'should fail if no secret is specified' do
    lambda { EncryptedCookie.new(nil) }.should raise_error(/A secret is required/)
    lambda { EncryptedCookie.new(nil, :secret => 'foo') }.should_not raise_error
  end
end

describe EncryptedApp do
  def app
    EncryptedApp
  end
  it "should not include unencrypted marshal'd data" do
    get '/'
    last_response.body.should == 'session: {}'
    last_response.headers['Set-Cookie'].should_not include("BAh7AA")
  end
  it "should make decryptable session data" do
    get '/set/foo/bar'
    last_response.body.should == 'all set'
    get '/'
    last_response.body.should == 'session: {"foo"=>"bar"}'
    last_response.headers['Set-Cookie'].should_not include("BAh7AA")
  end
  it "should make encrypted session data that can't be decrypted with the wrong key" do
    get '/set/foo/bar'
    last_response.body.should == 'all set'
    get '/'
    last_response.body.should == 'session: {"foo"=>"bar"}'
    last_response.headers['Set-Cookie'].should_not include("BAh7AA")

    data = unpack_cookie
    aes = OpenSSL::Cipher.new('aes-128-cbc').decrypt
    aes.key = 'bar' * 10
    iv = data[0, aes.iv_len]
    crypted_text = data[aes.iv_len..-1]

    lambda { plaintext = (aes.update(crypted_text) << aes.final) }.should raise_error("bad decrypt")
  end
  it "should reset the session if someone messes with the crypted data" do
    get '/set/foo/bar'
    last_response.body.should == 'all set'
    get '/'
    last_response.body.should == 'session: {"foo"=>"bar"}'

    # tamper with the cookie (too short to be aes data)
    rack_mock_session.cookie_jar << Rack::Test::Cookie.new('rack.session=foo', URI.parse('http://example.org//'))

    get '/'
    last_response.body.should == 'session: {}'

    # tamper with the cookie (long enough to attempt aes decryption)
    rack_mock_session.cookie_jar << Rack::Test::Cookie.new('rack.session=foobarbaz', URI.parse('http://example.org//'))

    get '/'
    last_response.body.should == 'session: {}'
  end
  it "should reset the session on timeout" do
    get '/set/foo/bar'
    last_response.body.should == 'all set'
    get '/'
    last_response.body.should == 'session: {"foo"=>"bar"}'
    sleep 0.08
    get '/'
    last_response.body.should == 'session: {"foo"=>"bar"}'
    sleep 0.08
    get '/'
    last_response.body.should == 'session: {"foo"=>"bar"}'
    sleep 0.1
    get '/'
    last_response.body.should == 'session: {}'
    get '/timeout/0'
    last_response.body.should == 'timeout set'
    get '/'
    last_response.body.should == 'session: {}'
  end
end

describe UnencryptedApp do
  def app
    UnencryptedApp
  end
  it "should include unencrypted marshal'd data" do
    get '/'
    cookie = Marshal.load(unpack_cookie)
    cookie['foo'].should == 'bar'
  end
end
