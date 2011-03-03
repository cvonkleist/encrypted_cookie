## Encrypted session cookies for Rack (and therefore Sinatra)

The `encrypted_cookie` gem provides 128-bit-AES-encrypted, tamper-proof cookies
for Rack through the class `Rack::Session::EncryptedCookie`.

## How to use encrypted\_cookie

    $ gem install encrypted_cookie

Sinatra example:

    require 'sinatra'
    require 'encrypted_cookie'
    
    use Rack::Session::EncryptedCookie,
      :secret => TYPE_YOUR_LONG_RANDOM_STRING_HERE*
    
    get '/' do
      session[:foo] = 'bar'
      "session: " + session.inspect
    end

_*_ Your `:secret` must be at least 16 bytes long and should be really random.

## Encryption and integrity protection

The cookie encryption method is 128-bit AES (with salt). Additionally, the
cookies are integrity protected with Rack's built-in HMAC support, which means
that if a user tampers with their cookie in any way, their session will
immediately be reset to `{}` (empty hash).

## Generating a good secret

    require 'openssl'
    puts OpenSSL::Random.random_bytes(16).inspect
