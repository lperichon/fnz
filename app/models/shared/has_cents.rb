module Shared::HasCents
  extend ActiveSupport::Concern

  included do

    # @param varname nombre para el attributo virtual.
    # Define setter y getter.
    #
    # @example
    #   has_cents_for(:amount)
    #   # defines virtual amount and amount= proxying to amount_cents
    #
    def self.has_cents_for(varname)
      define_method("#{varname}=") do |new_value|
        self.send("#{varname}_cents=", new_value.nil? ? nil : (new_value.to_f * 100).round.to_i )
      end

      define_method(varname) do
        if send("#{varname}_cents")
          send("#{varname}_cents") / 100.0
        end
      end

    end

  end

end