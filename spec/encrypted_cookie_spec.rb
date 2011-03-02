require 'rack/test'
require 'sinatra'
require 'rspec'
require 'ruby-debug'
require 'cgi'
require File.dirname(__FILE__) + '/../lib/encrypted_cookie'

include Rack::Session

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

class EncryptedApp < Sinatra::Application
  use Rack::Session::EncryptedCookie, :secret => 'foo' * 10
  get '/' do
    "session: " + session.inspect
  end
  get '/set/:key/:value' do
    session[params[:key]] = params[:value]
    "all set"
  end
end

# this app has cookie integrity protection, but not encryption
class UnencryptedApp < Sinatra::Application
  use Rack::Session::Cookie, :secret => 'foo' * 10
  get '/' do
    "session: " + session.inspect
  end
end

describe EncryptedCookie do
  it 'should fail if no secret is specified' do
    lambda { EncryptedCookie.new(nil) }.should raise_error(/A secret is required/)
    lambda { EncryptedCookie.new(nil, :secret => 'foo') }.should_not raise_error(/A secret is required/)
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

    data = last_response.headers['Set-Cookie'][/rack.session=(.*?);/, 1]
    str = CGI.unescape(data).unpack('m0').first
    aes = OpenSSL::Cipher::Cipher.new('aes-128-cbc').decrypt
    aes.key = 'foo' * 10
    iv = str[0, aes.iv_len]
    crypted_text = str[aes.iv_len..-1]

    plaintext = (aes.update(crypted_text) << aes.final)
    base64_marshal_data, hmac = plaintext.split('--')
    session_hash = Marshal.load(base64_marshal_data.unpack('m0').first)
    session_hash.should == {"foo" => "bar"}
  end
  it "should make encrypted session data that can't be decrypted with the wrong key" do
    get '/set/foo/bar'
    last_response.body.should == 'all set'
    get '/'
    last_response.body.should == 'session: {"foo"=>"bar"}'
    last_response.headers['Set-Cookie'].should_not include("BAh7AA")

    data = last_response.headers['Set-Cookie'][/rack.session=(.*?);/, 1]
    str = CGI.unescape(data).unpack('m0').first
    aes = OpenSSL::Cipher::Cipher.new('aes-128-cbc').decrypt
    aes.key = 'bar' * 10
    iv = str[0, aes.iv_len]
    crypted_text = str[aes.iv_len..-1]

    lambda { plaintext = (aes.update(crypted_text) << aes.final) }.should raise_error("bad decrypt")
  end
end

describe UnencryptedApp do
  def app
    UnencryptedApp
  end
  it "should include unencrypted marshal'd data" do
    get '/'
    last_response.body.should == 'session: {}'
    last_response.headers['Set-Cookie'].should include("BAh7AA")
  end
end
