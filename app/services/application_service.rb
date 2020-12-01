class ApplicationService
  def self.call(*args, &block)
    new(*args).call(&block)
  end
end
