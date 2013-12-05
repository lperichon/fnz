class ProductImport < Import
  has_and_belongs_to_many :products
  alias_method :imported_records, :products

  def handle_row(business, row)
    Product.build_from_csv(business, row)
  end

end