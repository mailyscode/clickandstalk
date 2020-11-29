require 'webdrivers'
require 'selenium-webdriver'


class ScrappingJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    @user = User.find(user_id)
    scrap_insta
    scrap_linkedin
    collect_tweets
    # send email
  end

  private

  def scrap_insta
    username_insta = @user.username_insta
    # connexion au lien
    driver = Selenium::WebDriver.for :chrome
    driver.navigate.to "https://www.instagram.com/#{username_insta}"
    # autorisation des cookies
    driver.find_element(:css, '.aOOlW.bIiDR').click
    sleep 2

    driver.find_element(:css, '.y3zKF').click

    # recupere les inputs et ecrit dedans
    inputs = driver.find_elements(:css, '._2hvTZ.pexuQ.zyHYP')

    inputs[0].send_keys('clickandstalk')
    inputs[1].send_keys('rengE4-qefwac-xatzoc')

    sleep 2
    # recupere le bouton log in et click dessus avec nos identifiants
    driver.find_elements(:css, '.sqdOP.L3NKy.y3zKF').last.click

    sleep 2
    # on re navigate_to l'url pour skip les settings insta
    driver.navigate.to "https://www.instagram.com/#{username_insta}"

    # on scrool en bas et recupere les photo
    img_urls = []
    20.times do
      begin
        driver.execute_script('window.scrollTo(0, document.body.scrollHeight)')
        elements = driver.find_elements(:css, '.KL4Bh img')
        elements.each do |img|
          img_urls << img.attribute('src')
        end
        sleep 2
      rescue Selenium::WebDriver::Error::StaleElementReferenceError
      end
    end
    img_urls.uniq.each do |url|
      resource = Resource.new(
        data_type: "insta",
        data: {
          url: url
        }
      )
      resource.user = @user
      resource.save
    end
    driver.quit
  end

  def scrap_linkedin
    username_linkedin = @user.username_linkedin
    # code pour le scrap linkedin
    driver = Selenium::WebDriver.for :chrome

    begin
      # Navigate to URL
      driver.get 'https://linkedin.com'
      sleep 3
      # Get search box element from webElement 'q' using Find Element
      inputs = driver.find_elements(:css, '.sign-in-form__form-input-container input')
      sleep 2
      inputs[0].send_keys("clickandstalk@gmail.com")
      inputs[1].send_keys("654321click")
      sleep 3
      driver.find_element(:css, '.sign-in-form__submit-button').click
      sleep 5
      # Redirect to the user's page
      driver.get "https://linkedin.com/in/#{username_linkedin}"
      sleep 5

      # Get user's avatar + headline
      avatar = driver.find_element(:css, '.presence-entity.pv-top-card__image.presence-entity--size-9.ember-view img')
      avatar_url = avatar.attribute('src')
      sleep 5
      headline = driver.find_element(:css, '.ph5.pb5 h2').attribute("innerHTML").strip
      sleep 5

      # Click 'view more'
      scroll_down = driver.find_elements(:css, '.pv-profile-section__actions-inline button')
      scroll_down.each(&:click)
      view_more = driver.find_elements(:css, '.inline-show-more-text__button')
      view_more.each { |btn| btn.click }
      sleep 5

      # Get user's Experiences
      experiences = []
      experience_images = driver.find_elements(:css, '.pv-entity__logo.company-logo img')
      experience_roles = driver.find_elements(:css, '.pv-entity__summary-info h3')
      experience_companies = driver.find_elements(:css, '.pv-entity__secondary-title')
      experience_dates = driver.find_elements(:css, '.pv-entity__date-range span:nth-child(2)')

      (0...experience_images.count).to_a.each do |i|
        experiences << {
          image: experience_images[i].attribute('src'),
          role: experience_roles[i].attribute("innerHTML"),
          company: experience_companies[i].attribute("innerHTML").strip.gsub("\n<!---->", ''),
          date: experience_dates[i].attribute("innerHTML")
        }
      end
      sleep 5

      # Get user's education
      education = []
      education_cards = driver.find_elements(:css, '#education-section .pv-profile-section__list-item')
      education_cards.each do |card|
        company_img = card.find_element(:css, '.pv-entity__logo img').attribute('src')
        date = card.find_element(:css, '.pv-entity__dates span:nth-child(2)').text
        education << {
          school: card.find_element(:css, '.pv-entity__degree-info h3').attribute('innerHTML'),
          diploma_level: card.find_element(:css, '.pv-entity__secondary-title.pv-entity__degree-name span:nth-child(2)').attribute('innerHTML'),
          diploma_type: card.find_element(:css, '.pv-entity__secondary-title.pv-entity__fos span:nth-child(2)').attribute('innerHTML'),
          school_logo: company_img,
          date: date
        }
      end
      sleep 5

      # Save linkedin data in Resources
      Resource.create(
        data_type: "linkedin",
        data: { avatar_url: avatar_url },
        user: @user
      )

      Resource.create(
        data_type: "linkedin",
        data: { headline: headline },
        user: @user
      )

      experiences.each do |info|
        @resource = Resource.new(
          data_type: "linkedin",
          data: { experiences: info }
        )
        @resource.user = @user
        @resource.save
      end

      education.each do |info|
        @resource = Resource.new(
          data_type: "linkedin",
          data: { education: info }
        )
        @resource.user = @user
        @resource.save
      end
    end
  end

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

  def check_tweets
  gbot = Grammarbot::Client.new(api_key: 'grammarbot_default_key', language: 'en-US', base_uri: 'http://api.grammarbot.io')
    gbot.api_key = 'new_api_key'
    gbot.language = 'en-GB'
    gbot.base_uri = 'http://pro.grammarbot.io'
    tweets = client.user_timeline(count: 10, include_rts: false)
    tweets.each do |tweet|
      @resource = Resource.new(
        data_type: "twitter",
        data: { content: tweet.text.check_tweets }
      )
      @resource.user = @user
      @resource.save
    end
    results = gbot.check(tweets)
  end


  def profanity
  end

  def resource_params
    params.require(:resource).permit(:data_type, :data)
  end
end
