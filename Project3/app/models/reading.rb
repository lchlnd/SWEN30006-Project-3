class Reading < ActiveRecord::Base
  belongs_to :location
  belongs_to :source

  has_many :datapoints

  has_one :rainfall
  has_one :temperature
  has_one :wind_direction
  has_one :wind_speed
end
