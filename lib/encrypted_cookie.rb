require 'rack'
require 'encrypted_cookie/encryptor'

module Rack
  module Session
    # Rack::Session::EncryptedCookie provides AES-256-encrypted, tamper-proof
    # cookie-based session management.
    #
    # The session is Marshal'd, encrypted and HMAC'd.
    #
    # Example:
    #
    #     use Rack::Session::EncryptedCookie,
    #       :secret => 'change_me',
    #       :key => 'rack.session',
    #       :domain => 'foo.com',
    #       :path => '/',
    #       :expire_after => 2592000
    #       :time_to_live => 600
    #
    #     All parameters are optional except :secret.
    #
    #     The default for the session time-to-live is 30 minutes. You can set
    #     the timeout on per session base by adding the expiration time in the
    #     session:
    #        session[Rack::Session::EncryptedCookie::EXPIRES] = Time.now + 120
    #
    #     Note that you shouldn't trust the expire_after parameter in the cookie
    #     for session expiry as that can be altered by the recipient. Instead,
    #     use time_to_live which is server side check.
    class EncryptedCookie
      EXPIRES = '_encrypted_cookie_expires_'

      def initialize(app, options={})
        @app = app
        @key = options[:key] || "rack.session"
        @secret = options[:secret]
        fail "Error! A secret is required to use encrypted cookies. Do something like this:\n\nuse Rack::Session::EncryptedCookie, :secret => YOUR_VERY_LONG_VERY_RANDOM_SECRET_KEY_HERE" unless @secret
        @default_options = {:domain => nil,
          :path => "/",
          :time_to_live => 1800,
          :expire_after => nil}.merge(options)
        @encryptor = Encryptor.new(@secret)
      end

      def call(env)
        load_session(env)
        status, headers, body = @app.call(env)
        commit_session(env, status, headers, body)
      end

      private

      def remove_expiration(session_data)
        expires = session_data.delete(EXPIRES)
        if expires and expires < Time.now
          session_data.clear
        end
      end

      def load_session(env)
        request = Rack::Request.new(env)
        env["rack.session.options"] = @default_options.dup

        session_data = request.cookies[@key]
        session_data = @encryptor.decrypt(session_data)
        session_data = Marshal.load(session_data)
        remove_expiration(session_data)

        env["rack.session"] = session_data
      rescue
        env["rack.session"] = Hash.new
      end

      def add_expiration(session_data, options)
        if options[:time_to_live] && !session_data.key?(EXPIRES)
          expires = Time.now + options[:time_to_live]
          session_data.merge!({EXPIRES => expires})
        end
      end

      def commit_session(env, status, headers, body)
        options = env["rack.session.options"]

        session_data = env["rack.session"]
        add_expiration(session_data, options)
        session_data = Marshal.dump(session_data)
        session_data = @encryptor.encrypt(session_data)

        if session_data.size > (4096 - @key.size)
          env["rack.errors"].puts("Warning! Rack::Session::Cookie data size exceeds 4K. Content dropped.")
        else
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
