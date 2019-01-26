module TransactionsHelper

  def bip_tag_id(transaction)
    best_in_place transaction,
                  :tag_id,
                  as: :select,
                  collection: @business.tags.order(:name).map{|t| [t.id, t.name]},
                  url: business_transaction_path(@business, transaction)
  end
end
