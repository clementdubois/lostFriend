class Firm < ActiveRecord::Base
  has_many :line_curriculums, :as => :place
  has_many :members, :through => :line_curriculum
end
