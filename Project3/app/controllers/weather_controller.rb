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
				format.html {render "location_data"}
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

				@last_updates[l] = readings.order("created_at").last.created_at
			end

			respond_to do |format|
				format.html {render "postcode_data"}
				format.js
				format.json {render json: build_postcode_readings(@date, @location_readings, @last_updates)}
			end
		else
			# Need a way to return an error message if the user enters an invalid location_id or postcode
			#render "Error - invalid location/postcode id"
		end
	end

	def predict
		
		Predictor.create

	end

	def postcode_predict
		@postcode = Postcode.find_by_code(params[:postcode])
		lat = @postcode.position.latitude
		long = @postcode.position.longitude
		redirect_to :action => :predict, :period => params[:period].to_s,  :lat => lat.to_s, :long => long.to_s
	end
end
