# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  #skip_before_filter :verify_authenticity_token, :only => :create
  #skip_before_filter :verify_authenticity_token, if: -> { (controller_name == 'sessions' && action_name == 'create') || (controller_name == 'my') }
  before_filter :set_charset
  before_filter :store_location
  before_action :configure_permitted_parameters, if: :devise_controller?

  def set_charset
    #headers["Content-Type"] = "text/html; charset=UTF-8" #这一句会导致js的format不可用，改成在每个地方单独设置
  end


  def authenticate_admin_user!
    authenticate_user!
    unless current_user.isadmin?
      flash[:alert] = "哥们，想当管理员呢？"
      redirect_to root_path
    end
  end

  def current_admin_user
    return nil if user_signed_in? && !current_user.isadmin?
    current_user
  end

  def require_user
    if current_user.blank?
      respond_to do |format|
        format.html { authenticate_user! }
        format.all { head(:unauthorized) }
      end
    end
  end

  def check_badge
    if current_user
      current_user.rm_badge(1)
      current_user.rm_badge(2)
      if current_user.duration && current_user.duration>Time.now
        current_user.add_badge(1)
      elsif current_user.points>=1000
        current_user.add_badge(2)
      end
    end
  end

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation, :remember_me) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :username, :email, :password, :remember_me) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :current_password, :avatar) }
  end

  def store_location
    # store last url - this is needed for post-login redirect to whatever the user last visited.
    return unless request.get?
    if (request.path != "/users/sign_in" &&
        request.path != "/users/sign_up" &&
        request.path != "/users/password/new" &&
        request.path != "/users/password/edit" &&
        request.path != "/users/confirmation" &&
        request.path != "/users/sign_out" &&
        !request.xhr?) # don't store ajax calls
      session[:previous_url] = request.fullpath
    end
  end

  def after_sign_in_path_for(resource)
    #puts "=====",session[:previous_url]
    session[:previous_url] || '/my'
  end

end
