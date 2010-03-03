class Invite < ActiveRecord::Base
  belongs_to :member
  belongs_to :member_target, :class_name => 'Member', :foreign_key => 'member_id_target'        # the target of the friend relationship
  validates_presence_of :member, :member_target
  
  
  def is_valid?(receiver)
    
    !has_already_invited(receiver) &&
    !has_already_been_invited(receiver) &&
    self != receiver
  
  end
  
  def has_already_invited(receiver)
    
    self.member.invites_out.each do |invitation|
      if invitation.member_target == receiver
        return true
      end
    end
    
    false
  end
  
  def has_already_been_invited(receiver)
    
     self.member.invites_in.each do |invitation|
        if invitation.member == receiver
          return true
        end
      end
      
      false
  end
  
end
