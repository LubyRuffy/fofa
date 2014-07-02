

class ApiController < ApplicationController
  def addhost
    @rawurl = params['host']
    @error, @msg = Userhost.add_user_host(@rawurl,request.env['HTTP_X_FORWARDED_FOR'] || request.remote_ip)
    render :json => {error:@error, msg:@msg}
  end
end
