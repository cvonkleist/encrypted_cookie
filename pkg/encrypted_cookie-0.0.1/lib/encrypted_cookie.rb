require 'openssl'

module Rack
  module Session
    class Cookie
      class AES
        def initialize(key)
          @key = key
        end

        def encode(str)
          aes = OpenSSL::Cipher::Cipher.new('aes-128-cbc').encrypt
          salt = OpenSSL::Random.random_bytes(aes.key_len)
          iv = OpenSSL::Random.random_bytes(aes.iv_len)
          [iv + (aes.update(str) << aes.final)].pack('m0')
        end

        def decode(str)
          str = str.unpack('m0').first
          aes = OpenSSL::Cipher::Cipher.new('aes-128-cbc').decrypt
          iv = str[0, aes.iv_len]
          crypted_text = str[aes.iv_len..-1]
          aes.update(crypted_text) << aes.final
        end
      end
    end
  end
end
