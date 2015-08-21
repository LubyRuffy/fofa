

class SgkController < ApplicationController
  layout 'member'

  def index
    if params[:q] && params[:q].size>0
      q = {query:     { query_string:  { query: "#{params[:q]}" } } }
      @sgk = Sgk.search( q.to_json ).paginate(:page => params[:page],:per_page => 20)
    end
  end

  def crack
    if params[:md5]
      text = crack_md5(params[:md5], Rails.configuration.x.cmd5.email, Rails.configuration.x.cmd5.password.to_s)
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

