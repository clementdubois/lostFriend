# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController

  # render new.rhtml
  def new
  end

  def create
    logout_keeping_session!
    member = Member.authenticate(params[:login], params[:password])
    if member && member.state == "active"
      
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_member = member
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      redirect_back_or_default('/')
      flash[:notice] = "Identification réussi"
    else
      note_failed_signin
      @login       = params[:login]
      @remember_me = params[:remember_me]
      redirect_to root_path()
    end
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "Vous avez été déconnecté."
    redirect_back_or_default('/')
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Impossible de vous connecter en tant que '#{params[:login]}'"
    flash[:notice] = "Peut être ne vous êtes vous pas encore inscrit"
    logger.warn "Authentification échoué en tant que '#{params[:login]}' pour #{request.remote_ip} à #{Time.now.utc}"
  end
end
