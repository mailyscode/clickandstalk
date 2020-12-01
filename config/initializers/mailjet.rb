Mailjet.configure do |config|
  config.api_key = ENV['MAILJET_API']
  config.secret_key =ENV['MAILJET_API_SECRET']
  config.default_from = 'clickandstalk@gmail.com'
end
