class InstaExample
  def self.followers_elon
    # Requests from server doesn't need to accept a cookie consent

    # Prepare selenium
    Selenium::WebDriver::Chrome::Service.driver_path = ENV['CHROMEDRIVER_PATH']
    caps = Selenium::WebDriver::Remote::Capabilities.new
    caps["screen_resolution"] = "1024x768"

    driver = Selenium::WebDriver.for(:chrome, desired_capabilities: caps)

    begin
      # 1. Sign in to create session cookie
      driver.navigate.to "https://www.instagram.com/accounts/login"
      sleep 5
      # fill in inputs (email/mdp)
      inputs = driver.find_elements(:css, '._2hvTZ.pexuQ.zyHYP')
      inputs[0].send_keys(ENV['INSTA_ID'])
      inputs[1].send_keys(ENV['INSTA_MDP'])
      # submit form
      sleep 2
      driver.find_elements(:css, '.sqdOP.L3NKy.y3zKF').last.click

      sleep 4
      # 2. Navigate to page we want to scrap
      driver.navigate.to "https://www.instagram.com/elonmusk"
      # for example followers count
      followers = driver.find_element(:css, '.Y8-fY a span').attribute('innerHTML')

    # In case of exception, rescue it
    rescue StandardError => e
      # Take a screenshot that will be visible with www.clickandstalk.com/test.png
      driver.save_screenshot("#{Rails.root}/public/test.png")

      # Save HTML file that lead to error, available at www.clickandstalk.com/test.html
      html = driver.find_element(:css, 'html').attribute('innerHTML')
      File.open("#{Rails.root}/public/test.html", 'wb') { |file| file.write(html) }

      # Note : Screenshot and html file won't be available many time, cause heroku
      # destroys new created files that are not coming from git commits on every
      # restart (at least one time per day)

      # Return HTML
      html
    end

    followers
  end
end
