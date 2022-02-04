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
        t = Transaction.create!(
          recurrent_transaction: self,

          type: transaction_type,
          description: description,
          amount: amount,

          business_id: business_id,
          source_id: source_id,
          target_id: target_id,

          contact_id: contact_id,
          agent_id: agent_id,
          tag_id: admpart_tag_id,
          admpart_tag_id: admpart_tag_id,

          state: "pending",

          creator: business.users.first,

          transaction_at: ref_date.beginning_of_month.to_time,
          report_at: ref_date.beginning_of_month.to_time
        )
    end
  end

  def transaction_type
    if type.present?
      type.gsub("Recurrent","")
    else
      "RecurrentDebit"
    end
  end

  def self.daily_create_transactions
    RecurrentTransaction.all.each do |rt|
      rt.create_for_current_month
    end
  end

end
