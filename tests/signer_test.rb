##
# Copyright (c) 2015-2016 WePay
#
# http://opensource.org/licenses/Apache2.0
##

require 'RubyUnit'
require_relative '../lib/wepay-signer'

##
# Test Cases for the WePay::Signer module.
##
class SignerTest < RubyUnit::TestCase

  # Test data
  DEFAULT_CLIENT_ID     = 12173158495
  DEFAULT_CLIENT_SECRET = '1594122c5c36f438f8ba'
  DEFAULT_SIGNATURE     = 'c2de34c15cd76f797cf80781747da3874639a827a4cb79dcd862cc17b35cf2e2c721ea7d49ab9f60590d637ae0f51fd4ed8ddb551b922e0cd7e35a13b86de360'
  DEFAULT_PAGE          = 'https://wepay.com/account/12345'
  DEFAULT_REDIRECT_URI  = 'https://partnersite.com/home'
  DEFAULT_QS            = 'client_id=%s&page=%s&redirect_uri=%s&stoken=%s&token=%s'
  DEFAULT_TOKEN         = '10c936ca-5e7c-508b-9e60-b211c20be9bc'

  ##
  # Setup
  ##
  def setup
    @signer = WePay::Signer.new(DEFAULT_CLIENT_ID, DEFAULT_CLIENT_SECRET)
  end

  def get_self_key_Test
    assertEqual 'WePay', @signer.self_key
  end

  def get_client_key_Test
    assertEqual DEFAULT_CLIENT_ID.to_s, @signer.client_id
  end

  def get_client_secret_Test
    assertEqual DEFAULT_CLIENT_SECRET.to_s, @signer.client_secret
  end

  def get_hash_algo_Test
    assertEqual 'sha512', @signer.hash_algo
  end

  def sign_Test
    signature = @signer.sign({
      :page         => DEFAULT_PAGE,
      :redirect_uri => DEFAULT_REDIRECT_URI,
      :token        => DEFAULT_TOKEN,
    })

    assertEqual DEFAULT_SIGNATURE, signature
  end

  def generate_query_string_params_Test
    querystring = @signer.generate_query_string_params({
      :page         => DEFAULT_PAGE,
      :redirect_uri => DEFAULT_REDIRECT_URI,
      :token        => DEFAULT_TOKEN,
    })

    assertEqual sprintf(DEFAULT_QS, DEFAULT_CLIENT_ID, DEFAULT_PAGE, DEFAULT_REDIRECT_URI, DEFAULT_SIGNATURE, DEFAULT_TOKEN), querystring
  end

  def generate_query_string_params_client_secret_Test
    querystring = @signer.generate_query_string_params({
      :page          => DEFAULT_PAGE,
      :redirect_uri  => DEFAULT_REDIRECT_URI,
      :token         => DEFAULT_TOKEN,
      :client_id     => DEFAULT_CLIENT_ID,
      :client_secret => DEFAULT_CLIENT_SECRET,
    })

    assertEqual sprintf(DEFAULT_QS, DEFAULT_CLIENT_ID, DEFAULT_PAGE, DEFAULT_REDIRECT_URI, DEFAULT_SIGNATURE, DEFAULT_TOKEN), querystring
  end

end
