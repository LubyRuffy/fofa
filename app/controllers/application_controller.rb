# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :set_charset
  def set_charset
    headers["Content-Type"] = "text/html; charset=UTF-8"
  end
end
