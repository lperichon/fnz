module MonthExchangeRate::InverseConversion

  def inverse_conversion_rate
    if conversion_rate
      1.0 / conversion_rate
    end
  end

  def inverse_conversion_rate=(new_value)
    self.conversion_rate = 1.0 / new_value.to_f
  end

end
