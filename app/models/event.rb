class Event < Business
  
  has_many :inscriptions, :foreign_key => :business_id

  after_create :initialize_event

  def initialize_event
   	accounts.create(:name => "Default")	
  end
end
