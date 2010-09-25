class InfoController < ApplicationController

  include FbGetArtists
  include FbGetFriends
  include FetchAndCache

  respond_to :js
  before_filter :require_user

  def similarity

    @ids = params['friends_input'].split(",")
    @ids << get_facebook_cookie['uid']

    @hash = get_facebook_artists @ids, current_user

    @artists = @hash.values.flatten.uniq

    if false
      @output = {
        :images => {
          'a' => 'http://profile.ak.fbcdn.net/hprofile-ak-snc4/hs227.ash2/49223_745375464_9946_q.jpg',
          'b' => 'http://profile.ak.fbcdn.net/hprofile-ak-sf2p/hs353.snc4/41677_737168824_5825_s.jpg'
        },
        :similarities => ['a', 'b', 0.6],
        :artists      => ['a', 'b']
      }.to_json
    else
      #args    = Escape.shell_command @artists
      #@output = `#{Rails.root.join('script', 'yqlfetch.pl')} #{args}`
      for artist in @artists
 	p fetch(artist)
      end
   end

    respond_with @output
  end

  def grabfriends
    @friends = Rails.cache.fetch(get_facebook_cookie['uid'] + '_friends') do
      get_facebook_friends(get_facebook_cookie['uid'], current_user)
    end
  end

end
