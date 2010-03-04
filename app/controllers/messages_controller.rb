class MessagesController < ApplicationController
  
  def index
    
    @conversations = []
    
    Conversation.all.each do |conversation|
      if current_member.mailbox[:inbox].has_conversation?(conversation)
        @conversations << conversation
      end
    end
    
    
  end
  
  def create
    
    recipients = []
    params[:Destinataires].split(",").each do |dest|
      if Member.all(:conditions => {:login => dest}).first
        recipients << Member.all(:conditions => {:login => dest}).first
      end
    end
        
    current_member.send_message(recipients, params[:Message], params[:Sujet])
    
    redirect_to :action => :index
  end
  
  def reply
    
    current_member.reply_to_conversation(Conversation.find(params[:conv_id]), params[:Reponse])
    
    redirect_to :action => :index
  end
  
  def bulk
    
    
    redirect_to :action => :index
  end
  
  
end