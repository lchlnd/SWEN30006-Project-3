module LocationsJson
	extend ActiveSupport::Concern

	# Return a hash map containing all of the data to be included in the JSON object
	def build_locations locations, date
		output = {"date" => date}
		location_data = []
		locations.each do |l|
			# Build the hash for each location
			loc_hash = {}
			loc_hash["id"] = l.name
			loc_hash["lat"] = l.position.latitude
			loc_hash["long"] = l.position.longitude
			loc_hash["last_update"] = "null" 
			# No readings in db yet.  Otherwise: 
			# loc_hash["last_update"] = Reading.where(:location_id => l.id).order("created_at").last.created_at.to_s
			# Add the hash for each location to the 'location_data' array
			location_data << loc_hash
		end
		# Add the array containing all of the location hashes to the output
		output["locations"] = location_data
		return output
	end
end



