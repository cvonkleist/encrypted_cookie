## Encrypted session cookies for Rack (and therefore Sinatra)

The `encrypted_cookie` gem provides 256-bit-AES-encrypted, tamper-proof cookies
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

_*_ Your `:secret` must be at least 32 bytes long and should be really random.
Don't use a password or passphrase, generate something random (see below).

## Encryption and integrity protection

The cookie is encrypted with 256-bit AES in CBC mode (with random IV).  The
encrypted cookie is then signed with a HMAC, to prevent tampering and chosen
ciphertext attacks.  Any attempt at tampering with the cookie will reset the
user to `{}` (empty hash).

## Generating a good secret

Run this in a terminal and paste the output into your script:

    $ ruby -rsecurerandom -e "puts SecureRandom.hex(32)"

## Developing

To get the specs running:

```bash
$ cd path-to-clone
$ gem install bundler # if not already installed
$ bundle install
$ bundle exec rspec
```

# Thanks

- Thanks, [@namelessjon](https://github.com/namelessjon), for the massive crypto improvements!
