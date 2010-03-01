module InvitesHelper
  
  def link_to_accept_invite(title, invite, options={})
    link_to h(title), accept_invite_path(invite), options
  end
  
  def link_to_refuse_invite(title, invite, options={})
    link_to h(title), refuse_invite_path(invite), options
  end
  
  def link_to_cancel_invite(title, invite, confirm, options={})
    if invite.is_accepted.nil?
      link_to h(title), invite, :confirm => confirm, :method => :delete
    end
  end
  
  def link_to_delete_friendship(title, friend, options={})
    invitation = Invite.all(:conditions => {:member_id => current_member.id, :member_id_target => friend.id})
    
    if invitation.length == 0 
      invitation = Invite.all(:conditions => {:member_id_target => current_member.id, :member_id => friend.id})
    end
    
    link_to h(title), cancel_invite_path(invitation), options
  end
  
end