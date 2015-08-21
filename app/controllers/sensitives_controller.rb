
class SensitivesController < InheritedResources::Base
  before_action :set_sensitive, only: [:show, :edit, :update, :destroy]
  before_filter :require_user
  layout 'member'

  def index
    if params[:q] && params[:q].size>0
      q = {query:     { query_string:  { query: "content:(\"#{params[:q]}\")" } },
           highlight: { pre_tags:["<mark>"], post_tags:["</mark>"], fields: { content: {} } }}
      @sensitives = Sensitive.__elasticsearch__.search( q.to_json ).paginate(:page => params[:page],
                                                                                       :per_page => 20)
    else
      @sensitives = current_user.sensitives.paginate(:page => params[:page],
                                                    :per_page => 20).order('id DESC')
    end

  end

  def create
    @sensitive = current_user.sensitives.new(sensitive_params)
    respond_to do |format|
      if @sensitive.save
        @sensitive.__elasticsearch__.index_document
        #@sensitive.__elasticsearch__.refresh_index!
        format.html { redirect_to sensitives_url, notice: '创建成功！' }
        format.json { render :show, status: :created, location: @sensitive }
      else
        format.html { render :new }
        format.json { render json: @sensitive.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @sensitive.__elasticsearch__.update_document
    #@sensitive.__elasticsearch__.refresh_index!
    respond_to do |format|
      if @sensitive.update(sensitive_params)
        format.html { redirect_to @sensitive, notice: '更新成功！' }
        format.json { render :show, status: :ok, location: @sensitive }
      else
        format.html { render :edit }
        format.json { render json: @sensitive.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @sensitive.destroy
    @sensitive.__elasticsearch__.delete_document
    #@sensitive.__elasticsearch__.refresh_index!
    respond_to do |format|
      format.html { redirect_to sensitives_url, notice: '删除成功！' }
      format.json { head :no_content }
    end
  end

  def show
  end

  private
    def sensitive_params
      params.require(:sensitive).permit(:reference, :content, :memo)
    end

    def set_sensitive
      @sensitive = current_user.sensitives.find(params[:id]) rescue nil
      if @sensitive.nil?
        flash[:alert] = "目标不存在！"
        return redirect_to sensitives_path
      end
    end
end

