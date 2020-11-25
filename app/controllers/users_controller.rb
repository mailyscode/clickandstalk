class UsersController < ApplicationController
  def connect
    @user = current_user
  end

  def dashboard
    @user = current_user
  end

end
