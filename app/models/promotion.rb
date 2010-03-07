class Promotion < ActiveRecord::Base
  has_many :line_curriculums, :as => :place
  has_many :members, :through => :line_curriculums
  
end
