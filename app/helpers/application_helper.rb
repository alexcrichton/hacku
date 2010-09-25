module ApplicationHelper
  def fb_login_url
    @login_url = MiniFB.oauth_url(
        Rails.application.config.fb_app_id, login_url,
        :scope => 'user_interests,user_likes,friends_likes,friends_interests')
  end
end
