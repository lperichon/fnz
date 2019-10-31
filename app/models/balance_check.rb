class BalanceCheck < ActiveRecord::Base
  attr_accessible :account_id, :balance_cents, :checked_at

  belongs_to :account
  belongs_to :creator, :class_name => "User"

  before_validation :set_creator

  def balance
    balance_cents/100.0
  end

  def balance=(new_balance)
    self.balance_cents = new_balance*100
  end
  
  private 

  def set_creator
    self.creator = User.current_user unless creator
  end
  
end
