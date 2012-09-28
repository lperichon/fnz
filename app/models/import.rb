class Import < ActiveRecord::Base
  belongs_to :business
  has_attached_file :upload

  validates :business, :presence => true
  validates_attachment :upload, :presence => true, :content_type => { :content_type => "text/csv" }

  attr_accessible :upload, :business_id
end