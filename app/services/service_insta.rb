class ServiceInsta < ApplicationService
  def initialize(user_id)
    @user = User.find(user_id)
    @username = @user.username_insta
    @driver = Selenium::WebDriver.for :chrome
    @post_urls_and_img = []
    @result = []
  end

  def call
    allow_cookies
    connection
    collect_info
    collect_img_url
    collect_likes_views_loc
    create_most_liked
    create_resource
  end

  private

  def allow_cookies
    # autorisation des cookies
    @driver.navigate.to "https://www.instagram.com/#{@username_insta}"
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

  def collect_info
    # on navigue jusqu'au compte insta et recupere bio plus nb de followers
    @driver.navigate.to "https://www.instagram.com/#{@username_insta}"
    sleep 2
    followers = @driver.find_element(:css, '.Y8-fY a span').attribute('innerHTML')
    bio = @driver.find_element(:css, '.-vDIg span').attribute('innerHTML')
    Resource.create(
      data_type: 'insta',
      data: { info: { followers: followers, bio: bio } },
      user: @user
    )
  end

  def collect_img_url
    10.times do
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
        post_insta[:likes] = @driver.find_element(:css, '.Nm9Fw span').attribute('innerHTML').strip.gsub(/\s/, '').to_i
      rescue Selenium::WebDriver::Error::NoSuchElementError
        post_insta[:views] = @driver.find_element(:css, '.vcOH2 span').attribute('innerHTML').strip.gsub(/\s/, '').to_i
      end
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
end
