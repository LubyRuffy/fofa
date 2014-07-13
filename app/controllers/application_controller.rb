# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :set_charset
  before_action :configure_permitted_parameters, if: :devise_controller?

  def set_charset
    headers["Content-Type"] = "text/html; charset=UTF-8"
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

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation, :remember_me) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :username, :email, :password, :remember_me) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :current_password, :avatar) }
  end

=begin
  def after_sign_in_path_for(resource)
    '/my/'
  end
=end
end
