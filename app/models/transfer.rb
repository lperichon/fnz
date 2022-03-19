class Transfer < Transaction

  # explicity check for type=="Transfer" for cases when type is changed on update_attributes
  validates :target, presence: true, if: ->{ self.type == "Transfer" }
  validates :conversion_rate, presence: true, numericality: {greater_than: 0}, if: ->{ self.type == "Transfer" }

  def sign account
    sign = 0
    if self.source == account
      sign = -1
    elsif self.target == account
      sign = conversion_rate
    end
    return sign
  end
end
