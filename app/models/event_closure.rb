class EventClosure
  attr_accessor :business

  def initialize business
    self.business = business
  end

  def inscriptions_per_padma_account
    business.inscriptions.group(:padma_account).pluck_all("padma_account, SUM(value) as sum_value, SUM(balance) as sum_balance")
  end

  def other_credits_per_category
    business.transactions.credits
        .joins("LEFT JOIN inscriptions_transactions ON transactions.id = inscriptions_transactions.transaction_id").joins(:tags)
        .where("inscriptions_transactions.inscription_id IS NULL").group('tags.name').sum(:amount)
  end

  def debits_per_category
    business.transactions.debits.joins(:tags).group('tags.name').sum(:amount)
  end

  def commissions_per_padma_account
     business.inscriptions
      .where("padma_account NOT IN( ? )", business.agents.blank? ? '' : business.agents.collect(&:padma_id))
      .group(:padma_account).pluck_all("padma_account, SUM(value) as sum_value, SUM(balance) as sum_balance, SUM(value)*0.1 as commission")
  end

  def inscriptions_per_associate
    business.inscriptions.where(:padma_account => business.agents.collect(&:padma_id)).group(:padma_account).pluck_all("padma_account, SUM(value) as sum_value, SUM(balance) as sum_balance")
  end

  #has_many closure_participants
  #lecturer_minimum_cachet
  #organizer_rate
  #frozen (boolean, prevents future changes)
  #

end