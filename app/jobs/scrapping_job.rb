class ScrappingJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    ScrappingLinkedin.new(user_id).perform
    # ScrappingInsta.new(user_id).perform
    ScrappingTwitter.new(user_id).perform
    # send email
    # mail = UserMailer.job_finish
    # mail.deliver_now
  end
end
