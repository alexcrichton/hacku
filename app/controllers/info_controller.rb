class InfoController < ApplicationController

  include FbGetArtists
  include FbGetFriends

  respond_to :js
  before_filter :require_user

  def similarity
    @artists = params[:q].split("\n").map{ |s| s.split(',') }.flatten
    @artists.map!(&:chomp)

    if true
      @output = {
        :images => {
          'a' => 'http://profile.ak.fbcdn.net/hprofile-ak-snc4/hs227.ash2/49223_745375464_9946_q.jpg',
          'b' => 'http://profile.ak.fbcdn.net/hprofile-ak-sf2p/hs353.snc4/41677_737168824_5825_s.jpg'
        },
        :similarities => ['a', 'b', 0.6],
        :artists      => ['a', 'b']
      }.to_json
    else
      args    = Escape.shell_command @artists
      @output = `#{Rails.root.join('script', 'yqlfetch.pl')} #{args}`
    end

    respond_with @output
  end

  def facebook_artists
    @artists = get_facebook_artists(params[:users].split(',').map(&:chomp),
      current_user)
    respond_with @artists
  end

  def grabfriends
    @friends = get_facebook_friends(get_facebook_cookie['uid'], current_user)
  end

end
