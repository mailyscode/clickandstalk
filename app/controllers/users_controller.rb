class UsersController < ApplicationController
  def connect
    @user = current_user
  end

  def dashboard
    @user = current_user
  end

  def checkme
    ScrappingJob.perform_later(current_user)
    redirect_to dashboard_path
  end
end
