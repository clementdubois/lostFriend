class InfosController < ApplicationController
  
  def friends
    
    @user = Member.find(params[:id])
    @friends = @user.friends
    
    respond_to do |format|
      format.xml { render :layout => false }
    end
    
  end
  
end
