class Prediction < ActiveRecord::Base
  belongs_to :position

  has_many :datapoints, :class_name => 'PredictedDatapoint'

  has_one :rainfall, :class_name => 'PredictedRainfall'
  has_one :temperature, :class_name => 'PredictedTemperature'
  has_one :wind_direction, :class_name => 'PredictedWindDirection'
  has_one :wind_speed, :class_name => 'PredictedWindSpeed'
end
