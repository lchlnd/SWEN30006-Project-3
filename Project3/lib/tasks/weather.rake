# Adapted from sample solution

require 'nokogiri'
require 'open-uri'
require 'json'

BOM_BASE_URL = 'http://www.bom.gov.au'

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
        reading = Reading.new
        reading.create_temperature(value: temp)
        reading.create_rainfall(value: rain)
        reading.create_wind_speed(value: wind_speed)
        reading.create_wind_direction(value: wind_dir)

        # Save
        reading.location = location
        reading.save
      end
    end
  end

  # Scrape ForecastIO API for data
  task :scrape_forecast_io => environment do
    
  end
end