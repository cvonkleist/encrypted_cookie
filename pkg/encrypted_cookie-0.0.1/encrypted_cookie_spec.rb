require 'encrypted_cookie'

include Rack::Session

describe Cookie::AES do
  it 'should pass the encryption test' do
    a = Cookie::AES.new('foo')
    enc = a.encode("bar")
    a.decode(enc).should == 'bar'
  end
end
