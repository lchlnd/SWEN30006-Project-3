class Aggregation
  EPSILON = 0.0001
<<<<<<< HEAD
  TYPES = %w{rainfall wind_direction wind_speed temperature}


  # @param latitude Latitude coordinate of point of interest
  # @param longitude Longitude coordinate of point of interest
  # @return Hash of the form {regression_type => {time_stamp => value ...} ...}.
  def self.build_aggregate_hash(latitude, longitude)

    # Locations within range
    location_distances = get_station_distances(latitude, longitude, 5)

    # Get all readings for each time period of interest
    time_hash = get_time_hash(location_distances, 12)

    # Calculate weights for each location
    weights = Hash.new

    location_distances.each { |k, v| weights[k] = (v >= EPSILON ? 1/v : 1/EPSILON)  }

    # Sum the weights
    sum_weights = 0
    weights.each { |k, v| sum_weights += v }

    # Aggregate for each value type
    results = Hash.new

    TYPES.each do |type|
      results[type] = aggregate(time_hash, sum_weights, weights, type)
    end


    return results
  end

  # @param latitude Latitude coordinate of point of interest
  # @param longitude Longitude coordinate of point of interest
  # @param num Number of stations to return
  # @return Hash in form of {location_id => distance}
  def self.get_station_distances(latitude, longitude)

    all_stations = Hash.new

    # Get each distance
    Location.where(active: true).each do |location|
      all_stations[location.id] = self.euclidean_distance(longitude, latitude, location.position.longitude, location.position.latitude)
    end

    # Oder descending
    all_stations = all_stations.sort_by {|_key, value| value}.to_h

    # Get five closest
    results = Hash.new

    Hash[Array(all_stations)[0..4]].each_pair do |id, dist|
      results[id] = dist
    end
    return results
  end

  # @param location_distances Hash in form of {location_id => distance}
  # @param hours Range to find readings
  # @return Hash in form of {:time_stamp => [reading_from_station_1, reading_from_station_2, ...] ...}
  def self.get_time_hash(location_distances, hours)

    # Find latest readings for first location
    first_id = location_distances.first.first
    readings = Location.find(first_id).readings.where(:created_at => hours.hours.ago..DateTime.now)

    # Find readings from other stations at approx same time as first stations readings
    time_hash = Hash.new
    readings.each do |reading|
      sim_readings = Array.new
      # Add current readings to simultaneous readings
      sim_readings << reading

      # Get readings for each location
      Hash[Array(location_distances)[1..-1]].each_pair do |id, dist|
        # Look within time stamp of 2 minutes each way
        sim_readings << Location.find(id).readings.find_by(:created_at => (reading.created_at - 2.minutes)..(reading.created_at + 2.minutes))
      end
      time_hash[reading.created_at] = sim_readings
    end

    return time_hash
  end

  # @param time_hash Hash in form of {:time_stamp => [reading_from_station_1, reading_from_station_2, ...] ...}
  # @param sum_weights Sum of all of the location weights
  # @param weights Hash in form of {location_id => weight ...}
  # @param type Type of data to aggregate
  def self.aggregate(time_hash, sum_weights, weights, type)

    # Hash for results
    results = Hash.new

    # Want to get one data value for each time stamp
    time_hash.each do |time, readings|
      num = 0.0

      # Calculate the weight for each reading
      readings.each do |reading|
        if reading.class == Reading
          num += (reading.send(type).value * weights[reading.location_id]) if reading.send(type).value != nil
        end
      end
      # Now calculate the value and add to results
      results[time] = num / sum_weights
    end
    return results
  end

  def self.euclidean_distance(x_1, y_1, x_2, y_2)
    Math.sqrt((x_2 - x_1)**2 + (y_2 - y_1)**2)
  end
end