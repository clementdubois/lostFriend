class InvitesController < ApplicationController  
  before_filter :current_user_is_sender_required, :only => [:destroy]
  before_filter :current_user_is_target_required, :only => [:accept, :refuse]
  before_filter :current_user_is_implicated_in_invitation, :only => [:cancel]
  
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
    invitation = Invite.find(params[:invite_id])
    invitation.is_accepted = true
    invitation.save 
    
    member = Member.find(invitation.member_id)
    target = current_user
    
    member.reload
    target.reload
    
    flash[:notice] = "Vous êtes devenu amis"
    redirect_to edit_member_path(current_member)
  end
  
  def refuse
    invitation = Invite.find(params[:invite_id])
    invitation.is_accepted = false
    invitation.save 
    
    member = Member.find(invitation.member_id)
    target = current_user
    
    member.reload
    target.reload
    
    flash[:notice] = "Vous avez refuser l'invitation"
    redirect_to edit_member_path(current_member)
  end
  
  def destroy
    invite = Invite.find(params[:id])
    
    if invite.is_accepted.nil?
      invite.delete
      flash[:notice] = "L'invitation à bien été annulé"
      redirect_to edit_member_path(current_member)
    else
      flash[:error] = "Impossible de supprimer une invitation déja accepter ou refuser"
      redirect_to edit_member_path(current_member)
    end
      
  end
  
  def cancel
    invitation = Invite.find(params[:invite_id])
    invitation.is_accepted = false
    invitation.save 
    
    member = Member.find(invitation.member_id)
    target = current_member
    
    member.reload
    target.reload
    
    flash[:notice] = "Vous n'êtes plus amis"
    redirect_to edit_member_path(current_member)
  end
  
  private
  
  def current_user_is_implicated_in_invitation
    current_is_sender || current_is_target || access_denied
  end
  
  def current_user_is_sender_required
    current_is_sender || action_denied
  end
  
  def current_user_is_target_required
    current_is_target || action_denied
  end
  
  def current_is_sender
    current_member.id == Invite.find(params[:invite_id]).member_id
  end
  
  def current_is_target
    current_member.id == Invite.find(params[:invite_id]).member_id_target
  end
  

  
  def action_denied
    respond_to do |format|
      format.html do
        flash[:error] = "Cette action est interdite"
        store_location
        redirect_to edit_member_path(current_member)
      end
    end
  end



end