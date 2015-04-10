

class ApiController < ApplicationController

  skip_before_filter :verify_authenticity_token
  before_action :get_user, only: [:result, :resultjs]

  include ApiHelper

  def addhost
    @rawurl = params['host']
    user = User.where(:email=>params['email'], :key=>params['key']).take
    @error, @msg = Userhost.add_user_host(user, @rawurl, request.env['HTTP_X_FORWARDED_FOR'] || request.remote_ip, true)
    render :json => {error:@error, msg:@msg}
  end

  def addhostp
    @rawurl = params['host']
    user = User.where(:email=>params['email'], :key=>params['key']).take
    @error, @msg = Userhost.add_user_host(user, @rawurl, request.env['HTTP_X_FORWARDED_FOR'] || request.remote_ip, true)
    render :json => {error:@error, msg:@msg}
  end

  def result
    #response.headers["Content-Type"] = 'application/json'
    @error, @mode, @results, @tags = search_url(@query, @page, 1000)
    render :json => {error:@error, query:@query.force_encoding('utf-8'), mode:@mode, results:@results.map{|x| x.host }}.to_json
  end

  def resultjs
    response.headers["Content-Type"] = 'application/x-javascript'
    @error, @mode, @results, @tags = search_url(@query, @page, 1000)
    render :json => {error:@error, query:@query.force_encoding('utf-8'), mode:@mode, results:@results.map{|x| x.host }}.to_json, :callback=>params['callback']
  end

  def ip
    render :text => request.env['HTTP_X_FORWARDED_FOR'] || request.remote_ip
  end

  def ascii
  end

private
  def get_user
    user = User.where(:email=>params['email'], :key=>params['key']).take
    if user
      @query = ''
      @page = 1
      @page = params['page'].to_i if params['page'] && params['page'].to_i>1
      @query = Base64.decode64(params['qbase64']) if params['qbase64'] && params['qbase64'].size>2
      ip = request.env['HTTP_X_FORWARDED_FOR'] || request.remote_ip
      apicall = Apicall.create(user: user, query: @query, ip: ip, action: "result")
      apicall.save

      check_badge
      if @page>1
        if user.badges.size<1
          render :json => {error:'用户等级不是高级账户，请进行帐号充值！'}
        end
      end
    else
      render :json => {error:'用户认证失败，请确认conf/fofa.yml文件中的信息配置正确。API KEY请登录到fofa的管理后台获取！'}
    end
  end

end
