class ScrappingJob < ApplicationJob
  queue_as :default

  def perform(user)
    scrap_insta(user.username_insta)
    scrap_linked_in(user.username_linkedin)
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
    # code pour recuperer les tweets
  end
end
