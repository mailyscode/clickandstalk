
class ScrappingJob < ApplicationJob
  queue_as :default

  def perform(user)
    # scrap_insta(user.username_insta)
    # scrap_linked_in(user.username_linkedin)
    collect_tweets(user.twitter_oauth_data)
    # send email
  end

  private

  def scrap_insta(username_insta)
    # code pour le scrap d'insta
  end

  def scrap_linked_in(username_twitter)
    # code pour le scrap linked in
  end

  def collect_tweets(twitter_oauth_data)
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV["TWITTER_API_KEY"]
      config.consumer_secret     = ENV["TWITTER_API_KEY_SECRET"]
      config.access_token        = twitter_oauth_data["token"]
      config.access_token_secret = twitter_oauth_data["secret"]
    end
    tweets = client.home_timeline(count: 100)
    # code pour recuperer les tweets
  end
end
