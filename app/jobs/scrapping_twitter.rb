class ScrappingTwitter < ApplicationJob
  queue_as :default

  def initialize(user_id)
    @service = ServiceLinkedin.new(user_id)
  end

  def perform
    @service.call
  end
end
