# lib/url_api.rb
require 'httparty'

class UrlApi
  API_URL = 'https://api.pingdom.com/api/2.0/checks'

  def unique_url
    response = HTTParty.get(API_URL)
    # TODO more error checking (500 error, etc)
    json = JSON.parse(response.body)
    json['url']
  end
end