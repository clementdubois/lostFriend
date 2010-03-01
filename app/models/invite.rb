class Invite < ActiveRecord::Base
  belongs_to :member
  belongs_to :member_target, :class_name => 'Member', :foreign_key => 'member_id_target'        # the target of the friend relationship
  validates_presence_of :member, :member_target
  
end
