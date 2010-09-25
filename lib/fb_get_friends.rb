require 'net/https'

module FbGetFriends

  def get_facebook_friends user, access_token
    pullOutFriends get_friends_response(user, access_token)
  end

  private

  def get_friends_response user, access_token
    url = user + '/friends?access_token=' + access_token
    Rails.logger.debug "Requesting from: #{url}"
    n   = Net::HTTP.new 'graph.facebook.com', 443
    req = Net::HTTP::Get.new url

    n.use_ssl     = true
    n.verify_mode = OpenSSL::SSL::VERIFY_NONE

    resp = n.request req

    body = resp.body
    Rails.logger.debug "Received from facebook: #{body}"
    body
  end

  def pullOutFriends download_response
    response = ActiveSupport::JSON.decode(download_response)['data']

    friends = []

    for blocks in response
      friends << [blocks['id'], blocks['name']]
    end

    friends
  end

end
