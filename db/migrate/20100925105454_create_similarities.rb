class CreateSimilarities < ActiveRecord::Migration
  def self.up
    create_table :similarities do |t|
      t.integer :artist_id
      t.string :related_artist
      t.float  :score

      t.timestamps
    end
  end

  def self.down
    drop_table :similarities
  end
end
