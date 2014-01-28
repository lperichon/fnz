class SaleImport < Import
  has_and_belongs_to_many :sales
  alias_method :imported_records, :sales

  def handle_row(business, row)
    sale = Sale.build_from_csv(business, row)
    unless sale.valid?
    	puts sale.errors.full_messages
    end
    sale
  end

end