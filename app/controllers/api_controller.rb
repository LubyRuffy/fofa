

class ApiController < ApplicationController

  skip_before_filter :verify_authenticity_token
  before_action :get_user, only: [:result]

  include ApiHelper

  def addhost
    @rawurl = params['host']
    @error, @msg = Userhost.add_user_host(@rawurl,request.env['HTTP_X_FORWARDED_FOR'] || request.remote_ip, true)
    render :json => {error:@error, msg:@msg}
  end

  def addhostp
    @rawurl = params['host']
    @error, @msg = Userhost.add_user_host(@rawurl,request.env['HTTP_X_FORWARDED_FOR'] || request.remote_ip, true)
    render :json => {error:@error, msg:@msg}
  end

  def result

    @error, @mode, @results, @tags = search(@query, 10000)

    render :json => {error:@error, query:@query, mode:@mode, results:@results.map{|x| x.host }}
  end

private
  def get_user
    user = User.where(:email=>params['email'], :key=>params['key']).take
    unless user
      render :json => {error:'用户认证失败'}
    else
      @query = ''
      @query = Base64.decode64(params['qbase64']) if params['qbase64'] && params['qbase64'].size>2
      ip = request.env['HTTP_X_FORWARDED_FOR'] || request.remote_ip
      apicall = Apicall.create(user: user, query: @query, ip: ip, action: "result")
      apicall.save
    end
  end

end
