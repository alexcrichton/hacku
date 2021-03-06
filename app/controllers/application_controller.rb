class ApplicationController < ActionController::Base
  protect_from_forgery
  layout Proc.new{ |c| c.request.xhr? ? false : 'application' }

  helper_method :current_user, :current_fbuid

  def current_user
    get_facebook_cookie['access_token']
  end

  def current_fbuid
    get_facebook_cookie['uid']
  end

  def require_user
    unless current_user
      flash[:error] = 'Need to be logged in!'

      redirect_to new_login_path
    end
  end

  def get_facebook_cookie
    value   = cookies["fbs_#{Rails.application.config.fb_app_id}"]
    return {} if value.blank?
    value   = value[1..-2]
    hash    = {}
    payload = ''
    value.split('&').each do |seg|
      k, v = seg.split '='
      hash[k] = v
      payload += seg if k != 'sig'
    end

    digest = Digest::MD5.hexdigest(payload + Rails.application.config.fb_secret)

    if digest == hash['sig']
      hash
    else
      {}
    end
  end
end
