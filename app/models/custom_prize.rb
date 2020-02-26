class CustomPrize < ActiveRecord::Base
  attr_accessible :admpart_section, :agent_id, :amount

  belongs_to :admpart
  belongs_to :agent

  SECTIONS = %W(enrollment sale general)

  validates :admpart_section, inclusion: SECTIONS

  before_validation :set_default_amount
  validates :amount, :presence => true, :numericality => {:greater_than_or_equal_to => 0}

  def self.get_for(section_name,agent)
    cp = self.where(admpart_section: section_name, agent_id: agent.id).first
    if cp.nil?
      cp = self.create!(admpart_section: section_name, agent_id: agent.id)
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
