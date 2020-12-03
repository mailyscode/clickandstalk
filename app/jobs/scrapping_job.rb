class ScrappingJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    ScrappingInsta.new(user_id).perform unless @user.username_linkedin.nil?
    ScrappingLinkedin.new(user_id).perform unless @user.username_insta.nil?
    ScrappingTwitter.new(user_id).perform unless @user.username_twitter.nil?
    # send email
    mail = UserMailer.job_finish(user_id)
    mail.deliver_now
  end
end
