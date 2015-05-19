class WeatherController < ApplicationController
  def locations
	@locations            = Location.all
	weather_locationsHash = Hash.new
	locationsArray        = Array.new
	

	@locations.each do |l|
		locationHash               = Hash.new
		locationHash[:id]          = l.name
		locationHash[:lat]         = l.position.latitude
		locationHash[:lon]         = l.position.longitude
		locationHash[:last_update] = l.updated_at
		locationsArray << locationHash
  	end
  	weather_locationsHash[:date]      = Time.now.strftime("%d-%m-%y")
	weather_locationsHash[:locations] = locationsArray

  	render json: weather_locationsHash
  end

  
end
