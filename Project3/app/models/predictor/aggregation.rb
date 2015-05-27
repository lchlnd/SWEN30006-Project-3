class Aggregation
  def self.build_aggregate_hash(latitude, longitude)
    # Types of regressions
    types = ['rainfall', 'wind_direction', 'wind_speed', 'temperature']

    # Get weights
    location_weights = get_station_weights(latitude, longitude)

    # Get a hash which has a time value and readings for this time
    time_hash = get_time_hash(location_weights)

    # Total distance
    dist = 0
    location_weights.each { |k, v| dist += v }

    # Calculate weights
    weights = Hash.new
    location_weights.each { |k, v| weights[k] = (dist - v) / dist }

    results = Hash.new
    types.each do |type|
      results[type] = aggregate(time_hash, dist, weights, type)
    end

    return results
  end

  def self.get_station_weights(latitude, longitude)
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

  def self.get_time_hash(location_weights)
    # get first
    first_id = location_weights.first.first
    readings = Location.find(first_id).readings.where(:created_at => 12.hours.ago..DateTime.now)

    # Hash to store each time period of readings
    time_hash = Hash.new

    # Now find readings for other stations within small time frames
    readings.each do |reading|
      sim_readings = Array.new
      # Add current readings to sim_readings
      sim_readings << reading

      # Look at each station readings
      Hash[Array(location_weights)[1..-1]].each_pair do |id, dist|
        sim_readings << Location.find(id).readings.find_by(:created_at => (reading.created_at - 2.minutes)..(reading.created_at + 2.minutes))
      end

      time_hash[reading.created_at] = sim_readings
    end

    return time_hash
  end

  def self.aggregate(time_hash, total_distance, weights, type)
    # Hash for results
    results = Hash.new

    # Get a value for each time
    time_hash.each do |time, readings|
      num = 0.0

      # Weight for each reading
      readings.each do |reading|
        if reading.class == Reading
          if reading.send(type).value != nil
            num += (reading.send(type).value * weights[reading.location_id])
          end
        end
      end
      # Now calculate the value and add to results
      results[time] = num / total_distance
    end
    return results
  end

  def self.euclidean_distance(x_1, y_1, x_2, y_2)
    Math.sqrt((x_2 - x_1)**2 + (y_2 - y_1)**2)
  end
end