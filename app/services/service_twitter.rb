require 'net/http'

class ServiceTwitter < ApplicationService
  def initialize(user_id)
    @user = User.find(user_id)
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV["TWITTER_API_KEY"]
      config.consumer_secret     = ENV["TWITTER_API_KEY_SECRET"]
      config.access_token        = @user.twitter_oauth_data["token"]
      config.access_token_secret = @user.twitter_oauth_data["secret"]
    end
    @tweets = @client.user_timeline(count: 10, include_rts: false)
    @hashtags = {}
  end

  def call
    collect_tweet
    check_grammar
    # profanity
    collect_hashtags
  end

  private

  def collect_tweet
    @tweets.each do |tweet|
      @resource = Resource.new(
        data_type: "twitter",
        data: {
          username: tweet.user.screen_name,
          content: tweet.text,
          date: tweet.created_at,
          place: tweet.place.full_name,
          mistake: [],
          profanity: {}
        }
      )
      @resource.user = @user
      @resource.save!
    end
  end

  def check_grammar
    gbot = Grammarbot::Client.new(api_key: ENV["GRAMAR_BOT_KEY"], language: 'en-US', base_uri: 'http://api.grammarbot.io')
    # gbot.api_key = 'new_api_key'
    # gbot.language = 'en-GB'
    # gbot.base_uri = 'http://pro.grammarbot.io'

    @user.resources.where(data_type: "twitter").each do |resource|
      checked = gbot.check(resource.data["content"])
      checked.matches.each do |check|
        if check.rule['issueType'] == "grammar" || check.rule['issueType'] == "misspelling"
          data = resource.data
          data["mistake"] << [check.rule['issueType'], check.context.text[check.offset...check.offset + check.length]]
          resource.update(data: data)
          if check.rule['issueType'] == ""


          end
        end
      end
    end
  end

  def collect_hashtags
    @tweets.each do |tweet|
      tweet.text.split.each do |word|
        if word.chars.first == "#"
          if @hashtags["#{word}"].nil?
            @hashtags["#{word}"] = 1
          else
            @hashtags["#{word}"] += 1
          end
        end
      end
    end
    Resource.create!(
      data_type: 'twitter',
      data: {
        hashtag: @hashtags.sort_by { |word, value| -value }.first(5)
      },
      user: @user
    )
  end

  def profanity
    url = URI("https://api.promptapi.com/bad_words?censor_character=*")

    https = Net::HTTP.new(url.host, url.port);
    https.use_ssl = true

    responses = []
    request = Net::HTTP::Post.new(url)
    request['apikey'] = "P9EuaEEertmGmaMxaaWhmpQzLTKtM36i"
    @tweets.each do |tweet|
      request.body = tweet.text
      responses << https.request(request).read_body
    end
  end
end
