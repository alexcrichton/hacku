require 'net/http'

module Similarities

  API_KEY = '2116c8771c6a03bb89c24a0935bea3a4'

  def get_similarities artists
    images       = []
    similarities = []
    outputs      = artists.each_with_index do |artist, index|
      db = Artist.where(:name => artist).first

      if db.nil?
        db       = Artist.new
        output   = get_yql artist
        db.image = output[:images][artist]
        db.name  = artist

        output[:similarities].each do |ignored, related, score|
          db.similarities << Similarity.new(
            :related_artist => related,
            :score          => score.to_f
          )
        end

        db.save!
      end

      images << db.image

      db.similarities.each do |similarity|
        artists.each_with_index do |a, i|
          if similarity.related_artist == a
            similarities[i]     ||= Array.new artists.size, 0
            similarities[index] ||= Array.new artists.size, 0
            similarities[i][index] = similarity.score
            similarities[index][i] = similarity.score
          end
        end
      end
    end

    {
      :images       => images,
      :artists      => artists,
      :similarities => similarities
    }.to_json
  end

  protected

  def get_yql artist
    h = {
      :q => 'select similarartists.artist.name,similarartists.artist.match ' +
            '  from lastfm.artist.getsimilar where' +
            "  api_key='#{API_KEY}' and" +
            "  limit=\"100\" and artist=\"#{artist}\"",
      :format => 'json',
      :env    => 'store://datatables.org/alltableswithkeys'
    }

    body = Net::HTTP.get 'query.yahooapis.com', '/v1/public/yql?' + h.to_query
    response = ActiveSupport::JSON.decode body

    arr = response['query']['results']['lfm']

    ret_val = {:images => {}, :similarities => []}

    arr.each do |block|
      name  = block['similarartists']['artist']['name']
      score = block['similarartists']['artist']['match'].to_f
      ret_val[:similarities] << [artist, name, score.to_f]
    end

    ret_val[:images][artist] = get_image artist

    ret_val
  end

  def get_image artist
    h = {
      :q => 'select artist.image from lastfm.artist.getinfo where' +
            "  api_key='#{API_KEY}' and" +
            "  artist=\"#{artist}\"",
      :format => 'json',
      :env    => 'store://datatables.org/alltableswithkeys'
    }

    body = Net::HTTP.get 'query.yahooapis.com', '/v1/public/yql?' + h.to_query
    response = ActiveSupport::JSON.decode body

    arr = response['query']['results']['lfm']

    block = arr.detect do |b|
      b['artist']['image']['size'] == 'extralarge'
    end || arr.first

    block['artist']['image']['content']
  end

end
