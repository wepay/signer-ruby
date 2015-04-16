# Copyright (c) 2015 WePay.
#
# Based on a stripped-down version of the AWS Signature v4 implementation.
#
# http://opensource.org/licenses/Apache2.0

require 'openssl'

# The root WePay namespace.
module WePay

  # The Signer class is designed for those who are signing data on behalf of a public-private keypair.
  #
  # In principle, the "client party" has public key (i.e., `client_id`) has a matching private key
  # (i.e., `client_secret`) that can be verified by both the signer, as well as the client, but
  # by nobody else as we don't want to make forgeries possible.
  #
  # The "signing party" has a simple an identifier which acts as an additional piece of entropy in the
  # algorithm, and can help differentiate between multiple signing parties if the client party does
  # something like try to use the same public-private keypair independently of a signing party
  # (as is common with GPG signing).
  #
  # For example, in the original AWS implementation, the "self key" for AWS was "AWS4".
  class Signer

    # Constructs a new instance of this class.
    #
    # @param client_id [String] A string which is the public portion of the keypair identifying the client party. The
    #     pairing of the public and private portions of the keypair should only be known to the client party and the
    #     signing party.
    # @param client_secret [String] A string which is the private portion of the keypair identifying the client party.
    #     The pairing of the public and private portions of the keypair should only be known to the client party and
    #     the signing party.
    # @option options [String] self_key (WePay) A string which identifies the signing party and adds additional entropy.
    # @option options [String] hash_algo (sha512) The hash algorithm to use for signing.
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

    # Gets the self key that was set in the constructor.
    #
    # @return [String] The self key.
    def get_self_key
      @self_key
    end

    # Gets the client key that was set in the constructor.
    #
    # @return [String] The client key.
    def get_client_id
      @client_id
    end

    # Gets the client secret that was set in the constructor.
    #
    # @return [String] The client secret.
    def get_client_secret
      @client_secret
    end

    # Sign the payload to produce a signature for its contents.
    #
    # @param payload [Hash] The data to generate a signature for.
    # @option payload [required, String] token The one-time-use token.
    # @option payload [required, String] page The WePay URL to access.
    # @option payload [required, String] redirect_uri The partner URL to return to once the action is completed.
    # @return [String] The signature for the payload contents.
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

    # Signs and generates the query string URL parameters to use when making a request.
    #
    # @param  payload [Hash] The data to generate a signature for.
    # @option payload [required, String] token The one-time-use token.
    # @option payload [required, String] page The WePay URL to access.
    # @option payload [required, String] redirect_uri The partner URL to return to once the action is completed.
    # @option payload [required, String] stoken The signed token that is a result of a call to the `sign()` method.
    # @return [String] The query string parameters to append to the end of a URL.
    def generate_query_string_params(payload)
      signed_token = sign(payload)
      payload['client_id'] = @client_id
      payload['stoken'] = signed_token
      qsa = Array.new

      payload.keys.sort.each do | key |
        qsa.push sprintf("%s=%s", key, payload[key])
      end

      return qsa.join("&")
    end

private

    # Creates the string-to-sign based on a variety of factors.
    #
    # @param scope [String] The results of a call to the `create_scope()` method.
    # @param context [String] The results of a call to the `create_context()` method.
    # @return [String] The final string to be signed.
    def create_string_to_sign(scope, context)
      scope_hash = OpenSSL::Digest.new(@hash_algo, scope)
      context_hash = OpenSSL::Digest.new(@hash_algo, context)
      return sprintf "SIGNER-HMAC-%s\n%s\n%s\n%s\n%s", @hash_algo.upcase, @self_key, @client_id, scope_hash, context_hash
    end

    # An array of key-value pairs representing the data that you want to sign.
    # All values must be `scalar`.
    #
    # @param  payload [Hash] The data that you want to sign.
    # @option payload [String] self_key (WePay) A string which identifies the signing party and adds additional entropy.
    # @return [String] A canonical string representation of the data to sign.
    def create_context(payload)
      canonical_payload = ""

      payload.keys.sort.each do | key |
        val = payload[key].downcase
        key = key.downcase
        canonical_payload = canonical_payload + sprintf("%s=%s\n", key, val)
      end

      signed_headers_string = payload.keys.sort.join(";")
      canonical_payload + "\n" + signed_headers_string
    end

    # Gets the salt value that should be used for signing.
    #
    # @return [String] The signing salt.
    def get_signing_salt
      self_key_sign = OpenSSL::HMAC.digest(@hash_algo, @client_secret, @self_key)
      client_id_sign = OpenSSL::HMAC.digest(@hash_algo, self_key_sign, @client_id)
      salt = OpenSSL::HMAC.digest(@hash_algo, client_id_sign, 'signer')
      return salt
    end

    # Creates the "scope" in which the signature is valid.
    #
    # @return [String] The string which represents the scope in which the signature is valid.
    def create_scope
      return sprintf "%s/%s/signer", @self_key, @client_id
    end

  end
end
