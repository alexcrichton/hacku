class InfoController < ApplicationController

  respond_to :js

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
        :artists => ['a', 'b']
      }.to_json
    else
      @output = system 'program here', *@artists
    end

    respond_with @output
  end

end
