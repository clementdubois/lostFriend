class InvitesController < ApplicationController

  def create
    message = current_member.first_name+" "+current_member.last_name+" souhaite devenir votre ami"
    
    member_target = Member.find(params[:member_target])
    @invite = Invite.create(:member => current_member, :member_target => member_target, :message => message)
    
    if @invite.save
      flash[:notice] = "Votre demande à bien été envoyée"
      redirect_to members_path
    else
      flash[:error] = "Impossible d'ajouter cet ami"
      redirect_to members_path
    end
    
  end
  
  def accept
    
  end
  
  def refuse
    
  end


end