class ScrappingJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    @user = User.find(user_id)
    # ScrappingInsta.new(user_id).perform unless @user.username_insta
    ScrappingLinkedin.new(user_id).perform if @user.username_linkedin
    # ScrappingTwitter.new(user_id).perform
    # send email
    # mail = UserMailer.job_finish
    # mail.deliver_now
  end
end
