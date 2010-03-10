class MembersController < ApplicationController
  before_filter :find_member, :only => [:suspend, :unsuspend, :destroy, :purge, :show]
  before_filter :login_required, :only => [:index, :show, :edit, :update, :add, :destroy]
  before_filter :authorized, :only => [:add, :destroy]

  helper_method :admin?
  
  def index
    @member = Member.new
    @members = Member.all(:conditions => {:state => 'active'})
    @members_pending = Member.all(:conditions => {:state => 'pending'})
    
    2.times {@member.line_curriculums.build}
  end 
  
  def show
    @friends = @member.friends
    
    @invites_in = @member.invites_in.all(:conditions => {:is_accepted => nil})
    @invites_out = @member.invites_out.all(:conditions => {:is_accepted => nil})
    
  end
  
  # render new.rhtml
  def new
    @member = Member.new
  end
 
  def create    
    #Find member in the database that have the first and the activation_code indicated in the subscription field
    @member = Member.first(:conditions => {:first_name => params[:member][:first_name], :activation_code => params[:member][:activation_code]})
    find = true unless @member.nil?
    find = false if @member.nil?
        
    respond_to do |format|
      if(find && @member.state != "active") #if a member with the first name and the activation_code is find, it means that we can activate him
        
        #we can update the informations 
        if params[:member][:login].empty?
          params[:member][:login] = params[:member][:activation_code]
        end
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
    
  end
  
  def edit
    @member = current_member

    1.times do 
      school = @member.schools.build
    end
  end
  
  def update
    @member = current_member
    
    respond_to do |format|
      if @member.update_attributes(params[:member])
        # unless params[:school_line][:year1].empty?
        #   line = LineCurriculum.all(:conditions => {:member_id => current_member.id, :place_type => "School", :place_id => @member.})
        # end
        flash[:notice] = "Vos informations ont bien été enregistrées"
        format.html { redirect_to(edit_member_path(@member)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @member.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @member.destroy
    flash[:notice] = "Le membre à bien été supprimé"
    redirect_to members_path
  end
  
  def add
    member = Member.create(params[:member])
    member.save(false)
    unless params[:promotion1][:year1].empty? && params[:promotion1][:degree1].empty?
      promotion = Promotion.find_by_degree(params[:promotion1][:degree1])
      promo = member.line_curriculums.create(:ending_year => params[:promotion1][:year1],
                                             :beginning_year => params[:promotion1][:year1].to_i-2,
                                             :place_id => promotion.id,
                                             :place_type => "Promotion")
    end
    unless params[:promotion2][:year2].empty? && params[:promotion2][:degree2].empty?
      promotion = Promotion.find_by_degree(params[:promotion2][:degree2])
      promo = member.line_curriculums.create(:ending_year => params[:promotion2][:year2],
                                             :beginning_year => params[:promotion2][:year2].to_i-2,
                                             :place_id => promotion.id,
                                             :place_type => "Promotion")
    end

    
    flash[:notice] = "Le membre à bien été enregistré"
    
    redirect_to members_path
  end

  def suspend
    @member.suspend! 
    redirect_to members_path
  end

  def unsuspend
    @member.unsuspend! 
    redirect_to members_path
  end

  def purge
    @member.destroy
    redirect_to members_path
  end
  
  # There's no page here to update or destroy a member.  If you add those, be
  # smart -- make sure you check that the visitor is authorized to do so, that they
  # supply their old password along with a new one to update it, etc.
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


  def find_member
    @member = Member.find(params[:id])
  end
  
end
