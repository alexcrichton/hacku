class SessionsController < ApplicationController

  def redirect
    redirect_to current_user ? graph_path : new_login_path
  end

  def new
    if get_facebook_cookie
      self.current_user = get_facebook_cookie
      redirect_to graph_path
    end
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

      self.current_user = access_token_hash['access_token']
      flash[:success]   = 'Authentication successful.'

      redirect_to graph_path
    end
  rescue RestClient::BadRequest # Thrown on an unsuccessful request
    redirect_to new_login_path
  end

  def destroy
    self.current_user = nil
    redirect_to new_login_path
  end

  protected

  def get_facebook_cookie
    value   = cookies["fbs_#{Rails.application.config.fb_app_id}"][1..-2]
    hash    = CGI.parse value
    payload = ''
    hash.each_pair do |k, v|
      p k, v[0]
      payload += [k, v[0]].join('=') if k != 'sig'
    end

    digest = Digest::MD5.hexdigest(payload + Rails.application.config.fb_secret)

    if digest == hash['sig'][0]
      hash['access_token']
    else
      nil
    end
  end

end
