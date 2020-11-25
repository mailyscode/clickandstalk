class UsersController < ApplicationController
  def connect
    @user = current_user
  end

  def dashboard
  end
end
