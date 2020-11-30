    def collect_tweets
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV["TWITTER_API_KEY"]
      config.consumer_secret     = ENV["TWITTER_API_KEY_SECRET"]
      config.access_token        = @user.twitter_oauth_data["token"]
      config.access_token_secret = @user.twitter_oauth_data["secret"]
    end
    tweets = client.user_timeline(count: 10, include_rts: false)
    tweets.each do |tweet|
      @resource = Resource.new(
        data_type: "twitter",
        data: { username: tweet.user.screen_name, content: tweet.text, date: tweet.created_at, place: tweet.place.full_name }
      )
      @resource.user = @user
      @resource.save
    end
    hashtags = client.user_timeline(count: 10, include_rts: false)
    hashtags.each do |hashtag|
      @resource = Resource.new(
        data_type: "twitter",
        data: { content: client.search("#") }
      )
      @resource.user = @user
      @resource.save
    end
  end


  def scrap_twitter
  gbot = Grammarbot::Client.new(api_key: ENV["GRAMAR_BOT_KEY"], language: 'en-US', base_uri: 'http://api.grammarbot.io')
    # gbot.api_key = 'new_api_key'
    # gbot.language = 'en-GB'
    # gbot.base_uri = 'http://pro.grammarbot.io'
    tweets = client.user_timeline(count: 10, include_rts: false)
    tweets.each do |tweet|
      @resource = Resource.new(
        data_type: "twitter",
        data: { content: tweet.text.check_tweets }
      @resource.user = @user
      @resource.save
      )
    end
    result = gbot.check(tweet).text
  end

