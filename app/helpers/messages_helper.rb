module MessagesHelper
  
  def choose_read_type_class(message)
    
    mail = Mail.all(:conditions => {:message_id => message.id, :member_id => current_member.id}).first
    
    if mail.read
      return "read"
    else
      return "unread"
    end
    
  end
  
end