class ScrappingJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    @user = User.find(user_id)
    ScrappingLinkedin.new(user_id).perform if @user.username_linkedin
    ScrappingTwitter.new(user_id).perform if @user.username_twitter
    ScrappingInsta.new(user_id).perform if @user.username_insta
    # send email
    mail = UserMailer.job_finish(user_id)
    mail.deliver_now
  end
end
