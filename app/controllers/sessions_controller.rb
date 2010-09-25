class SessionsController < ApplicationController

  def redirect
    redirect_to current_user ? graph_path : new_login_path
  end

  def new
    if current_user
      # redirect_to graph_path
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

      flash[:success] = 'Authentication successful.'

      redirect_to graph_path
    end
  rescue RestClient::BadRequest # Thrown on an unsuccessful request
    redirect_to new_login_path
  end

end
