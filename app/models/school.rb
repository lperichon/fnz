class School < Business
  has_many :sales, :foreign_key => :business_id
  has_many :memberships, :foreign_key => :business_id
end
