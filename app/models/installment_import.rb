class InstallmentImport < Import
  has_and_belongs_to_many :installments, join_table: 'installment_imports_installments'
  alias_method :imported_records, :installments

  def handle_row(business, row)
    Installment.build_from_csv(business, row)
  end

end
