module LocationReadingsJson
	extend ActiveSupport::Concern

	# Return a hash map containing all of the data to be included in the JSON object
	def build_location_readings readings, date, current_temp, current_cond
		output = {"date" => date.to_s, "current_temp" => current_temp.to_s, "current_cond" => current_cond.to_s}
		measurements = []
		readings.each do |r|
			reading_hash = {}
			reading_hash["time"] = r.created_at.to_s
			reading_hash["temp"] = r.temperature.value.to_s
			reading_hash["precip"] = r.rainfall.value.to_s
			reading_hash["wind_direction"] = r.wind_direction.value.to_s
			reading_hash["wind_speed"] = r.wind_speed.value.to_s
			measurements << reading_hash
		end

		output["measurements"] = measurements
		return output
	end
end