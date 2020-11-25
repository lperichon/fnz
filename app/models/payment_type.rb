class PaymentType < ActiveRecord::Base
  #attr_accessible :name, :description

  has_many :memberships

  belongs_to :business
  validates_presence_of :business

  validates_presence_of :name

  validate :memberships_from_my_business

  private

  def memberships_from_my_business
    unless memberships.reject{|m| m.business_id == self.business_id}.empty?
      errors.add(:memberships, I18n.t('payment_type.errors.memberships_must_belong_to_this_account'))
    end
  end
end
