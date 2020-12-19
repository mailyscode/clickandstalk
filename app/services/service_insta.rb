require 'uri'
require 'net/http'
require 'webdrivers'
require 'selenium-webdriver'
require 'json'

class ServiceInsta < ApplicationService
  def initialize(user_id)
    @user = User.find(user_id)
    @username = @user.username_insta
    Selenium::WebDriver::Chrome::Service.driver_path = ENV['CHROMEDRIVER_PATH']
    @driver = Selenium::WebDriver.for :chrome
    @post_urls_and_img = []
    @result = []
  end

  def call
    allow_cookies
    connection
    collect_img_url
    collect_likes_views_loc
    quit_driver
    check_nudity
    create_resource
  end

  private

  def allow_cookies
    # autorisation des cookies
    @driver.navigate.to "https://www.instagram.com/#{@username}"
    @driver.find_element(:css, '.aOOlW.bIiDR').click
    sleep 2
  end

  def connection
    # on click sur se connecter
    @driver.find_element(:css, '.y3zKF').click
    # recupere les inputs et ecrit dedans
    inputs = @driver.find_elements(:css, '._2hvTZ.pexuQ.zyHYP')
    # on ecrit les identifiants du compte clickandstalk
    inputs[0].send_keys(ENV['INSTA_ID'])
    inputs[1].send_keys(ENV['INSTA_MDP'])
    sleep 2
    # recupere le bouton log in et click dessus avec nos identifiants
    @driver.find_elements(:css, '.sqdOP.L3NKy.y3zKF').last.click
    sleep 5
  end

  def collect_img_url
    @driver.navigate.to "https://www.instagram.com/#{@username}"
    sleep 2
    5.times do
      begin
        @driver.execute_script('window.scrollTo(0, document.body.scrollHeight)')
        urls = @driver.find_elements(:css, '.v1Nh3.kIKUG._bz0w a')
        imgs = @driver.find_elements(:css, '.KL4Bh img')
        (0...imgs.count).each do |i|
          @post_urls_and_img << {
            img: imgs[i].attribute('src'),
            url: urls[i].attribute('href')
          }
        end
        sleep 2
      rescue Selenium::WebDriver::Error::StaleElementReferenceError
      end
    end
  end

  def collect_likes_views_loc
    @result = @post_urls_and_img.uniq
    @result.each do |post_insta|
      @driver.navigate.to "#{post_insta[:url]}"
      sleep 2
      begin
        post_insta[:localisation] = @driver.find_element(:css, '.O4GlU').attribute('innerHTML').strip
      rescue Selenium::WebDriver::Error::NoSuchElementError
        post_insta[:localisation] = nil
      end
      begin
        post_insta[:like] = @driver.find_element(:css, '.Nm9Fw span').attribute('innerHTML').strip.gsub(/\s/, '').to_i
      rescue Selenium::WebDriver::Error::NoSuchElementError
        post_insta[:view] = @driver.find_element(:css, '.vcOH2 span').attribute('innerHTML').strip.gsub(/\s/, '').to_i
      end
      post_insta[:nudity] = false
    end
  end

  def create_resource
    @result.each do |post|
      Resource.create(
        data_type: 'insta',
        data: post,
        user: @user
      )
    end
  end

  def quit_driver
    @driver.quit
  end

  def check_nudity
    urls = @result.map { |post| post[:img] }
    p urls
    url = URI('https://app.nanonets.com/api/v2/ImageCategorization/LabelUrls/')
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(url)
    request["accept"] = 'application/x-www-form-urlencoded'
    request.basic_auth ENV['NUDITY_API_KEY'], ''
    request.set_form_data({ 'modelId' => '353cea12-4dcc-47ee-b139-dd345157b17d', 'urls' => urls })
    responses = http.request(request)
    responses = JSON.parse(responses.read_body)
    p responses
    responses["result"].each do |response|
      if response['prediction'][0]["label"] == "nsfw"
        p response['prediction'][0]["label"]
        p response['prediction'][0]["probability"]
        post = @result.select { |post_insta| post_insta[:img] == response["file"] }.first
        p post
        post[:nudity] = true if response['prediction'][0]["probability"] > 0.90
      end
    end
  end
end
