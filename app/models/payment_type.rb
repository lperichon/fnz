class PaymentType < ActiveRecord::Base
  attr_accessible :name, :description

  belongs_to :business
  validates_presence_of :business

  validates_presence_of :name
end
