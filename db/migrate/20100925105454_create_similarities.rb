class CreateSimilarities < ActiveRecord::Migration
  def self.up
    create_table :similarities do |t|
      t.int, :parent_id
      t.string, :name
      t.string, :related_artist
      t.int :value

      t.timestamps
    end
  end

  def self.down
    drop_table :similarities
  end
end
