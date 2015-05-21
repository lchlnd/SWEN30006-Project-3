module PostcodeReadingsJson
	extend ActiveSupport::Concern

	# Return a hash map containing all of the data to be included in the JSON object
	def build_postcode_readings date, data
		output = {"date" => date.to_s}
		location_data = []
		puts "Hello"
		puts output
		puts data

		# Generate the subarray of all locations
		data.each_key do |l| #, readings|
			puts "Hello?"
			loc_hash = {}
			loc_hash["id"] = l.name
			loc_hash["lat"] = l.position.latitude.to_s
			loc_hash["lon"] = l.position.longitude.to_s
			loc_hash["last_update"] = "null"
			# No readings in db yet:
			# loc_hash["last_update"] = Reading.where(:location_id => l.id).order("created_at").last.created_at.to_s

			measurements = []

			# # Generate the subarray of measurements for each location
			# readings.each do |r|
			# 	reading_hash = {}
			# 	reading_hash["time"] = r.created_at.to_s
			# 	reading_hash["precip"] = r.rainfall.value.to_s
			# 	reading_hash["wind_direction"] = r.wind_direction.to_s
			# 	reading_hash["wind_speed"] = r.wind_speed.value.to_s

			# 	measurements << reading_hash
			# end
			loc_hash["measurements"] = "some measurements"
			location_data << loc_hash
		end

		output["locations"] = location_data
		return output
	end

		
end