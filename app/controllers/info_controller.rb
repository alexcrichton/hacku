class InfoController < ApplicationController

  include FbGetArtists
  include FbGetFriends
  include Similarities
  include Stats

  respond_to :js
  before_filter :require_user

  def similarity

    @ids = params['friends_input'].split(",")
    @friends = @ids.map do |id|
      current_friends.detect{ |a| a[0] == id }[1]
    end

    @hash = get_facebook_artists @ids, current_user

    @artists = @hash.values.flatten.uniq
    @output  = get_similarities @artists

    respond_with @output
  end

  def grabfriends
    @friends = current_friends
  end

  def statistics
    @stats = get_stats params[:artists].split(',')

    respond_with @stats
  end

  protected

  def current_friends
    Rails.cache.fetch(get_facebook_cookie['uid'] + '_friends') do
      me     = MiniFB.get current_user, 'me'
      me_arr = [current_fbuid, me['first_name'] + ' ' + me['last_name']]
      get_facebook_friends(current_fbuid, current_user) + [me_arr]
    end
  end

end
