class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token

  def linkedin
    current_user.update(linked_oauth_data: request.env['omniauth.auth'])
    sign_in_and_redirect current_user, :event => :authentication
    set_flash_message(:notice, :success, :kind => "linkedin") if is_navigational_format?
  end

  # def twitter
  #   current_user.update(twitter_oauth_data: request.env['omniauth.auth'])
  #   sign_in_and_redirect @user, :event => :authentication
  #   set_flash_message(:notice, :success, :kind => provider_name) if is_navigational_format?
  # end
end
