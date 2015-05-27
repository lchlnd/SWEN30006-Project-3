require 'aggregation.rb'
require 'regression.rb'
class Predictor

	SECPERMIN = 60

	# Creates predictions for all data types for the given position and saves them in the database, as well as returning a 
	# hash containing all of the predictions.
	def self.create position, period

		aggregated_data = Aggregation.build_aggregate_hash position.latitude, position.longitude

		puts aggregated_data

		rain_hash = Regression.best_fit(t, y)
		rain_vals = get_values hash[:function], period

		windspeed_hash = Regression.best_fit(t, y)
		windspeed_vals = get_values wind_hash[:function], period

		winddir_hash = Regression.best_fit(t, y)
		winddir_vals = get_values winddir_hash[:functions], period

		temp_hash = Regression.best_fit(t, y)
		temp_vals = get_values temp_hash[:functions], period

		predictions = {}
		for t in (0..period).step(10)
			# Create prediction in database
			@pred = Prediction.new :timefame => t, :position_id => position.id
			@pred.create_rainfall(:value => rain_vals[t], :probability => rain_hash[:r2])
			@pred.create_wind_speed(:value => windspeed_vals[t], :probability => windspeed_hash[:r2])
			@pred.create_wind_direction(:value => winddir_vals[t], :probability => winddir_hash[:r2])
			@pred.create_temperature(:value => temp_vals[t], :probability => temp_hash[:r2])

			# Create hash for API request/web page rendering
			rain_pred = {"value" => rain_vals[t], "probability" => rain_hash[:r2]}
			windspeed_pred = {"value" => wind_vals[t], "probability" => windspeed_hash[:r2]}
			winddir_pred = {"value" => winddir_vals[t], "probability" => winddir_hash[:r2]}
			temp_pred = {"value" => temp_vals[t], "probability" => temp_hash[:r2]}
			predictions["#{t}m"] = {"rain" => rain_pred, "temp" => temp_pred, "wind_direction" => winddir_pred, "wind_speed" => windspeed_pred}
		end
		predictions
	end



	# Returns a hash of time-datavalue pairs, as predicted by the given function
	def self.get_values func, period
		values = {}
		for t in (0..period).step(10)
			values[t] = func.call(Time.now.to_i + t*SECPERMIN)
		end
		values
	end
end


 