class UsersController < ApplicationController
  def connect
    @user = current_user
  end

  def dashboard
    @user = current_user
  end

  def checkme
    ScrappingJob.perform_later(current_user.id)
    redirect_to dashboard_path
  end

  def twitter_page
  end

  def instagram_page
  end

  def linkedin_page
  end
end
