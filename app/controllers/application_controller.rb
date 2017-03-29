class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :require_sign_in

  helper_method :current_user

  def current_user
     @current_user ||= (User.find_by_email(session[:user_email]) || nil)
  end

  def require_sign_in
    if current_user.nil?
      redirect_to sign_in_path
    end
  end

  def require_edit_privileges
    if not current_user.can_edit?
      flash[:error] = "You don't have edit privileges."
      redirect_to root_path
    end
  end

  def require_delete_privileges
    if not current_user.can_delete?
      flash[:error] = "You don't have deleting privileges."
      redirect_to root_path
    end
  end
end
