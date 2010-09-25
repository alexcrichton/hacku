class SessionsController < ApplicationController

  def new
  end

  def create
    if params[:error_reason] == 'user_denied'
      redirect_to new_login_path
    else
      access_token_hash = MiniFB.oauth_access_token(
          Rails.application.config.fb_app_id,
          login_url,
          Rails.application.config.fb_secret,
          params[:code])

      @access_token = access_token_hash['access_token']

      @res = MiniFB.get(@access_token, 'me')

      self.current_user = @access_token
      flash[:success]   = 'Authentication successful.'

      redirect_to root_path
    end
  rescue RestClient::BadRequest # Thrown on an unsuccessful request
    redirect_to new_login_path
  end

  def destroy
    self.current_user = nil
    redirect_to new_login_path
  end

end
