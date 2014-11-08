class School < Business
  has_many :sales, :foreign_key => :business_id
  has_many :memberships, :foreign_key => :business_id
  has_many :enrollments, :through => :memberships

  after_create :initialize_padma_school

  def initialize_padma_school
    PadmaAccountsSynchronizer.new(self).sync
  	accounts.create(:name => "Default")	
  end
end
