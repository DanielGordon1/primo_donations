require 'jwt'
require 'yaml'
require 'uri'
require 'net/http'

def get_api_token
  api_key = YAML.load_file('config/application.yml')['ABN_API_KEY']
  web_token = build_jwt(api_key)

  url = URI("https://api-sandbox.abnamro.com/v1/oauth/token")

  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Post.new(url)
  request["api-key"] = api_key
  request["content-type"] = 'application/x-www-form-urlencoded'
  request["cache-control"] = 'no-cache'
  request.body = "client_assertion_type=urn%3Aietf%3Aparams%3Aoauth%3Aclient-assertion-type%3Ajwt-bearer&grant_type=client_credentials&client_assertion=#{web_token}&scope=tikkie"
  response = http.request(request)
  puts response.read_body
end

def build_jwt(api_key)
  private_key = OpenSSL::PKey::RSA.new(YAML.load_file('config/application.yml')['rsa_private_key'])
  public_key = private_key.public_key

  # get UNIX timestamp
  payload = {
    "nbf": Time.now.to_i,
    "exp": Time.now.to_i + 600,
    "iss": "me",
    "sub": api_key,
    "aud": "https://auth-sandbox.abnamro.com/oauth/token"
  }

  # token = JWT.encode payload, key, algorithm='HS256', header_fields={}
  token = JWT.encode(payload, private_key, 'RS512', { typ: 'JWT' })
  # puts token
  decoded_token = JWT.decode(token, public_key, true, { algorithm: 'RS512' } )
  # puts decoded_token
  return token
end

puts get_api_token
