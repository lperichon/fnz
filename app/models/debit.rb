class Debit < Transaction
  def sign account
    return -1
  end
end
