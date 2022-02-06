module Shared::HasCents
  extend ActiveSupport::Concern

  included do

    def self.has_cents_for(varname)
      define_method("#{varname}=") do |new_value|
        self.send("#{varname}_cents=", new_value.nil? ? nil : (new_value * 100).round.to_i )
      end

      define_method(varname) do
        if send("#{varname}_cents")
          send("#{varname}_cents") / 100.0
        end
      end

    end

  end

end