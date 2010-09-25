require 'net/https'

module FbGetArtists

@@default_token = "2227470867|2.mUu_AKppyrFnQmg_te2Tug__.3600.1285372800-541249364|zs_OrcCXk2yftNBHvQAUKj9Dl6M"

  def get_facebook_artists(users, access_token = @@default_token)
    mapping = {}

    users.each do |user|
      mapping[user] = pullOutArtists get_facebook_response(user), access_token
    end

    mapping
  end

  private

  def get_facebook_response(user = 'me', access_token = @@default_token)

    url = user +'/music?access_token=' +access_token
    n = Net::HTTP.new 'graph.facebook.com', 443
    req = Net::HTTP::Get.new(url)
    n.use_ssl = true
    n.verify_mode = OpenSSL::SSL::VERIFY_NONE
    resp = n.request req

    resp.body

  end

  def pullOutArtists(download_response)
    response = ActiveSupport::JSON.decode(download_response)["data"]

    artists = []

    for blocks in response
      artists << blocks["name"]
    end

    artists
  end

end
