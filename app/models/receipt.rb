class Receipt < ActiveRecord::Base

  include HasCurrency
  include Shared::HasCents
  include Shared::HasSecret

  has_cents_for(:amount)

  belongs_to :business
  has_many :trans, class_name: "Transaction"
  belongs_to :contact


end
