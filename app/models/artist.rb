class Artist < ActiveRecord::Base

  has_many :similarities, :dependent => :destroy
  accepts_nested_attributes_for :similarities

  validates_presence_of :name, :image

  validates_uniqueness_of :name

end
