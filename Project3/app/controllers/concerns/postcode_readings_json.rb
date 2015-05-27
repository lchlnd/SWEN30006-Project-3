module PostcodeReadingsJson
	extend ActiveSupport::Concern

	# Return a hash map containing all of the data to be included in the JSON object
	def build_postcode_readings date, location_readings, last_updates
		output = {"date" => date.to_s}
		location_data = []
		


		# Generate the subarray of all locations
		location_readings.each_pair do |loc, readings|
			loc_hash = {}
			loc_hash["id"] = loc.name
			loc_hash["lat"] = loc.position.latitude.to_s
			loc_hash["lon"] = loc.position.longitude.to_s
			loc_hash["last_update"] = last_updates[loc].to_s

			measurements = []
			
			# Generate the subarray of measurements for each location
			readings.each do |r|
				reading_hash = {}
				reading_hash["time"] = r.created_at.to_s
				reading_hash["temp"] = r.temperature.value.to_s
				reading_hash["precip"] = r.rainfall.value.to_s
				reading_hash["wind_direction"] = r.wind_direction.value.to_s
				reading_hash["wind_speed"] = r.wind_speed.value.to_s

				measurements << reading_hash
			end
			loc_hash["measurements"] = measurements
			location_data << loc_hash
		end
		output["locations"] = location_data
		return output
	end

		
end