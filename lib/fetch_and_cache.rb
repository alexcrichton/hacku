module FetchAndCache

	def fetch(artist)

		grab_artist =  Artists.where(:name => artist).first
		
		if(grab_artist == nil) 
			grab_artist = cache(artist)
		end

		grab_artist

	end


	def cache(artist)

		get_info = ActiveSupport::Decode(`#{Rails.root.join('script', 'yqlfetch.pl')} #{Escape.shell_command artist}`)

		new_artist = Artists.new;
		new_artist.name = artist;
		new_artist.image = get_info['images'][artist]
	#	new_artist.similarities = get_info['similarities']

		new_artist
	end
end
