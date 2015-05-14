class Location < ActiveRecord::Base
  belongs_to :position
  belongs_to :postcode
end
