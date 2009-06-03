module AuthenticatedSystem
  protected
    # Returns true or false if the user is logged in.
    # Preloads @current_base_user with the user model if they're logged in.
    def logged_in?
      current_base_user != :false
    end
    
    # Accesses the current base_user from the session.
    def current_base_user
      @current_base_user ||= (session[:base_user] && BaseUser.find_by_id(session[:base_user])) || :false
    end
    
    def current_base_user_id
      session[:base_user]
    end
    
    # Store the given base_user in the session.
    def current_base_user=(new_base_user)
      session[:base_user] = (new_base_user.nil? || new_base_user.is_a?(Symbol)) ? nil : new_base_user.id
      @current_base_user = new_base_user
    end
    
    # Check if the base_user is authorized.
    #
    # Override this method in your controllers if you want to restrict access
    # to only a few actions or if you want to check if the base_user
    # has the correct rights.
    #
    # Example:
    #
    #  # only allow nonbobs
    #  def authorize?
    #    current_base_user.login != "bob"
    #  end
    def authorized?
      true
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
      username, passwd = get_auth_data
      self.current_base_user ||= BaseUser.authenticate(username, passwd) || :false if username && passwd
      
      if logged_in? && authorized? && current_base_user.active?
        BaseLatestLogin.update_latest_login(self.current_base_user.id) # 最終ログイン日時更新
        true 
      else 
        access_denied
      end
    end
    
    # Redirect as appropriate when an access request fails.
    #
    # The default action is to redirect to the login screen.
    #
    # Override this method in your controllers if you want to have special
    # behavior in case the base_user is not authorized
    # to access the requested action.  For example, a popup window might
    # simply close itself.
    def access_denied
      respond_to do |accepts|
        accepts.html do
          store_location
          redirect_to :controller => '/base_user', :action => 'login', :return_to => session[:return_to]
        end
        accepts.xml do
          headers["Status"]           = "Unauthorized"
          headers["WWW-Authenticate"] = %(Basic realm="Web Password")
          render :text => "Could't authenticate you", :status => '401 Unauthorized'
        end
      end
      false
    end  
    
    # Store the URI of the current request in the session.
    #
    # We can return to this location by calling #redirect_back_or_default.
    def store_location
      session[:return_to] = request.request_uri
    end
    
    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default.
    # redirect_back をするときに session_id を持たせないと login に戻されちゃうのでその対応
    def redirect_back_or_default(default)
      return_to = session[:return_to]
      return_to = params[:return_to] if return_to.blank?
      if return_to
        if return_to.index(session_key)
          return_to.gsub!(/#{session_key}=[^&]*/, "#{session_key}=#{session.session_id}")
        else
          index = return_to.index('?')
          if index && index + 1 < return_to.length
            return_to << '&'
          elsif !index
            return_to << '?'
          end
          return_to << "#{session_key}=#{session.session_id}"
        end
        redirect_to(return_to)
      else
        redirect_to(default)
      end
      session[:return_to] = nil
    end

    # Inclusion hook to make #current_base_user and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_base_user, :logged_in?
    end

    # When called with before_filter :login_from_cookie will check for an :auth_token
    # cookie and log the user back in if apropriate
    def login_from_cookie
      return unless cookies[:auth_token] && !logged_in?
      user = BaseUser.find_by_remember_token(cookies[:auth_token])
      if user && user.remember_token?
        user.remember_me
        self.current_base_user = user
        cookies[:auth_token] = { :value => self.current_base_user.remember_token , :expires => self.current_base_user.remember_token_expires_at }
      end
    end

  private
    @@http_auth_headers = %w(X-HTTP_AUTHORIZATION HTTP_AUTHORIZATION Authorization)
    # gets BASIC auth info
    def get_auth_data
      auth_key  = @@http_auth_headers.detect { |h| request.env.has_key?(h) }
      auth_data = request.env[auth_key].to_s.split unless auth_key.blank?
      return auth_data && auth_data[0] == 'Basic' ? Base64.decode64(auth_data[1]).split(':')[0..1] : [nil, nil] 
    end

    def session_key
      request.session_options[:session_key] || '_session_id'
    end    
end
