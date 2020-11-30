class ScrappingJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    # ScrappingInsta.new(user_id)
    ScrappingLinkedin.new(user_id).perform
    # ScrappingTwitter.new(user_id)
    # send email
  end
end
