class Product < ActiveRecord::Base
  belongs_to :business

  validates :name, :presence => true
  validates :price, :presence => true, :numericality => {:greater_than_or_equal_to => 0}
  validates :cost, :presence => true, :numericality => {:greater_than_or_equal_to => 0}
  validates :stock, :presence => true, :numericality => {:greater_than_or_equal_to => 0}
  validates :business, :presence => true


  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :business_id, :price, :price_currency, :cost, :cost_currency, :stock, :hidden

  scope :hidden, where(:hidden => true)

  def price_currency
    Currency.find(self[:price_currency]) || Currency.find(:usd)
  end

  def cost_currency
    Currency.find(self[:cost_currency]) || Currency.find(:usd)
  end

  def self.build_from_csv(business, row)
    product = Product.new
    price = row[3].to_f/100
    price_currency = Currency.find(row[17])
    cost = row[3].to_f/100
    cost_currency = Currency.find(row[16])

    product.attributes = {
        :business_id => business.id,
        :price => price,
        :price_currency => price_currency,
        :cost => cost,
        :cost_currency => cost_currency,
        :name => row[1],
        :stock => row[5].to_i,
        :hidden => row[7] == "true"
    }

    return product
  end

  def self.csv_header
    "id,nombre,idioma,precio_in_cents,costo_in_cents,stock,observaciones,deleted,foto_file_name,foto_content_type,foto_file_size,foto_updated_at,created_at,updated_at,precio_updated_at,school_id,costo_currency,precio_currency,code,author,owner".split(',')
  end
end
