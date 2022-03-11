module Membership::HasPaymentType
  extend ActiveSupport::Concern

  included do

    belongs_to :payment_type

    def payment_type_name=(pt_name)
      pt = if (pt = business.payment_types.where(name: pt_name).first)
        pt
      else
        business.payment_types.create(name: pt_name)
      end
      self.payment_type = pt
    end

    def payment_type_name
      payment_type.try(:name)
    end

  end
end
