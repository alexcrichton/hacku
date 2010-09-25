class InfoController < ApplicationController

  include FbGetArtists
  include FbGetFriends
  include Similarities

  respond_to :js
  before_filter :require_user

  def similarity

    @ids = params['friends_input'].split(",")
    # @ids << get_facebook_cookie['uid']

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
      @output = get_similarities @artists
    end

    respond_with @output
  end

  def grabfriends
    @friends = Rails.cache.fetch(get_facebook_cookie['uid'] + '_friends') do
      me     = MiniFB.get current_user, 'me'
      me_arr = [current_fbuid, me['first_name'] + ' ' + me['last_name']]
      get_facebook_friends(current_fbuid, current_user) + [me_arr]
    end
  end

end
