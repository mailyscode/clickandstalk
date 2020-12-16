require 'nokogiri'
require 'json'
require 'open-uri'
require 'webdrivers'
require 'selenium-webdriver'

# frozen_string_literal: true
class ServiceLinkedin < ApplicationService
  def initialize(user_id)
    @user = User.find(user_id)
    @username_linkedin = @user.username_linkedin

    @regex = %r{<code.+>\n.+linkedin.voyager.dash.deco.identity.profile.FullProfileWithEntities.+"bpr-guid-(?<number>\d+)".+\n</code>}
    cookie = 'bcookie="v=2&8d4de218-f365-4785-8ec4-488a7cd8df83"; lissc=1; _ga=GA1.2.2109408691.1600070630; bscookie="v=1&20200914080350b1e64427-1eff-48f0-805c-1f4047e3de47AQElS72kdNEMOgZCqk3PbS5hhvX2SOV2"; _guid=c69c76a6-8dd8-4d6a-a41e-7fd09738f30d; aam_uuid=27529958338370129522117145318627435778; _gcl_au=1.1.2138693077.1600348498; li_oatml=AQHScFAMa6HVjgAAAXW97FY9X42ETEks2-rQEFdo4IU54z6NyyheGtdxi5Bbt32DI9rlxbrp4Vkp_D1Iyc_OTDAHhgvZyx_9; spectroscopyId=80571c54-ee23-4160-b147-38a6504d4ec6; AMCVS_14215E3D5995C57C0A495C55%40AdobeOrg=1; visit=v=1&M; li_rm=AQFCDROLx0Px9AAAAXX53tver4sfBHFHrS1VHSlS-87lppfwYHOoZCg-_av6FmPYUsErKASFVnCVND33MdepmlJLyt6MH7W97XJQ8tssDv3C7WL3vJWIjc8c; li_gc=MTsyMTsxNjA2MjE1MTQ1OzI7MDIxBNVyC/dvQ7mqxAorPQTz3faby9tG3gUWec3fmfChzeQ=; SID=f8922a49-2c34-4c5e-b01d-9652aa1e6f0f; VID=V_2020_11_25_09_1813; sdsc=22%3A1%2C1606324047974%7ECONN%2C0m5INWUzDDwXy9z9K7y6ncymOXd4%3D; _gid=GA1.2.1945203952.1606946773; AnalyticsSyncHistory=AQJiGNuzEEusrAAAAXYoUMR34kxr6KiWA8FCETP6z53KSI86wiGL4t_ihBgO_L49K_JKP10SmLR4spTWR7yX5w; lms_ads=AQHiQ9IBC4LI3gAAAXYoUMcJ0sn7s50wSe_8Zhvxz88tgxW32xQKh-Xj1g8BVQQQPBF9563MkcmEGdhrGQ96bCjNO0iabjj5; lms_analytics=AQHiQ9IBC4LI3gAAAXYoUMcJ0sn7s50wSe_8Zhvxz88tgxW32xQKh-Xj1g8BVQQQPBF9563MkcmEGdhrGQ96bCjNO0iabjj5; g_state={"i_p":1607105580419,"i_l":2}; lang=v=2&lang=fr-fr; li_at=AQEDASEhzx8AG0jvAAABdizd1SAAAAF2UOpZIE0AsQbe4BsDaLDRlwlodMepr0s3S2Lq0xEtI8xHyZLAvjwP5Gt2hKJgW0t69ZGos-Vm-3KFGRMK-3vpCI0HMwoBJyEDme3QaMpvtG2J4Z2qWgM3S7vb; liap=true; JSESSIONID="ajax:8787665354130132957"; AMCV_14215E3D5995C57C0A495C55%40AdobeOrg=-637568504%7CMCIDTS%7C18600%7CMCMID%7C28090368562717460672138844027118261961%7CMCAAMLH-1607675316%7C6%7CMCAAMB-1607675316%7C6G1ynYcLPuiQxYZrsz_pkqfLG9yMXBpb2zX5dvJdYQJzPXImdj0y%7CMCOPTOUT-1607077716s%7CNONE%7CvVersion%7C5.1.1%7CMCCIDH%7C1711301840; UserMatchHistory=AQJYWn7kjyH9HgAAAXYs3u1BcNE3WZjMoHmLqX3LWACWKL1zFv3sRqT8sS_4daPuzxRSa1qTacI8rAsZJwGDprdJcbjC3SAmuoGw1wXWXNnPlopAmyvUuVXRAU2kfMN_Efh0Cp-oWfo9RXTMPum0l64wbzgoOlB68h1ImaYDjkOW85lq-ucRdWHd9TbeFjGrZ9ck-yh1mbs4VhucDQP5hGA537tzgddyIeUpff-DzPG23Pybv3asUNonnzFqoocAgpHZVGh5oWi8WuoTobLYbWE_6wJVNM3UTJsM014; lidc="b=VB39:s=V:r=V:g=3351:u=43:i=1607070578:t=1607156904:v=1:sig=AQFmXKBbTtkoXVGlA7xGrbiy5fPjhxv0"; li_mc=MTsyMTsxNjA3MDcxNDU2OzI7MDIxugIK20T2dF6yLt3PQ7elXdkYYEiz8mC43OZ62E0Jo9E='

    url = URI.encode("https://www.linkedin.com/in/#{@username_linkedin}") # vebjørn-bræck-støen-132583188
    file = URI.open(url, "cookie" => cookie).read
    number = file.match(@regex)[:number]
    doc = Nokogiri::HTML(file)

    @data = JSON.parse(doc.css("#bpr-guid-#{number}").text.strip)
  end

  def call
    find_profile
    geolocalisation
    # connections
    find_industries
    find_experiences
    find_schools
    find_education
    find_skills
    find_languages_and_honors
  end

  private

  def find_profile
    profile = @data['included'].select { |included| included["$type"] == "com.linkedin.voyager.dash.identity.profile.Profile" }
    profile.map do |s|
      Resource.create(
        data_type: "linkedin",
        data: {
          profile: {
            profile_picture: s["profilePicture"].nil? ? false : "#{s['profilePicture']['displayImageReference']['vectorImage']['rootUrl']}#{s['profilePicture']['displayImageReference']['vectorImage']['artifacts'][2]['fileIdentifyingUrlPathSegment']}",
            full_name: "#{s['firstName']} #{s['lastName']}",
            headline: s["headline"].nil? ? false : s["headline"],
            summary: s["summary"].nil? ? false : s["summary"].gsub(/\n/, ' ')
          }
        },
        user: @user
      )
    end
  end

  def geolocalisation
    geo = @data['included'].select { |included| included["$type"] == "com.linkedin.voyager.dash.common.Geo" }
    geo.map do |s|
      Resource.create(
        data_type: "linkedin",
        data: {
          geolocalisation: s["defaultLocalizedName"]
        },
        user: @user
      )
    end
  end

  def connections
    driver = Selenium::WebDriver.for :chrome
    begin
      # Navigate to URL
      driver.get 'https://linkedin.com'
      sleep 3
      # Sign in
      inputs = driver.find_elements(:css, '.sign-in-form__form-input-container input')
      sleep 2
      inputs[0].send_keys(ENV["MAIL_LINKEDIN"])
      inputs[1].send_keys(ENV["MDP_LINKEDIN"])
      sleep 3
      driver.find_element(:css, '.sign-in-form__submit-button').click
      sleep 5
      # Sign in
      driver.get "https://linkedin.com/in/#{@username_linkedin}"
      sleep 5
      begin
        connections = driver.find_element(:css, '.pv-top-card--list-bullet li:nth-child(2) span').attribute("innerHTML").strip
        sleep 5
      rescue Selenium::WebDriver::Error::NoSuchElementError
        connections = nil
        driver.quit
      end
    ensure
      driver.quit
    end

    Resource.create(
      data_type: "linkedin",
      data: {
        connections: connections
      },
      user: @user
    ) unless connections.nil?
  end

  def find_industries
    industry = @data['included'].select { |included| included["$type"] == "com.linkedin.voyager.dash.common.Industry" }
    industry.map do |s|
      Resource.create(
        data_type: "linkedin",
        data: {
          industry: s["name"]
        },
        user: @user
      )
    end
  end

  def companies
    companies = @data['included'].select { |included| included["$type"] == "com.linkedin.voyager.dash.organization.Company"}
    companies.map do |s|
      Resource.create(
        data_type: "linkedin",
        data: {
          company: s["name"]
        },
        user: @user
      )
    end
  end

  def find_experiences
    experiences = @data['included'].select { |included| included["$type"] == "com.linkedin.voyager.dash.identity.profile.Position"}
    experiences.map do |s|
      Resource.create(
        data_type: "linkedin",
        data: {
          experience: {
            company: s["companyName"],
            date: s["dateRange"].nil? ? false : (s["dateRange"]["end"].nil? ? (s['dateRange']['start']['year']).to_s : "#{s['dateRange']['start']['year']} - #{s['dateRange']['end']['year']}"),
            title: s["title"],
            location: s["locationName"]
          }
        },
        user: @user
      )
    end
  end

  def find_schools
    schools = @data['included'].select { |included| included["$type"] == "com.linkedin.voyager.dash.organization.School"}
    schools.map do |s|
      Resource.create(
        data_type: "linkedin",
        data: {
          school: s["name"]
        },
        user: @user
      )
    end
  end

  def find_education
    education = @data['included'].select { |included| included["$type"] == "com.linkedin.voyager.dash.identity.profile.Education"}
    education.map do |s|
      Resource.create(
        data_type: "linkedin",
        data: {
          education: {
            school: s["schoolName"],
            date: s["dateRange"].nil? ? false : (s["dateRange"]["end"].nil? ? (s['dateRange']['start']['year']).to_s : "#{s['dateRange']['start']['year']} - #{s['dateRange']['end']['year']}"),
            degree: s["degreeName"],
            field: s["fieldOfStudy"],
            grade: s["grade"],
            other_activites: s["activities"]
          }
        },
        user: @user
      )
    end
  end

  def find_skills
    skills = @data['included'].select { |included| included["$type"] == "com.linkedin.voyager.dash.identity.profile.Skill"}
    skills.map do |s|
      Resource.create(
        data_type: "linkedin",
        data: {
          skill: s["name"]
        },
        user: @user
      )
    end
  end

  def find_languages_and_honors
    # HONORS
    honors = @data['included'].select { |included| included["$type"] == "com.linkedin.voyager.dash.identity.profile.Honor"}
    honors.map do |s|
      Resource.create(
        data_type: "linkedin",
        data: {
          honor: {
            title: s["title"],
            issuer: s["issuer"],
            description: s["description"]
          }
        },
        user: @user
      )
    end

    # LANGUAGES
    languages = @data['included'].select { |included| included["$type"] == "com.linkedin.voyager.dash.identity.profile.Language"}
    languages.map do |s|
      Resource.create(
        data_type: "linkedin",
        data: {
          language: {
            name: s["name"],
            proficiency: s["proficiency"]
          }
        },
        user: @user
      )
    end
  end
end
