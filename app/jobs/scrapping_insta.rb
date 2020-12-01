class ScrappingInsta < ApplicationJob
  queue_as :default

  def initialize(user_id)
    # @service = ServiceInsta.new(user_id)
  end

  def perform
    # @service.call
  end
end
