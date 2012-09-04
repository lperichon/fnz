class School < Business
  has_many :sales, :foreign_key => :business_id
end
