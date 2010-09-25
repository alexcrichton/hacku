require 'net/http'

module Stats

  API_KEY = '2116c8771c6a03bb89c24a0935bea3a4'

  def get_stats artists
    get_top_tags_str(artists) + get_popularity_stats_str(artists)
  end

  def get_tags_yql artist
    h = {
      :q => 'select toptags.tag.name, toptags.tag.count ' +
            '  from lastfm.artist.gettoptags where' +
            "  api_key='#{API_KEY}' and" +
            "  artist=\"#{artist}\"",
      :format => 'json',
      :env    => 'store://datatables.org/alltableswithkeys'
    }

    body = Net::HTTP.get 'query.yahooapis.com', '/v1/public/yql?' + h.to_query
    response = ActiveSupport::JSON.decode body

    ret_val = {};
    return ret_val if response['query']['results'].nil?

    tag_arr = response['query']['results']['lfm']

    tag_arr.each do |block|
      name = block['toptags']['tag']['name']
      count = block['toptags']['tag']['count'].to_i
      ret_val[name] = count
    end

    ret_val
  end

  def get_top_tags_str artists
    all_tags = {};
    artists.each do |artist|
      artist_tags = get_tags_yql(artist)
      artist_tags.each_pair do |tag, count|
        all_tags[tag] = [0, 0] if !all_tags.key?(tag)
        all_tags[tag][0] += count
        all_tags[tag][1] += 1 if (count >= 10) # ignore unpopular tags
      end
    end

    top_by_total = []
    top_by_num_artists = []
    (1..5).each do |i|
      new_tag_total = (all_tags.max {|a,b| a[1][0] <=> b[1][0]})[0]
      if (all_tags[new_tag_total][0] > 0)
        top_by_total.push(new_tag_total)
        all_tags[new_tag_total][0] = -1
      end

      new_tag_num_artists = (all_tags.max {|a,b| a[1][1] <=> b[1][1]})[0]
      if (all_tags[new_tag_num_artists][1] > 0)
        top_by_num_artists.push(new_tag_num_artists)
        all_tags[new_tag_num_artists][1] = -1
      end
    end

    ret_val = "top tags by total tags: \n  " +
      top_by_total.join("\n  ") + "\n" +
      "top tags by number of artists tagged: \n  " +
      top_by_num_artists.join("\n  ") +"\n"
    ret_val
  end

  def get_popularity_yql artist
    h = {
      :q => "select artist.stats.listeners, artist.stats.playcount " +
            "  from lastfm.artist.getinfo where" +
            "  api_key='#{API_KEY}' and" +
            "  artist=\"#{artist}\"",
      :format => 'json',
      :env    => 'store://datatables.org/alltableswithkeys'
    }

    body = Net::HTTP.get 'query.yahooapis.com', '/v1/public/yql?' + h.to_query
    response = ActiveSupport::JSON.decode body

    ret_val = [0, 0];
    return ret_val if response['query']['results'].nil?
    stats_arr = response['query']['results']['lfm']['artist']['stats']

    ret_val[0] = stats_arr['listeners'].to_i
    ret_val[1] = stats_arr['playcount'].to_i
    ret_val
  end

  def get_popularity_stats_str artists
    popularity_hash = {}

    artists.each do |artist|
      tmp = get_popularity_yql(artist)
      popularity_hash[artist] = [];
      popularity_hash[artist].push(tmp[0]);
      popularity_hash[artist].push(tmp[1]);
      popularity_hash[artist].push(tmp[0]);
      popularity_hash[artist].push(tmp[1]);
    end

    most_listeners = []
    least_listeners = []
    most_playcount = []
    least_playcount = []

    (1..5).each do |i|
      new_ml = (popularity_hash.max {|a,b| a[1][0] <=> b[1][0]})[0]
      if (popularity_hash[new_ml][0] > 0)
        most_listeners.push(new_ml)
        popularity_hash[new_ml][0] = 0
      end

      new_mp = (popularity_hash.max {|a,b| a[1][1] <=> b[1][1]})[0]
      if (popularity_hash[new_mp][1] > 0)
        most_playcount.push(new_mp)
        popularity_hash[new_mp][1] = 0
      end

      new_ll = (popularity_hash.min {|a,b| a[1][2] <=> b[1][2]})[0]
      if (popularity_hash[new_ll][2] < 500000000)
        least_listeners.push(new_ll)
        popularity_hash[new_ll][2] = 5000000000
      end

      new_lp = (popularity_hash.min {|a,b| a[1][3] <=> b[1][3]})[0]
      if (popularity_hash[new_lp][3] < 500000000)
        least_playcount.push(new_lp)
        popularity_hash[new_lp][3] = 500000000
      end
    end

    ret_val = "most popular artists by listeners:\n  " +
      most_listeners.join("\n  ") + "\n" +
      "most popular artists by playcount:\n  " +
      most_playcount.join("\n  ") + "\n" +
      "least popular artists by listeners:\n  " +
      least_listeners.join("\n  ") + "\n" +
      "least popular artists by playcount:\n  " +
      least_playcount.join("\n  ") + "\n"
    ret_val
  end
end
