require 'net/https'

module FbGetArtists

  def get_facebook_artists users, access_token
    mapping = {}

    users.each do |user|
      mapping[user]  = Rails.cache.fetch(user + '_artists') do
        pullOutArtists get_facebook_response(user, access_token)
      end
    end

    mapping
  end

  private

  def get_facebook_response user, access_token
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

  def pullOutArtists download_response
    response = ActiveSupport::JSON.decode(download_response)["data"]

    artists = []

    for blocks in response
      artists << blocks["name"]
    end

    artists
  end

end
