class Prediction < ActiveRecord::Base
  belongs_to :position

  has_many :predicted_datapoints

  has_one :predicted_rainfall, :class_name => "PredictedRainfall"
  has_one :predicted_temperature
  has_one :predicted_wind_direction
  has_one :predicted_wind_speed
end
