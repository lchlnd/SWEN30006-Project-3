class Postcode < ActiveRecord::Base
  belongs_to :position

  has_many :locations
end
