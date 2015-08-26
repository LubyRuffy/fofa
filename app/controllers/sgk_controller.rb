

class SgkController < ApplicationController
  before_filter :require_user
  layout 'member'

  def index
    if params[:q] && params[:q].size>0
      @q = {query:     { query_string:  { query: params[:q] } },
           highlight: { pre_tags:["<mark>"], post_tags:["</mark>"], fields: { '*'=> {} } } }
      @sgk = Sgk.search( @q ).paginate(:page => params[:page],:per_page => 20)
    end
  end

  def crack
    if params[:md5]
      type = params[:md5].include?(':') ? 8 : 0
      text = crack_md5(params[:md5], Rails.configuration.x.cmd5.email, Rails.configuration.x.cmd5.password.to_s, type)
      if text
        render json: {error:false, text:text}
      else
        render json: {error:true, errmsg:'没有查到结果！'}
      end
    else
      render json: {error:true, errmsg:'无效参数！'}
    end
  end

end

