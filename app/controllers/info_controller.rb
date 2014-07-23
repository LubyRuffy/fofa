class InfoController < ApplicationController
  def gov
    @data = GovSite.select("case when sure_province is not null then sure_province else ip_province_chinese end as province,count(*) as cnt").group("province")
    @data = @data.delete_if {|e| !e["province"]}
  end

  def gov_cnt
    @data = GovSite.select("case when sure_province is not null then sure_province else ip_province_chinese end as province,count(*) as cnt").group("province")
    @data = @data.delete_if {|e| !e["province"]}
    render :json => @data
  end

  def about
  end

  def library
    @all_cnt = Rule.count
    @rules = Rule.where(:published=>1).order('created_at desc').paginate(:page => params[:page],
                                         :per_page => 20)
  end
  
  def contact
  end
end
