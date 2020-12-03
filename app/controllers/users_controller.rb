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

  def update
    @user = current_user
    @user.resources.destroy_all
    @user.update(user_params)
    redirect_to connect_path
  end

  def linkedin
    @user = current_user
    @resources = @user.resources.where(data_type: "linkedin")

    Resource::DATA_KEY_LINKEDIN.each do |key|
      value = @user.resources.where(data_type: "linkedin").with_key(key).map(&key)
      instance_variable_set("@#{key.to_s.pluralize}", value)
    end
  end

  def twitter
    @user = current_user
    @resources = @user.resources.where(data_type: "twitter")

    Resource::DATA_KEY_TWITTER.each do |key|
      value = @user.resources.where(data_type: "twitter").with_key(key).map(&key)
      instance_variable_set("@#{key.to_s.pluralize}", value)
    end
  end

  def instagram
    @user = current_user
    @resources = @user.resources.where(data_type: "insta")

    Resource::DATA_KEY_INSTA.each do |key|
      value = @user.resources.where(data_type: "insta").with_key(key).map(&key)
      instance_variable_set("@#{key.to_s.pluralize}", value)
    end
    @most_liked_post = @resources.select { |resource| resource.data["like"] }
                                 .sort_by { |resource| -resource.data["like"] }
                                 .first(5)

    @most_viewed_post = @resources.select { |resource| resource.data["view"] }
                                  .sort_by { |resource| -resource.data["view"] }
                                  .first(5)
  end

  private

  def user_params
    params.require(:user).permit(:username_linkedin, :username_insta)
  end
end
