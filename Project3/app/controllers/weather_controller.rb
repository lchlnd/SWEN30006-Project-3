class WeatherController < ApplicationController
	include LocationsJson
	include LocationReadingsJson
	include PostcodeReadingsJson

	def locations
		@locations = Location.all
		respond_to do |format|
			format.html
			# format.js probably not needed because we are not using any javascript
			format.js
			format.json {render json: build_locations(@locations, Date.today)}
		end
	end

	def data
		# Pretend a location id and a date has been provided as a parameter:
		loc_id = 1
		date = Date.today
		# Pretend lookups for current temp and conditions have been done:
		currenttemp = 20
		currentcond = "sunny"

		@readings = Reading.where(:location_id => loc_id, :created_at => date)

		respond_to do |format|
			format.html
			format.js
			format.json {render json: build_location_readings(@readings, date, currenttemp, currentcond)}
		end
	end


	# Need to find a way to combine this with the above data method i.e. to distinguish between whether the parameter is
	# postcode or a location_id
	def postcode_data
		# Pretend a postcode and date have been given:
		postcode = 3525
		date = Date.today


		p = Postcode.find_by_code(postcode)
		@locations = p.locations

		# Prepare data for JSON builder:
		data = {}
		@locations.each do |l|
			puts "a location?"
			readings = Reading.where(:location_id => l.id, :created_at => date)
			data[l] = readings
		end

		respond_to do |format|
			format.html
			format.js
			format.json {render json: build_postcode_readings(date, data)}
		end

	end





		# @locations            = Location.all
		# weather_locationsHash = Hash.new
		# locationsArray        = Array.new
		
		# #Build Hash for JSON Object
		# @locations.each do |l|
		# 	locationHash               = Hash.new
		# 	locationHash[:id]          = l.name
		# 	locationHash[:lat]         = l.position.latitude
		# 	locationHash[:lon]         = l.position.longitude
		# 	locationHash[:last_update] = l.updated_at
		# 	locationsArray << locationHash
	 #  	end
	 #  	weather_locationsHash[:date]      = Time.now.strftime("%d-%m-%y")
		# weather_locationsHash[:locations] = locationsArray
		# #Render JSON object
	 #  	render json: weather_locationsHash
	  


  
end
