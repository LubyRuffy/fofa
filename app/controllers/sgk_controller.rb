
class SgkController < ApplicationController
  layout 'member'

  def index
    if params[:q] && params[:q].size>0
      q = {query:     { query_string:  { query: "#{params[:q]}" } } }
      @sgk = Sgk.search( q.to_json ).paginate(page: params[:page],per_page: 20)
    end

  end

end

