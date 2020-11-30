require 'amazing_print'
require 'nokogiri'
require 'json'
require 'open-uri'
require 'webdrivers'
require 'selenium-webdriver'

# frozen_string_literal: true
class ServiceLinkedin < ApplicationService
  def initialize(user_id)
    @user = User.find(user_id)
    username_linkedin = @user.username_linkedin

    @regex = %r{<code.+>\n.+linkedin.voyager.dash.deco.identity.profile.FullProfileWithEntities.+"bpr-guid-(?<number>\d+)".+\n</code>}
    cookie = 'bcookie="v=2&f58d3c69-aef1-4bc9-8a4c-acb72be95771"; lissc=1; bscookie="v=1&20201129102309ee5b0465-ef13-409a-8480-39d9647f53f4AQGhnDXuEcINs6KOGewflax03yAHcnbL"; li_gc=MTsyMTsxNjA2NjQ1Mzk5OzI7MDIx1lOAkPyiwhObp9a296KD3jpI2QD/5TdsecM5+sWTWI0=; li_rm=AQENDn7BPnmKAgAAAXYTh0-Z5SZv4h0Z4Sn-lXmY8_DZzMdkLSLRd9ZZg6d-W4qGnEZt0pIV2J5uorf4S3Q9s9_lANZWAuKHpGvDCpzAKHqMY_H-_hDvp6xv; _ga=GA1.2.962298148.1606645404; _gid=GA1.2.905994353.1606645404; _gat=1; AMCVS_14215E3D5995C57C0A495C55%40AdobeOrg=1; aam_uuid=22135691800873043941416996258899395133; li_at=AQEDATNYHJcFYd28AAABdhOHaHgAAAF2N5PseFYAa8le3wem3b1Qp-ZS6x3Wx_IJSFQRyTH5X_KNbSZrHp-iK0NaB_nOdtQalRULjNT7PbBrOZ9n7QaIxjH6Tfznu4vGh3jtrA6ukytNcVMqlv53dWez; liap=true; JSESSIONID="ajax:5429456736043900841"; lang=v=2&lang=fr-fr; li_mc=MTsyMTsxNjA2NjQ1NDEwOzI7MDIx59959eyMoYUWCQ5uhP+VEqEmqTs3QnnPcVBHM5k7moQ=; lidc="b=VB03:s=V:r=V:g=4078:u=6:i=1606645410:t=1606731504:v=1:sig=AQGHQSVnQ6w2m2SP9cj5Fe8cTPSW8lJG"; spectroscopyId=ad781578-6f34-4bf8-a2c7-8e00704167f8; AMCV_14215E3D5995C57C0A495C55%40AdobeOrg=-637568504%7CMCIDTS%7C18596%7CMCMID%7C21952258699507596811397525096527262198%7CMCAAMLH-1607250215%7C6%7CMCAAMB-1607250215%7C6G1ynYcLPuiQxYZrsz_pkqfLG9yMXBpb2zX5dvJdYQJzPXImdj0y%7CMCOPTOUT-1606652615s%7CNONE%7CvVersion%7C5.1.1%7CMCCIDH%7C661940655'

    url = URI.encode("https://www.linkedin.com/in/#{username_linkedin}") # vebjørn-bræck-støen-132583188
    file = URI.open(url, "cookie" => cookie).read
    number = file.match(@regex)[:number]
    doc = Nokogiri::HTML(file)

    @data = JSON.parse(doc.css("#bpr-guid-#{number}").text.strip)
  end

  def call
    find_profile
    geolocalisation
    connections
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
        user: user
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
        user: user
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
        driver.get "https://linkedin.com/in/#{username_linkedin}"
        sleep 5
        begin
          connections = driver.find_element(:css, '.pv-top-card--list-bullet li:nth-child(2) span').attribute("innerHTML").strip
          sleep 5
        rescue Selenium::WebDriver::Error::NoSuchElementError
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
        user: user
      )
  end

  def find_industries
    industry = @data['included'].select { |included| included["$type"] == "com.linkedin.voyager.dash.common.Industry" }
    industry.map do |s|
      Resource.create(
        data_type: "linkedin",
        data: {
          industry: s["name"]
        },
        user: user
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
        user: user
      )
    end
  end

  def find_experiences
    experiences = @data['included'].select { |included| included["$type"] == "com.linkedin.voyager.dash.identity.profile.Position"}
    experiences.map do |s|
      Resource.create(
        data_type: "linkedin",
        data: {
          experiences: {
            company: s["companyName"],
            date: s["dateRange"].nil? ? false : (s["dateRange"]["end"].nil? ? (s['dateRange']['start']['year']).to_s : "#{s['dateRange']['start']['year']} - #{s['dateRange']['end']['year']}"),
            title: s["title"],
            location: s["locationName"]
          }
        },
        user: user
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
        user: user
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
        user: user
      )
    end
  end

  def find_skills
    skills = @data['included'].select { |included| included["$type"] == "com.linkedin.voyager.dash.identity.profile.Skill"}
    skills.map do |s|
      Resource.create(
        data_type: "linkedin",
        data: {
          skill: ["multiLocaleName"].values.first
        },
        user: user
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
        user: user
      )
    end

    # LANGUAGES
    languages = data['included'].select { |included| included["$type"] == "com.linkedin.voyager.dash.identity.profile.Language"}
    languages.map do |s|
      Resource.create(
        data_type: "linkedin",
        data: {
          language: {
            name: s["name"],
            proficiency: s["proficiency"]
          }
        },
        user: user
      )
    end
  end
end
