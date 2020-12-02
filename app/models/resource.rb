class Resource < ApplicationRecord
  DATA_KEY_TWITTER = [:content, :username, :date, :place, :hashtag, :mistake, :profanity]
  DATA_KEY_LINKEDIN = [:profile, :geolocalisation, :connections, :industry, :experience, :school, :education, :skill, :honor, :language]

  belongs_to :user

  store_accessor :data, *(DATA_KEY_LINKEDIN + DATA_KEY_TWITTER)

  # store :data, accessors: DATA_KEY_LINKEDIN + DATA_KEY_TWITTER
  scope :with_key, ->(key) { where("data->>'#{key}' IS NOT NULL") }
end
