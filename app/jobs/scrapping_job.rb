require 'webdrivers'
require 'selenium-webdriver'

class ScrappingJob < ApplicationJob
  queue_as :default

  def perform(user)
    scrap_insta(user.username_insta)
    # scrap_linked_in(user.username_linkedin)
    # collect_tweets(user.twitter_oauth_data)
    # send email
  end

  private

  def scrap_insta(username_insta)
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
      resource = Resources.new(
        data_type: "insta",
        data: {
          url: url
        }
      )
      resource.user = User.where(username_insta: username_insta)
      resource.save
    end
  end

  def scrap_linked_in(username_twitter)
    # code pour le scrap linked in
  end

  def collect_tweets(twitter_oauth_data)
    # code pour recuperer les tweets
  end
end
