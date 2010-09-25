class Similarity < ActiveRecord::Base

  belongs_to :artist

  validates_presence_of :related_artist, :score

end
