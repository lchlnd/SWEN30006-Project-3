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
		@date = Date.parse(params[:date])
		@date_readings = []

		if (@location = Location.find_by_id params[:id].to_i) != nil
			@readings = Reading.where(:location_id => @location.id)
			@readings.each do |r|
				if r.created_at.to_date == @date
					@date_readings << r
				end
			end
			@current_temp = 20
			@current_cond = "sunny"
			respond_to do |format|
				format.html
				format.js
				format.json {render json: build_location_readings(@readings, @date, @current_temp, @current_cond)}
			end
		elsif (@postcode = Postcode.find_by_code params[:id].to_i) != nil

			# Find all locations within the given postcode
			@locations = Location.where(:postcode_id => @postcode.id)
			@location_readings = {}
			@last_updates = {}

			# Find all readings for each location, and store them in a hashmap.
			@locations.each do |l|
				@location_readings[l] = []
				readings = Reading.where(:location_id => l.id)
				readings.each do |r|
					if r.created_at.to_date == @date
						@location_readings[l] << r
					end
				end
				puts "In locations loop"

				#@last_updates[l] = readings.order("created_at").last.created_at
			end

			respond_to do |format|
				format.html
				format.js
				format.json {render json: build_postcode_readings(@date, @location_readings)}#, @last_updates)}
			end
		else
			render "Error - invalid location/postcode id"
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
end
