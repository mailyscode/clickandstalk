class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :username_insta, :username_twitter, :username_linkedin])

    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :username_insta, :username_twitter, :username_linkedin])
  end
end
