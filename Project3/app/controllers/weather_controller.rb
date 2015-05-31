class WeatherController < ApplicationController
	include LocationsJson
	include LocationReadingsJson
	include PostcodeReadingsJson

	# get 'weather/locations' 
	def locations

		@locations = Location.all
		@location_data = {}
		@locations.each do |loc|
			@location_data[loc] = Reading.where(:location_id => loc.id).last.created_at.localtime.strftime("%H:%M%p %d-%m-%Y")
		end
		respond_to do |format|
			format.html
			# format.js probably not needed because we are not using any javascript
			format.js
			format.json {render json: build_locations(@location_data, Date.today)}
		end
	end

	# get 'weather/data/:id/:date'
	def data
		@date = Date.parse(params[:date])
		@date_readings = []

		if (@location = Location.find_by_id params[:id].to_i) != nil
			@readings = Reading.where(:location_id => @location.id).order("created_at DESC")
			@daily_readings = []
			@readings.each do |r|
				if r.created_at.localtime.to_date == @date
					@daily_readings << r
				end
			end

			@conditions = @location.current_conditions
			
			respond_to do |format|
				format.html {render "location_data"}
				format.js
				format.json {render json: build_location_readings(@daily_readings, @date, @conditions)}
			end
		elsif (@postcode = Postcode.find_by_code params[:id].to_i) != nil

			# Find all locations within the given postcode
			@locations = Location.where(:postcode_id => @postcode.id)
			@location_readings = {}
			@last_updates = {}

			# Find all readings for each location, and store them in a hashmap.
			@locations.each do |l|
				@location_readings[l] = []
				@readings = Reading.where(:location_id => l.id).order("created_at DESC")
				@readings.each do |r|
					if r.created_at.localtime.to_date == @date
						@location_readings[l] << r
					end
				end
				@last_updates[l] = @readings.order("created_at").last.created_at
			end

			respond_to do |format|
				format.html {render "postcode_data"}
				format.js
				format.json {render json: build_postcode_readings(@date, @location_readings, @last_updates)}
			end
		else
			respond_to do |format|
				format.html {redirect_to :action => "find_location_data", :error => :station_name}
				format.js
				format.json {render json: {"location" => "null", "predictions" => "null"}}
			end
		end
	end

	def find_location_data
		@locations = Location.all
	end


	def redirect_location_data

		@loc = Location.find_by(:name => params[:location][:name])
		@date = params[:location][:date]

		if(@loc == nil)
			redirect_to :action=> "find_location_data", :error => :station_name
		elsif(@date == "")
			redirect_to :action=> "find_location_data", :error => :date
		else
			redirect_to :action => "data", :id => @loc.id, :date => @date
		end
	end

	# get 'weather/prediction/:lat/:long/:period'
	def predict
		if (@pos = Position.find_by(:latitude => params[:lat], :longitude => params[:long])) == nil
			@pos = Position.create(:latitude => params[:lat], :longitude => params[:long])
		end
		@prediction_data = {"latitude" => @pos.latitude, "longitude" => @pos.longitude}
		@prediction_data["predictions"] = Predictor.create @pos, params[:period]

		respond_to do |format|
			format.html {render "lat_lon_pred"}
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
			format.html {render "postcode_pred"}
			format.js
			format.json {render json: @prediction_data}
		end

	end

	def redirect_postcode_data

		@postcode = Postcode.find_by(:code => params[:postcode][:code])
		@date = params[:postcode][:date]

		if(@postcode == nil)
			redirect_to :action=> "find_postcode_data", :error=> :postcode
		elsif(@date == "")
			redirect_to :action=> "find_postcode_data",  :error => :date
		else
			redirect_to :action => "data", :id => @postcode.code, :date => @date
		end

		
	end

	def redirect_location_pred

		@lat = params[:location][:latitude]
		@long = params[:location][:longitude]
		@period = params[:location][:period]

		if(@lat == "")
			redirect_to :action=> "find_location_pred_data", :error => :latitude
		elsif(@long=="")
			redirect_to :action=> "find_location_pred_data", :error => :longitude
		elsif(@period=="")
			redirect_to :action=> "find_location_pred_data", :error => :period
		else
			redirect_to :action => "predict", :lat => @lat, :long => @long, :period => @period
		end
	end

	def redirect_postcode_pred

		@postcode = Postcode.find_by(:code => params[:postcode][:code])
		@period = params[:postcode][:period]

		if(@postcode == nil)
			redirect_to :action=> "find_postcode_pred_data", :error=> :postcode
		elsif(@period == "")
			redirect_to :action=> "find_postcode_pred_data",  :error => :period
		else
			redirect_to :action => "postcode_predict", :postcode => @postcode.code, :period => @period.to_i
		end
	end


	def index
		@average_temperature = []
		location = Location.find_by(:name =>"Melbourne Airport")

		tot_temp = 0.0
		count    = 0.0
		location.readings.where(:created_at=> Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).each do |reading|
			@average_temperature << [reading.created_at,reading.temperature.value]
		end
	end

end
