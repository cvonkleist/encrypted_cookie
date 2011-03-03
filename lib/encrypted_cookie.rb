require 'openssl'
require 'rack/request'
require 'rack/response'

module Rack

  module Session

    # Rack::Session::EncryptedCookie provides AES-128-encrypted, tamper-proof
    # cookie-based session management.
    #
    # The session is Marshal'd, HMAC'd, and encrypted.
    #
    # Example:
    #
    #     use Rack::Session::EncryptedCookie,
    #       :secret => 'change_me',
    #       :key => 'rack.session',
    #       :domain => 'foo.com',
    #       :path => '/',
    #       :expire_after => 2592000
    #
    #     All parameters are optional except :secret.

    class EncryptedCookie

      def initialize(app, options={})
        @app = app
        @key = options[:key] || "rack.session"
        @secret = options[:secret]
        fail "Error! A secret is required to use encrypted cookies. Do something like this:\n\nuse Rack::Session::EncryptedCookie, :secret => YOUR_VERY_LONG_VERY_RANDOM_SECRET_KEY_HERE" unless @secret
        @default_options = {:domain => nil,
          :path => "/",
          :expire_after => nil}.merge(options)
      end

      def call(env)
        load_session(env)
        status, headers, body = @app.call(env)
        commit_session(env, status, headers, body)
      end

      private

      def load_session(env)
        request = Rack::Request.new(env)
        session_data = request.cookies[@key]

        if session_data
          #begin
            session_data = decrypt(session_data)
            session_data, digest = session_data.split("--")
            session_data = nil  unless digest == generate_hmac(session_data)
          #rescue OpenSSL::Cipher::Cipher
        end

        begin
          session_data = session_data.unpack("m*").first
          session_data = Marshal.load(session_data)
          env["rack.session"] = session_data
        rescue
          env["rack.session"] = Hash.new
        end

        env["rack.session.options"] = @default_options.dup
      end

      def commit_session(env, status, headers, body)
        session_data = Marshal.dump(env["rack.session"])
        session_data = [session_data].pack("m*")

        session_data = "#{session_data}--#{generate_hmac(session_data)}"

        session_data = encrypt(session_data)

        if session_data.size > (4096 - @key.size)
          env["rack.errors"].puts("Warning! Rack::Session::Cookie data size exceeds 4K. Content dropped.")
        else
          options = env["rack.session.options"]
          cookie = Hash.new
          cookie[:value] = session_data
          cookie[:expires] = Time.now + options[:expire_after] unless options[:expire_after].nil?
          Utils.set_cookie_header!(headers, @key, cookie.merge(options))
        end

        [status, headers, body]
      end

      def generate_hmac(data)
        OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, @secret, data)
      end

      def encrypt(str)
        aes = OpenSSL::Cipher::Cipher.new('aes-128-cbc').encrypt
        aes.key = @secret
        salt = OpenSSL::Random.random_bytes(aes.key_len)
        iv = OpenSSL::Random.random_bytes(aes.iv_len)
        [iv + (aes.update(str) << aes.final)].pack('m0')
      end

      def decrypt(str)
        str = str.unpack('m0').first
        aes = OpenSSL::Cipher::Cipher.new('aes-128-cbc').decrypt
        aes.key = @secret
        iv = str[0, aes.iv_len]
        crypted_text = str[aes.iv_len..-1]
        aes.update(crypted_text) << aes.final
      end
    end
  end
end
