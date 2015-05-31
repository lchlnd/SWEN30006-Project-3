module LocationReadingsJson
	extend ActiveSupport::Concern

	# Return a hash map containing all of the data to be included in the JSON object
	def build_location_readings readings, date, conditions
		output = {"date" => date.to_time.localtime.strftime("%d-%m-%Y")}.merge(conditions)
		measurements = []
		readings.each do |r|
			reading_hash = {}
			reading_hash["time"] = r.created_at.localtime.strftime("%H:%M:%S %p")
			reading_hash["temp"] = r.temperature.value.to_s
			reading_hash["precip"] = r.rainfall.value.to_s + "mm"
			reading_hash["wind_direction"] = r.wind_direction.compass_string
			reading_hash["wind_speed"] = r.wind_speed.value.to_s
			measurements << reading_hash
		end

		output["measurements"] = measurements
		return output
	end
end