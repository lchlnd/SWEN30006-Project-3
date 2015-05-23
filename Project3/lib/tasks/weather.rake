# Adapted from sample solution

require 'nokogiri'
require 'open-uri'
require 'json'

BOM_BASE_URL = 'http://www.bom.gov.au'
FIO_BASE_URL = 'https://api.forecast.io/forecast'

WIND_DIRS = %i{ N NNE NE ENE E ESE SE SSE S SSW SW WSW W WNW NW NNW }.freeze
WIND_DIR_MAPPINGS = WIND_DIRS.each_with_index.inject({}) { |m, (dir, index)| m[dir] = index * 360.0 / WIND_DIRS.size;
m }.freeze

def load_bom_info_table
  vic_doc = Nokogiri::HTML(open("#{BOM_BASE_URL}/vic/observations/vicall.shtml"))
  vic_doc.css('tr')
end

namespace :weather do

  # Scrape the BOM site for data
  task :scrape_bom => :environment do
    source = Source.find_or_create_by(name: 'BOM')
    info_table = load_bom_info_table
    info_table.each do |row|
      # Get name, check if it is in database
      name = row.xpath('./th/a').text
      if location = Location.find_by(name: name)
        # Location exists, get information
        temp = row.xpath('./td')[1].text.to_f
        rain = row.xpath('./td')[12].text.to_f
        wind_speed = row.xpath('./td')[7].text.to_f
        wind_dir_name = row.xpath('./td')[6].text
        wind_dir = WIND_DIR_MAPPINGS[wind_dir_name.to_sym]

        # Create new reading
        reading = Reading.new(timestamp: Time.now)
        reading.create_temperature(value: temp)
        reading.create_rainfall(value: rain)
        reading.create_wind_speed(value: wind_speed)
        reading.create_wind_direction(value: wind_dir)

        # Save
        reading.location = location
        reading.source = source
        reading.save
      end
    end
  end

  # Scrape ForecastIO API for data
  task :scrape_forecast => :environment do
    # api_key = ENV['FORECAST_IO_API_KEY']
    api_key = '0f6b719cfafec37657112026f8685932'
    source = Source.find_or_create_by(name: 'ForecastIO')

    Location.all.each do |location|
      puts "Scraping #{location.name}"
      # Get data for each location
      forecast = JSON.parse(open("#{FIO_BASE_URL}/#{api_key}/#{location.position.latitude},#{location.position.longitude}?units=si&exclude=minutely,hourly,daily,alerts,flags").read)
      current_data = forecast["currently"].to_hash.with_indifferent_access

      # Include previous rainfall, if exists
      observation_time = Time.at(current_data[:time])
      last_reading = location.readings.where(source: source).last
      if last_reading
        last_reading_time = last_reading.timestamp.to_time
        if (last_reading_time - 9.hours).to_date == (observation_time - 9.hours).to_date
          rainfall = last_reading.rainfall
        end
      end

      # Calc total
      rainfall ||= 0
      last_reading_time ||= (observation_time - 9.hours).to_date.to_time + 9.hours
      rainfall += current_data[:precipIntensity] * current_data[:precipProbability] * (observation_time -
          last_reading_time) / 3600

      # Create new reading
      reading = Reading.new(timestamp: observation_time)
      reading.create_temperature(value: current_data[:temperature])
      reading.create_rainfall(value: rainfall)
      reading.create_wind_speed(value: current_data[:windSpeed] * 3.6)
      reading.create_wind_direction(value: current_data[:windBearing])

      # Save
      reading.location = location
      reading.source = source
      reading.save
    end
  end
end