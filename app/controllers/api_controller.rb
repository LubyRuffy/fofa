

class ApiController < ApplicationController
  include ApiHelper

  def addhost
    @rawurl = params['host']
    @error, @msg = Userhost.add_user_host(@rawurl,request.env['HTTP_X_FORWARDED_FOR'] || request.remote_ip)
    render :json => {error:@error, msg:@msg}
  end

  def addhostp
    @rawurl = params['host']
    @error, @msg = Userhost.add_user_host(@rawurl,request.env['HTTP_X_FORWARDED_FOR'] || request.remote_ip)
    render :json => {error:@error, msg:@msg}
  end

  def result
    @query = ''
    @query = Base64.decode64(params['qbase64']) if params['qbase64'] && params['qbase64'].size>2
    @error, @mode, @results, @tags = search(@query, 10000)

    render :json => {error:@error, query:@query, mode:@mode, results:@results.map{|x| x.host }}
  end
end
