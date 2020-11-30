class InscriptionTransaction < ActiveRecord::Base
  self.table_name = :inscriptions_transactions

  belongs_to :inscription
  belongs_to :trans, foreign_key: 'transaction_id', class_name: "Transaction"#:transaction

  #attr_accessible :transaction_id

  after_save :update_inscription
  after_destroy :update_inscription
  alias_method :transactions, :trans

  def update_inscription
    inscription.update_balance
  end
end
