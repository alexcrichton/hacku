require 'net/https'

module FbGetArtists

@@default_token = "2227470867|2.mUu_AKppyrFnQmg_te2Tug__.3600.1285372800-541249364|zs_OrcCXk2yftNBHvQAUKj9Dl6M"

	def self.download(user='me', access_token = @@default_token)

		url = user +'/music?access_token=' +access_token
		n = Net::HTTP.new 'graph.facebook.com', 443
		req = Net::HTTP::Get.new(url)
		n.use_ssl = true
		n.verify_mode = OpenSSL::SSL::VERIFY_NONE
		resp = n.request req

		resp.body

	end

	def self.pullOutArtists(download_response)

		response = ActiveSupport::JSON.decode(download_response)["data"]

		artists = []

		for blocks in response
			artists << blocks["name"]
		end

		artists
	
	end

	def self.run(user_one='me', user_two='me', access_token = @@default_token)

		artists_one = self.pullOutArtists(download(user_one, access_token))
		artists_two = self.pullOutArtists(download(user_two, access_token))

		mapping = {user_one => artists_one, user_two => artists_two}

		mapping
	end

end
