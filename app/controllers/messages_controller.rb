class MessagesController < ApplicationController
  before_filter :authorized, :only => [:send_all]

  helper_method :admin?

  def index

    @conversations = []

    Conversation.all.each do |conversation|
      if current_member.mailbox[:inbox].has_conversation?(conversation) || current_member.mailbox[:sentbox].has_conversation?(conversation) 
        @conversations << conversation
      end
    end


  end

  def choose_action
    if params[:reply]
      reply(params[:response])
    # elsif params[:bulk]
    #   bulk(params[:checked])
    elsif params[:mark_read]
      as_read(params[:checked])
    elsif params[:mark_unread]
      as_unread(params[:checked])
    end

    redirect_to :action => "index"
  end
  
  def new
    @conversation = Conversation.new
  end
  
  def show
    @conversation = Conversation.find(params[:id])
    render :conversation
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

  def reply(params)

    current_member.reply_to_conversation(Conversation.find(params[:conversation_id]), params[:message])

    flash[:notice] = "Votre réponse à bien été envoyé"
  end

  def bulk(params)
    # mails = Mail.all(:conditions => {:conversation_id => params[:conv_ids], :member_id => current_member.id })
    #     
    #     mails.each do |mail|
    #       mail.move_to(:trash)
    #     end  
    #      
    #     flash[:notice] = "Les conversations ont été supprimées, vous n'en faites maintenant plus partie"
  end

  def as_read(params)
    convs = Conversation.all(params[:conv_ids])
    convs.each do |conv|
      current_member.read_conversation(conv)
    end
    
    flash[:notice] = "Les conversations ont été marqué comme lus"  
  end

  def as_unread(params)
     convs = Conversation.all(params[:conv_ids])
      convs.each do |conv|
        current_member.unread_conversation(conv)
      end
   
    flash[:notice] = "Les conversations ont été marqué comme non lus"
  end


  # Send a message to all the student
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