module Similarities

  def get_similarities artists
    output_hash = {
      :images => {},
      :artists => artists,
      :similarities => Hash.new{ |h, k| h[k] = {} }
    }

    artists.each do |artist|
      args   = Escape.shell_command artist
      output = `#{Rails.root.join('script', 'yqlfetch.pl')} #{args}`
      hash   = ActiveSupport::JSON.decode output

      output_hash[:images][artist] = hash['image']

      hash['similarities'].each do |artist1, artist2, relevance|
        output_hash[:similarities][artist1][artist2] = relevance
        output_hash[:similarities][artist2][artist1] = relevance
      end
    end

    output_hash
  end

end
