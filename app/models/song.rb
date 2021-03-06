class Song < ApplicationRecord

    has_many :party_songs
    has_many :parties, through: :party_songs

    def getVotes(party_id, song_id)
        puts "party: #{party_id}, song: #{song_id}"
        party_song = PartySong.find_by party_id: party_id, song_id: song_id
        puts "votes: #{party_song.votes}"
        party_song.votes
    end

	def self.add_song(artist, title)
		song = Song.find_by title: title, artist: artist

		if song != nil 
			return song
		end

		song = Song.create({
			title: title,
			artist: artist
		})

		return song
	end	
end
