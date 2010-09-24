class InfoController < ApplicationController

  respond_to :js

  def similarity
    @artists = params[:q].split("\n").map{ |s| s.split(',') }.flatten
    @artists.map!(&:chomp)

    if true
      @output = {
        :images => {:a => 'http://nowhere'},
        :similarities => {:a => {:b => 3}}
      }.to_json
    else
      @output = system 'program here', *@artists
    end

    respond_with @output
  end

end
