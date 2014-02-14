class School < Business
  has_many :sales, :foreign_key => :business_id
  has_many :memberships, :foreign_key => :business_id
  has_many :enrollments, :through => :memberships

  after_create :initialize_padma_school

  def initialize_padma_school
  	
  	unless padma_id.blank?
  		padma_account = padma
  		
  		padma_account.users.each do |padma_user|
  			#initialize users
  			user = User.find_or_create_by_drc_uid(drc_uid:padma_user.id, email: padma_user.email, password: Devise.friendly_token[0,20])
  			users << user
  			#initialize agents
  			agents.create(name: padma_user.id)
  		end
  		agents.create(name: owner.drc_uid)
  	end

  	accounts.create(:name => "Default")	
  end
end
