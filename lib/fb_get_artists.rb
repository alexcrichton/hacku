require 'net/https'

module FbGetArtists

@@default_token = "2227470867|2.aHoc_MKR0rKcao1Ntnq1mw__.3600.1285380000-745375464|1o56hSrn1_pAebnsIl8pxf6v7xs"

  def get_facebook_artists(users, access_token = nil)
    access_token ||= @@default_token
    mapping = {}

    users.each do |user|
      mapping[user] = pullOutArtists get_facebook_response(user, access_token)
    end

    mapping
  end

  private

  def get_facebook_response(user = 'me', access_token = @@default_token)
    url = user +'/music?access_token=' + access_token
    Rails.logger.debug "Requesting from: #{url}"
    n   = Net::HTTP.new 'graph.facebook.com', 443
    req = Net::HTTP::Get.new(url)

    n.use_ssl     = true
    n.verify_mode = OpenSSL::SSL::VERIFY_NONE

    resp = n.request req

    body = resp.body
    Rails.logger.debug "Received from facebook: #{body}"
    body
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
