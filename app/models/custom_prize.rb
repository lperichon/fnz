class CustomPrize < ActiveRecord::Base
  attr_accessible :tag_id, :agent_id, :amount

  belongs_to :admpart
  belongs_to :agent
  belongs_to :tag

  before_validation :set_default_amount
  validates :amount, :presence => true, :numericality => {:greater_than_or_equal_to => 0}

  def self.get_for(tag,agent)
    cp = self.where(tag_id: tag.id, agent_id: agent.id).first
    if cp.nil?
      cp = self.create!(tag_id: tag.id, agent_id: agent.id)
    end
    cp
  end

  private

  def set_default_amount
    if amount.nil?
      self.amount = 0
    end
  end
  
end
