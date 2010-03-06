class MessagesController < ApplicationController
  before_filter :authorized, :only => [:send_all]
  
  helper_method :admin?
  
  def index
    
    @conversations = []
    
    Conversation.all.each do |conversation|
      if current_member.mailbox[:inbox].has_conversation?(conversation)
        @conversations << conversation
      end
    end
    
    
  end
  
  def create
    
    if admin?(current_member) && params[:Destinataires] == "all"
      send_all(params)
      return
    end
    
    recipients = []
    params[:Destinataires].split(",").each do |dest|
      if Member.all(:conditions => {:login => dest}).first
        recipients << Member.all(:conditions => {:login => dest}).first
      end
    end
        
    current_member.send_message(recipients, params[:Message], params[:Sujet])
    
    flash[:notice] = "Votre message à bien été envoyé"
    
    redirect_to :action => :index
  end
  
  def reply
    
    current_member.reply_to_conversation(Conversation.find(params[:conv_id]), params[:Reponse])
    
    
    flash[:notice] = "Votre réponse à bien été envoyé"
    redirect_to :action => :index
  end
  
  def bulk
    
    
    redirect_to :action => :index
  end
  
  # Send à message to all the student
  def send_all(params)
    
    recipients = Member.all(:conditions => {:state => "active"})
    current_member.send_message(recipients, params[:Message], params[:Sujet])
    
    flash[:notice] = "Vous avez bien envoyé le mesaage à tous les membres"
    
    redirect_to member_messages_path(current_member)
  end
  
  
  def admin?(member)
    member.login == "admin"
  end

protected
  def authorized
    unless admin?(current_member)
      flash[:error] = "Vous n'avez pas la permission"
      redirect_to members_path
      false
    end
    
  end
  
  
end