require 'jwt'
require 'yaml'
require 'rest-client'

def get_api_token
  api_key = YAML.load_file('config/application.yml')['ABN_API_KEY']
  web_token = build_jwt(api_key)

  payload = {
      client_assertion: web_token,
      client_assertion_type: 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
      grant_type: 'client_credentials' }


  response = RestClient.post(
    'https://api-sandbox.abnamro.com/v1/oauth/token',
    {
      :transfer => {
        :path => '/foo/bar',
        :owner => 'that_guy',
        :group => 'those_guys'
      },
       :upload => {
        :file => File.new(path, 'rb')
      }
    },
    { accept: :json, content_type: 'application/x-www-form-urlencoded',
      api_key: api_key
    }
      )
  # response = RestClient::Request.execute({
  #   method: :post,
  #   url: 'https://api-sandbox.abnamro.com/v1/oauth/token',
  #   headers: { accept: :json, content_type: 'application/x-www-form-urlencoded',
  #     api_key: api_key },
  #   # form_data: payload.to_json,
  #   scope: 'tikkie' }) |response, request, result|
  #   p request
  #   case response.code
  #   when 400
  #     [ :error, JSON.parse(response.to_str) ]
  #   when 200
  #     [ :success, JSON.parse(response.to_str) ]
  #   else
  #     fail "Invalid response #{response.to_str} received."
  #   end
  # end
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
