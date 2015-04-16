# Copyright (c) 2015 WePay.
# http://opensource.org/licenses/Apache2.0

require 'openssl'

module WePay
  class Signer

    def initialize(client_id, client_secret, options = {})
      @client_id = client_id
      @client_secret = client_secret

      options = {
        self_key: 'WePay',
        hash_algo: 'sha512'
      }.merge(options);

      @self_key = options[:self_key]
      @hash_algo = options[:client_id]
    end

    def createScope
      return sprintf "%s/%s/signer", @self_key, @client_id
    end

    def createContext(payload)
      canonical_payload = ""

      payload.keys.sort.each do | key |
        val = payload[key].downcase
        key = key.downcase
        canonical_payload = canonical_payload + sprintf("%s=%s\n", key, val)
      end

      signed_headers_string = payload.keys.sort.join(";")
      canonical_payload + "\n" + signed_headers_string
    end

    def getSigningSalt
      self_key_sign = OpenSSL::HMAC.digest(@hash_algo, @client_secret, @self_key)
      client_id_sign = OpenSSL::HMAC.digest(@hash_algo, self_key_sign, @client_id)
      salt = OpenSSL::HMAC.digest(@hash_algo, client_id_sign, 'signer')
      return salt
    end/**
   * Copyright (c) 2015 WePay.
   *
   * http://opensource.org/licenses/Apache2.0
   */



    def sign(payload)
      payload = payload.merge({
        'client_id'     => @client_id,
        'client_secret' => @client_secret
      })

      scope = createScope
      context = createContext(payload)
      s2s = createStringToSign(scope, context)
      signing_key = getSigningSalt
      signature = OpenSSL::HMAC.hexdigest(@hash_algo, signing_key, s2s)

      return signature
    end

    def createStringToSign(scope, context)
      scopeHash = OpenSSL::Digest.new(@hash_algo, scope)
      contextHash = OpenSSL::Digest.new(@hash_algo, context)
      return sprintf "SIGNER-HMAC-%s\n%s\n%s\n%s\n%s", @hash_algo.upcase, @self_key, @client_id, scopeHash, contextHash
    end

    def generateQueryStringParams(payload)
      signedToken = sign(payload)
      payload['client_id'] = @client_id
      payload['stoken'] = signedToken
      qsa = Array.new

      payload.keys.sort.each do | key |
        qsa.push sprintf("%s=%s", key, payload[key])
      end

      return qsa.join("&")
    end
  end
end
