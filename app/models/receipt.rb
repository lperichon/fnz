class Receipt < ActiveRecord::Base

  include HasCurrency
  include Shared::HasCents
  include Shared::HasSecret

  has_cents_for(:amount)

  belongs_to :business
  belongs_to :trans, class_name: "Transaction", foreign_key: "transaction_id"
  belongs_to :contact


end
