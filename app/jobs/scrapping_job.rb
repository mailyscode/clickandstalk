require 'webdrivers'
require 'selenium-webdriver'

class ScrappingJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    @user = User.find(user_id)
    # scrap_insta(user.username_insta)
    scrap_linkedin
    # collect_tweets(user.twitter_oauth_data)
    # send email
  end

  private

  def scrap_insta(username_insta)
    # code pour le scrap d'insta
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

  def collect_tweets(twitter_oauth_data)
    # code pour recuperer les tweets
  end


  def resource_params
    params.require(:resource).permit(:data_type, :data)
  end
end
