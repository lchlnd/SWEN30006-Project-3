require 'aggregation.rb'
require 'regression.rb'
class Predictor
	EPSILON = 0.001
	SECPERMIN = 60
	TRUE_NORTH = 360
	MAX_TIME = 180
	PRED_INTERVAL = 10

	# Creates predictions for all data types for the given position and saves them in the database, as well as returning a 
	# hash containing all of the predictions.
	def self.create position, period
		aggregated_data = Aggregation.build_aggregate_hash position.latitude, position.longitude

		# Set up a reference point for t=0
		time_reference = aggregated_data["wind_speed"].first.first.to_f

		# Get predicted values for each datatype
		rain_hash = regress aggregated_data["rainfall"], time_reference
		rain_vals = get_values rain_hash[:function], period, time_reference
		rain_factor =  MAX_TIME*max(1, rain_hash[:fit]/rain_hash[:mean])

		windspeed_hash= regress aggregated_data["wind_speed"], time_reference
		windspeed_vals = get_values windspeed_hash[:function], period, time_reference
		windspeed_factor =  MAX_TIME*max(1, windspeed_hash[:fit]/windspeed_hash[:mean])

		winddir_hash = regress aggregated_data["wind_direction"], time_reference
		winddir_vals = get_values winddir_hash[:function], period, time_reference
		winddir_factor = MAX_TIME*max(1, winddir_hash[:fit]/winddir_hash[:mean])

		temp_hash = regress aggregated_data["temperature"], time_reference
		temp_vals = get_values temp_hash[:function], period, time_reference
		temp_factor = MAX_TIME*max(1, temp_hash[:fit]/(temp_hash[:mean]))

		predictions = {}



		for t in (0..period.to_i).step(PRED_INTERVAL)
			# Create prediction in database
			rain_prob = ((MAX_TIME - 0.5*t)/rain_factor).round(2)
			windspeed_prob = ((MAX_TIME - 0.5*t)/windspeed_factor).round(2)
			winddir_prob = ((MAX_TIME - 0.5*t)/winddir_factor).round(2)
			temp_prob = ((MAX_TIME - 0.5*t)/temp_factor).round(2)

			@pred = Prediction.new :timeframe => t, :position_id => position.id
			@pred.create_rainfall(:value => rain_vals[t], :probability => rain_prob)
			@pred.create_wind_speed(:value => windspeed_vals[t], :probability => windspeed_prob)
			@pred.create_wind_direction(:value => winddir_vals[t]%TRUE_NORTH, :probability => winddir_prob)
			@pred.create_temperature(:value => temp_vals[t], :probability => temp_prob)

			# Create hash for API request/web page rendering
			rain_pred = {"value" => rain_vals[t].to_s + "mm", "probability" => rain_prob}
			windspeed_pred = {"value" => windspeed_vals[t].to_s, "probability" => windspeed_prob}
			winddir_pred = {"value" => (winddir_vals[t]%TRUE_NORTH).to_s, "probability" => winddir_prob}
			temp_pred = {"value" => temp_vals[t].to_s, "probability" => temp_prob}
			predictions["#{t}"] = {"time" => (Time.now + t.minutes).localtime.strftime("%H:%M%p %d-%m-%Y"), "rain" => rain_pred, "temp" => temp_pred, "wind_direction" => winddir_pred, "wind_speed" => windspeed_pred}
			
		end
		predictions
	end

	# Takes a data hash containing times and reading values, and generates a set of predictions for the given period
	def self.regress data, time_reference
		times = []
		data.keys.each do |t|
			times << t.to_f - time_reference
		end
		Regression.best_fit(times, data.values)
	end

	# Returns a hash of time - data value pairs, as predicted by the given function
	def self.get_values func, period, time_reference
		values = {}
		for t in (0..period.to_i).step(PRED_INTERVAL)
			val = func.call(Time.now.to_i - time_reference + t*SECPERMIN)
			values[t] = val > 0 ? val.round(2) : 0
		end
		values
	end

	def self.max arg1, arg2
		arg1 >= arg2 ? arg1 : arg2
	end
end


 