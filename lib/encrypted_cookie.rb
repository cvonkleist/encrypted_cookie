require 'openssl'
require 'rack/request'
require 'rack/response'
require 'encrypted_cookie/encryptor'

module Rack

  module Session

    # Rack::Session::EncryptedCookie provides AES-256-encrypted, tamper-proof
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
    #
    #     Note that you shouldn't trust the expire_after parameter in the cookie
    #     for session expiry as that can be altered by the recipient.  Instead,
    #     store a timestamp in the session
    class EncryptedCookie

      def initialize(app, options={})
        @app = app
        @key = options[:key] || "rack.session"
        @secret = options[:secret]
        fail "Error! A secret is required to use encrypted cookies. Do something like this:\n\nuse Rack::Session::EncryptedCookie, :secret => YOUR_VERY_LONG_VERY_RANDOM_SECRET_KEY_HERE" unless @secret
        @default_options = {:domain => nil,
          :path => "/",
          :expire_after => nil}.merge(options)
        @encryptor = Encryptor.new(@secret)
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
          session_data = @encryptor.decrypt(session_data)
        end

        begin
          session_data = Marshal.load(session_data)
          env["rack.session"] = session_data
        rescue
          env["rack.session"] = Hash.new
        end

        env["rack.session.options"] = @default_options.dup
      end

      def commit_session(env, status, headers, body)
        session_data = Marshal.dump(env["rack.session"])
        session_data = @encryptor.encrypt(session_data)

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
    end
  end
end
