class TransactionImport < Import
  has_and_belongs_to_many :trans,
                          class_name: "Transaction",
                          join_table: "imports_transactions",
                          foreign_key: "import_id"
  alias_method :imported_records, :trans

  validates_attachment :upload, :presence => true, :content_type => { :content_type => "text/csv" }

  before_destroy :destroy_transactions

  def handle_row(business, row)
    Transaction.build_from_csv(business, row)
  end

  def destroy_transactions
    trans.readonly(false).destroy_all
  end

end
