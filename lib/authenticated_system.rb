module AuthenticatedSystem
  protected
    # Returns true or false if the member is logged in.
    # Preloads @current_member with the member model if they're logged in.
    def logged_in?
      !!current_member
    end

    # Accesses the current member from the session. 
    # Future calls avoid the database because nil is not equal to false.
    def current_member
      @current_member ||= (login_from_session || login_from_basic_auth || login_from_cookie) unless @current_member == false
    end

    # Store the given member id in the session.
    def current_member=(new_member)
      session[:member_id] = new_member ? new_member.id : nil
      @current_member = new_member || false
    end

    # Check if the member is authorized
    #
    # Override this method in your controllers if you want to restrict access
    # to only a few actions or if you want to check if the member
    # has the correct rights.
    #
    # Example:
    #
    #  # only allow nonbobs
    #  def authorized?
    #    current_member.login != "bob"
    #  end
    def authorized?
      logged_in?
    end

    # Filter method to enforce a login requirement.
    #
    # To require logins for all actions, use this in your controllers:
    #
    #   before_filter :login_required
    #
    # To require logins for specific actions, use this in your controllers:
    #
    #   before_filter :login_required, :only => [ :edit, :update ]
    #
    # To skip this in a subclassed controller:
    #
    #   skip_before_filter :login_required
    #
    def login_required
      authorized? || access_denied
    end

    # Redirect as appropriate when an access request fails.
    #
    # The default action is to redirect to the login screen.
    #
    # Override this method in your controllers if you want to have special
    # behavior in case the member is not authorized
    # to access the requested action.  For example, a popup window might
    # simply close itself.
    def access_denied
      respond_to do |format|
        format.html do
          store_location
          redirect_to new_session_path
        end
        format.any do
          request_http_basic_authentication 'Web Password'
        end
      end
    end

    # Store the URI of the current request in the session.
    #
    # We can return to this location by calling #redirect_back_or_default.
    def store_location
      session[:return_to] = request.request_uri
    end

    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default.
    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

    # Inclusion hook to make #current_member and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_member, :logged_in?
    end

    # Called from #current_member.  First attempt to login by the member id stored in the session.
    def login_from_session
      self.current_member = Member.find_by_id(session[:member_id]) if session[:member_id]
    end

    # Called from #current_member.  Now, attempt to login by basic authentication information.
    def login_from_basic_auth
      authenticate_with_http_basic do |username, password|
        self.current_member = Member.authenticate(username, password)
      end
    end

    # Called from #current_member.  Finaly, attempt to login by an expiring token in the cookie.
    def login_from_cookie
      member = cookies[:auth_token] && Member.find_by_remember_token(cookies[:auth_token])
      if member && member.remember_token?
        cookies[:auth_token] = { :value => member.remember_token, :expires => member.remember_token_expires_at }
        self.current_member = member
      end
    end
    
    # This is ususally what you want; resetting the session willy-nilly wreaks
    # havoc with forgery protection, and is only strictly necessary on login.
    # However, **all session state variables should be unset here**.
    def logout_keeping_session!
      # Kill server-side auth cookie
      @current_member.forget_me if @current_member.is_a? Member
      @current_member = false     # not logged in, and don't do it for me
      kill_remember_cookie!     # Kill client-side auth cookie
      session[:member_id] = nil   # keeps the session but kill our variable
      # explicitly kill any other session variables you set
    end

    # The session should only be reset at the tail end of a form POST --
    # otherwise the request forgery protection fails. It's only really necessary
    # when you cross quarantine (logged-out to logged-in).
    def logout_killing_session!
      logout_keeping_session!
      reset_session
    end
    
    #
    # Remember_me Tokens
    #
    # Cookies shouldn't be allowed to persist past their freshness date,
    # and they should be changed at each login

    # Cookies shouldn't be allowed to persist past their freshness date,
    # and they should be changed at each login

    def valid_remember_cookie?
      return nil unless @current_member
      (@current_member.remember_token?) && 
        (cookies[:auth_token] == @current_member.remember_token)
    end
    
    # Refresh the cookie auth token if it exists, create it otherwise
    def handle_remember_cookie!(new_cookie_flag)
      return unless @current_member
      case
      when valid_remember_cookie? then @current_member.refresh_token # keeping same expiry date
      when new_cookie_flag        then @current_member.remember_me 
      else                             @current_member.forget_me
      end
      send_remember_cookie!
    end
  
    def kill_remember_cookie!
      cookies.delete :auth_token
    end
    
    def send_remember_cookie!
      cookies[:auth_token] = {
        :value   => @current_member.remember_token,
        :expires => @current_member.remember_token_expires_at }
    end
end
