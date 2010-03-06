class School < ActiveRecord::Base
  has_many :line_curriculum, :as => :place
  has_many :members, :through => :line_curriculum
end
