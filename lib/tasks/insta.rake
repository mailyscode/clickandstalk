namespace :insta do
  task scrap_example: :environment do
    Selenium::WebDriver::Chrome::Service.driver_path = ENV['CHROMEDRIVER_PATH']
    driver = Selenium::WebDriver.for :chrome

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

    puts "==================================="
    puts "Elon Musk has #{followers} followers"
  end
end
