require 'aggregation.rb'
require 'regression.rb'
class Predictor

	SECPERMIN = 60

	# Creates predictions for all data types for the given position and saves them in the database, as well as returning a 
	# hash containing all of the predictions.
	def self.create position, period

		aggregated_data = Aggregation.build_aggregate_hash position.latitude, position.longitude
		time_reference = aggregated_data["rainfall"].first.first.to_f - 4

		# Regress aggregated rainfall data
		# rain_times = []
		# raining = :false
		# aggregated_data["rainfall"].each_pair do |t, rainfall|
		# 	if rainfall != 0
		# 		raining = :true
		# 	end
		# 	rain_times << t.to_f - time_reference
		# end
		# puts aggregated_data["rainfall"]
		# if raining == :true
		# 	rain_hash = Regression.best_fit(rain_times, aggregated_data["rainfall"].values)
		# 	puts "raining = true"
		# 	puts rain_hash
		# else
		# 	rain_hash = {:function => lambda{|x| 0}, :r2 => 1.0}
		# end
		# rain_vals = get_values rain_hash[:function], period

		# Regress aggregated windspeed data
		windspeed_times = []
		aggregated_data["wind_speed"].keys.each do |t|
			windspeed_times << t.to_f - time_reference
		end
		windspeed_hash = Regression.best_fit(windspeed_times, aggregated_data["wind_speed"].values)
		windspeed_vals = get_values windspeed_hash[:function], period

		# Regress aggregated wind direction data
		winddir_times = []
		aggregated_data["wind_direction"].keys.each do |t|
			winddir_times << t.to_f - time_reference
		end
		winddir_hash = Regression.best_fit(winddir_times, aggregated_data["wind_direction"].values)
		winddir_vals = get_values winddir_hash[:function], period

		# Regress aggregated temperature data
		temp_times = []
		aggregated_data["temperature"].keys.each do |t|
			temp_times << t.to_f - time_reference
		end
		temp_hash = Regression.best_fit(temp_times, aggregated_data["temperature"].values)
		temp_vals = get_values temp_hash[:function], period

		predictions = {}
		for t in (0..period.to_i).step(10)
			# Create prediction in database
			@pred = Prediction.new :timeframe => t, :position_id => position.id
			#@pred.create_rainfall(:value => rain_vals[t], :probability => rain_hash[:r2])
			@pred.create_wind_speed(:value => windspeed_vals[t], :probability => windspeed_hash[:r2])
			@pred.create_wind_direction(:value => winddir_vals[t], :probability => winddir_hash[:r2])
			@pred.create_temperature(:value => temp_vals[t], :probability => temp_hash[:r2])

			# Create hash for API request/web page rendering
			#rain_pred = {"value" => rain_vals[t], "probability" => rain_hash[:r2]}
			windspeed_pred = {"value" => windspeed_vals[t], "probability" => windspeed_hash[:r2]}
			winddir_pred = {"value" => winddir_vals[t], "probability" => winddir_hash[:r2]}
			temp_pred = {"value" => temp_vals[t], "probability" => temp_hash[:r2]}
			predictions["#{t}m"] = {"temp" => temp_pred, "wind_direction" => winddir_pred, "wind_speed" => windspeed_pred}
			#{}"rain" => rain_pred, "temp" => temp_pred, "wind_direction" => winddir_pred, "wind_speed" => windspeed_pred}
		end
		predictions
	end



	# Returns a hash of time-datavalue pairs, as predicted by the given function
	def self.get_values func, period
		values = {}
		for t in (0..period.to_i).step(10)
			values[t] = func.call(Time.now.to_i + t*SECPERMIN)
		end
		values
	end
end


 