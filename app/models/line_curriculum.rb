class LineCurriculum < ActiveRecord::Base
  belongs_to :member
  belongs_to :place, :polymorphic => true
   
end
