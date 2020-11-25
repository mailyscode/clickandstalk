class UsersController < ApplicationController
  def connect
    @user = current_user
  end

HEAD
 def dashboard
    @user = current_user
end

end
