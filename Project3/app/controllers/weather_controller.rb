class WeatherController < ApplicationController
	include LocationsJson
	include LocationReadingsJson
	include PostcodeReadingsJson

	# get 'weather/locations' 
	def locations

		@locations = Location.all
		respond_to do |format|
			format.html
			# format.js probably not needed because we are not using any javascript
			format.js
			format.json {render json: build_locations(@locations, Date.today)}
		end
	end

	# get 'weather/data/:id/:date'
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
			puts "Hello"
			puts @date_readings
			respond_to do |format|
				format.html {render "location_data"}
				format.js
				format.json {render json: build_location_readings(@date_readings, @date, @current_temp, @current_cond)}
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

	def find_postcode_data

		respond_to do |format|

			format.html {render "find_postcode_data"}
		end
	end

	def find_location_data

		respond_to do |format|

			format.html {render "find_location_data"}
		end
	end

	def redirect_location_data

		@id = Location.find_by(:name => params[:location][:name])
		@date = params[:location][:date]

		redirect_to :action => "data", :id => @id.id, :date => @date
	end

	# get 'weather/prediction/:lat/:long/:period'
	def predict
		if (@pos = Position.find_by(:latitude => params[:lat], :longitude => params[:long])) == nil
			@pos = Position.create(:latitude => params[:lat], :longitude => params[:long])
		end
		@prediction_data = {"latitude" => @pos.latitude, "longitude" => @pos.longitude}
		@prediction_data["predictions"] = Predictor.create @pos, params[:period]

		respond_to do |format|
			format.html
			format.js
			format.json {render json: @prediction_data}
		end
	end

	# get 'weather/prediction/:postcode/:period'
	def postcode_predict

		if (@postcode = Postcode.find_by_code(params[:postcode])) == nil
			return :error
		end
		
		@prediction_data = {"postcode" => params[:postcode]}
		@prediction_data["predictions"] = Predictor.create  @postcode.position, params[:period]

		respond_to do |format|
			format.html
			format.js
			format.json {render json: @prediction_data}
		end

	end

	def redirect_postcode_data

		@id = Postcode.find_by(:code => params[:postcode][:code])
		@date = params[:postcode][:date]

		redirect_to :action => "data", :id => @id.code, :date => @date
	end
		


end
