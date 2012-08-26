class Transfer < Transaction
  belongs_to :target, :class_name => "Account"

  validates :target, :presence => true
  validates :conversion_rate, :presence => true, :numericality => {:greater_than => 0}

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
