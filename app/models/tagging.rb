class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :tran, class_name: "Transaction", foreign_key: "transaction_id"#:transaction

  validates_presence_of :tag_id

  validates_uniqueness_of :tag_id, :scope => :transaction_id

  after_destroy :remove_unused_tags

  after_save :set_transaction_admpart_tag
  after_destroy :unset_transaction_admpart_tag

  #attr_accessible :tag_id, :transaction_id

  private

  def set_transaction_admpart_tag
    tran.update_attribute(:admpart_tag_id, tag_id)
  end

  def unset_transaction_admpart_tag
    tran.update_attribute(:admpart_tag_id, nil)
  end

  def remove_unused_tags
    if tag.taggings.count.zero?
        tag.destroy
    end
  end
end
