class TransactionImport < Import
  has_and_belongs_to_many :transactions, :join_table => "imports_transactions", :foreign_key => "import_id"
  alias_method :imported_records, :transactions

  validates_attachment :upload, :presence => true, :content_type => { :content_type => "text/csv" }

  def handle_row(business, row)
    Transaction.build_from_csv(business, row)
  end

end