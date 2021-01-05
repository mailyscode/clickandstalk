class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :username_insta, :username_twitter, :username_linkedin])

    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :username_insta, :username_twitter, :username_linkedin])
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || connect_path
  end

  def default_url_options
    { host: ENV["DOMAIN"] || "localhost:3000" }
  end
end
