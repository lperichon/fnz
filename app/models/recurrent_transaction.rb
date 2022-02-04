# Recurrencia MENSUAL
class RecurrentTransaction < ActiveRecord::Base

  belongs_to :business

  belongs_to :source, class_name: "Account"
  belongs_to :target, class_name: "Account"

  belongs_to :contact
  belongs_to :agent

  belongs_to :admpart_tag, class_name: "Tag"

  validates :amount, presence: true, numericality: {greater_than_or_equal_to: 0}

  after_save :create_for_current_month

  def create_for_current_month
    create_monthly_transaction_for(Time.zone.today)
  end

  def create_monthly_transaction_for(ref_date)
    unless Transaction.where(recurrent_transaction_id: self)
      .where("transaction_at >= ? AND transaction_at <= ?", ref_date.beginning_of_month, ref_date.end_of_month)
      .exists?
        Transaction.create!(
          recurrent_transaction: self,

          type: type,
          description: description,
          amount: amount,

          business: business,
          source: source,
          target: target,

          contact: contact,
          agent: agent,
          admpart_tag: admpart_tag,

          state: "pending",

          creator: business.users.first,

          transaction_at: ref_date.beginning_of_month.to_time,
          report_at: ref_date.beginning_of_month.to_time
        )
    end
  end

  def self.daily_create_transactions
    RecurrentTransaction.all.each do |rt|
      rt.create_for_current_month
    end
  end

end
