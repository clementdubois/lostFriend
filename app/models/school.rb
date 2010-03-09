class School < ActiveRecord::Base
  has_many :line_curriculums, :as => :place
  has_many :members, :through => :line_curriculums
  
  accepts_nested_attributes_for :line_curriculums

end
