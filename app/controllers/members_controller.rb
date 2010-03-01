class MembersController < ApplicationController
  before_filter :find_member, :only => [:suspend, :unsuspend, :destroy, :purge]

  def index
    @members = Member.all
  end 
  
  def show
    @member = current_member
  end
  
  # render new.rhtml
  def new
    @member = Member.new
  end
 
  def create    
    #Find member in the database that have the first and last name indicated in the subscription field
    @member = Member.first(:conditions => {:first_name => params[:member][:first_name], :activation_code => params[:member][:activation_code]})
    find = true unless @member.nil?
    find = false if @member.nil?
        
    respond_to do |format|
      if(find && @member.state != "active") #if a member with the first name and the activation_code is find, it means that we can activate him
        
        #we can update the informations 
        if @member.update_attributes(params[:member])
          @member.update_attribute("state", "active")
          self.current_member = @member # !! now logged in
          flash[:notice] = "Vos informations ont bien été enregistrées"
          format.html { redirect_to(root_path()) }
          format.xml  { head :ok }
        else
          flash[:error] = @member.errors.to_s
          format.html { render :action => 'new' }
          format.xml  { render :xml => @member.errors, :status => :unprocessable_entity }
        end
      
      elsif(@member.nil?)     #If no member find, it means that the person who want to subscribe is not in the database 
        flash[:error] = "Nous sommes désolés mais vous n'apparaissez pas dans notre base de données d'anciens étudiants"
        format.html { redirect_to(signup_path()) }
      elsif(@member.state == "active")     #If the state is "active" it means that his account is already active
        flash[:error] = "Votre compte est déjà activé. Veuillez vous connecter avec votre login et votre mot de passe"
        format.html { redirect_to(login_path()) }
      end
    
    end
    
    
    # @member = Member.new(params[:member])
    # success = @member && @member.save
    # if success && @member.errors.empty?
    #         # Protects against session fixation attacks, causes request forgery
    #   # protection if visitor resubmits an earlier form using back
    #   # button. Uncomment if you understand the tradeoffs.
    #   # reset session
    #   self.current_member = @member # !! now logged in
    #   flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
    # else
    #   flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
    #   render :action => 'new'
    # end
  end
  
  def edit
    @member = current_member
    @friends = @member.friends
    @waiting_for_acceptance 
    @waiting_for_my_acceptance 
    
    logger.debug @member.invites_in.to_yaml
    logger.debug @member.invites_out.to_yaml
    
    @member.invites_in.each do |invite|
      @waiting_for_acceptance += Member.find(invite.member_id_target)
    end
    @member.invites_out.each do |invite|
      @waiting_for_my_acceptance += Member.find(invite.member_id)
    end

  end
  
  def update
    @member = current_member
    
    respond_to do |format|
      if @member.update_attributes(params[:member])
        flash[:notice] = "Vos informations ont bien été enregistrées"
        format.html { redirect_to(root_path()) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @member.errors, :status => :unprocessable_entity }
      end
    end
  end

  def suspend
    @member.suspend! 
    redirect_to members_path
  end

  def unsuspend
    @member.unsuspend! 
    redirect_to members_path
  end

  def destroy
    @member.delete!
    redirect_to members_path
  end

  def purge
    @member.destroy
    redirect_to members_path
  end
  
  # There's no page here to update or destroy a member.  If you add those, be
  # smart -- make sure you check that the visitor is authorized to do so, that they
  # supply their old password along with a new one to update it, etc.

protected
  def find_member
    @member = Member.find(params[:id])
  end
  
end
