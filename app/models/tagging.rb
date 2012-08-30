class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :transaction

  validates_presence_of :tag_id

  validates_uniqueness_of :tag_id, :scope => :transaction_id

  after_destroy :remove_unused_tags

  attr_accessible :tag_id, :transaction_id

  private

  def remove_unused_tags
    if tag.taggings.count.zero?
        tag.destroy
    end
  end
end