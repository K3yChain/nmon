class PagesController < ApplicationController
  def index
    auth = {:username => 'stuff@logi-tek.net', :password => 'tina2000'}
    query = {'host' => 'cloudpassage.com', 'type' => 'http'}
    @ = HTTParty.get('https://api.pingdom.com/api/2.0/single', headers: {"app-key" => "2j7igy6801oc1cw1yrm0xyozbsmx9p97"}, :basic_auth => auth, :query => query).body
  end
end