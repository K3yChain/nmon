class ChecksController < ApplicationController

  def index
    @checks = Check.all
  end

  def api_setup()
    auth = {:username => 'stuff@logi-tek.net', :password => 'tina2000'}
    query = {'host' => @check.check_hostname, 'type' => 'http'}
    response = HTTParty.get('https://api.pingdom.com/api/2.0/checks', headers: {"app-key" => "2j7igy6801oc1cw1yrm0xyozbsmx9p97"}, :basic_auth => auth, :query => query).body
  end

  def create
    @check = Check.create(check_name: params[:check_name], check_hostname: params[:check_hostname], user_id: current_user.id)
    url_check_name = params[:check_name]
    url_hostname = params[:check_hostname]

    auth = {:username => 'stuff@logi-tek.net', :password => 'tina2000'}
    query = {'host' => @check.check_hostname, 'type' => 'http'}
    response = HTTParty.post('https://api.pingdom.com/api/2.0/checks?name=' + url_check_name + '&host=' + url_hostname + '&type=http', headers: {"app-key" => "2j7igy6801oc1cw1yrm0xyozbsmx9p97"}, :basic_auth => auth, :query => query).body
    post_response = JSON.parse(response).to_h
    grabbed_check_id = post_response["check"]["id"]
    p grabbed_check_id
    @check.update(check_id: grabbed_check_id)
  if @check.save
  flash[:success] = "Check Created"
  redirect_to "/checks/#{@check_id}"
  else
    render :new
  end
    
  end

  def new
  end

  def show
    @check = Check.find(params[:id])
    auth = {:username => 'stuff@logi-tek.net', :password => 'tina2000'}
    query = {'host' => @check.check_hostname, 'type' => 'http'}
    response = HTTParty.get('https://api.pingdom.com/api/2.0/checks', headers: {"app-key" => "2j7igy6801oc1cw1yrm0xyozbsmx9p97"}, :basic_auth => auth, :query => query).body
    @checks = JSON.parse(response).to_h
  end

  def destroy
    @check = Check.find_by(id: params[:id])
    auth = {:username => 'stuff@logi-tek.net', :password => 'tina2000'}
    query = {'host' => @check.check_hostname, 'type' => 'http'}
    response = HTTParty.delete('https://api.pingdom.com/api/2.0/checks/' + @check.check_id.to_s, headers: {"app-key" => "2j7igy6801oc1cw1yrm0xyozbsmx9p97"}, :basic_auth => auth, :query => query).body
    post_response = JSON.parse(response).to_h
    @check.destroy
    redirect_to "/checks"
    flash[:danger] = post_response['message']
  end

end