class UserBusiness < ActiveRecord::Base
  self.table_name = "businesses_users"
  belongs_to :user
  belongs_to :business

  attr_accessible :user_id, :business_id, :show_on_menu
end