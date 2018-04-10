class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
    @users  = User.all

    # POST or PUT with a hash sends parameters as a urlencoded form body
    RestClient.post 'https://api-sandbox.abnamro.com/v1/oauth/token', :param1 => 'one'
  end

  response = RestClient::Request.new({
      method: :post,
      url: 'https://api-sandbox.abnamro.com/v1/oauth/token',
      headers: { accept: :json, content_type: 'application/x-www-form-urlencoded',
        api_key: ABN_API_KEY },
      form-data: {
        client_assertion: (JSON Web token required to authenticate client),
        client_assertion_type: urn:ietf:params:oauth:client-assertion-type:jwt-bearer,
        grant_type: client_credentials }
        #, scope: (the desired scope)(Optional)
    }).execute do |response, request, result|
      case response.code
      when 400
        [ :error, parse_json(response.to_str) ]
      when 200
        [ :success, parse_json(response.to_str) ]
      else
        fail "Invalid response #{response.to_str} received."
      end
    end
end
