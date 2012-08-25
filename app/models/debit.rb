class Debit < Transaction
  def sign
    return -1
  end
end
