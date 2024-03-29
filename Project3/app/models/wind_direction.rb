class WindDirection < Datapoint

	# Converts the wind direction from a value in degrees to a string containing the corresponding compass bearing 
	def compass_string
		map = {0.0 => 'N', 22.5 => 'NNE', 45.0 => 'NE', 67.5 => 'ENE', 90.0 => 'E', 112.5 => 'ESE', 135.0 => 'SE', 
			157.5 => 'SSE', 180.0 => 'S', 202.5 => 'SSW', 225.0 => 'SW', 247.5 => 'WSW', 270.0 => 'W', 292.5 => 'WNW',
			315.0 => 'NW', 337.5 => 'NNW', 360.0 => 'N'}

    if self.value.nil?
      '-'
    else
      map[(self.value/22.5).round*22.5]
    end
	end

	# Converts the given compass bearing in string form into a float value in degrees
	def self.to_float compass_string
		map = {'N' => 0, 'NNE' => 22.5, 'NE' => 45, 'ENE' => 67.5, 'E' => 90, 'ESE' => 112.5, 'SE' => 135, 
			'SSE' => 157.5, 'S' => 180, 'SSW' => 202.5, 'SW' => 225, 'WSW' => 247.5, 'W' => 270, 'WNW' => 292.5,
			'NW' => 315, 'NNW' => 337.5}
		map[compass_string]
	end
end
