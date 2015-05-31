class Location < ActiveRecord::Base
  belongs_to :position
  belongs_to :postcode

  has_many :readings

  SECPERMIN = 60
  RAIN_THRESHOLD = 1
  WARM_THRESHOLD = 25
  WINDY_THRESHOLD = 30
  FREEZING_THRESHOLD = 5
  STILL_THRESHOLD = 3

  def current_conditions
  	r = self.readings.last
  	if((Time.now - r.created_at) < 30*SECPERMIN)

  		if(r.rainfall.value - Reading.find(r.id - 1).rainfall.value >= RAIN_THRESHOLD)
  			cond = "raining"
  		elsif(r.temperature.value >= WARM_THRESHOLD)
  			cond = "warm"
      elsif(r.temperature.value <= FREEZING_THRESHOLD)
        cond = "freezing"
  		elsif(r.wind_speed.value >= WINDY_THRESHOLD)
  			cond = "windy"
      elsif(r.wind_speed.value <= STILL_THRESHOLD)
        cond = "still"
  		else
  			cond = "mild"
  		end


  		return {"current_temp" => r.temperature.value.to_s, "current_cond" => cond}
  	else
  		return {"current_temp" => "null", "current_cond" => "null"}
  	end
  end
end
