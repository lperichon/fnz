class User < ActiveRecord::Base
  include Accounts::IsAUser

  rolify

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable
  def encrypted_password
  end

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :remember_me, :time_zone, :drc_uid

  has_many :owned_businesses, :foreign_key => :owner_id, :class_name => 'Business'
  has_many :user_businesses
  has_many :businesses, :through => :user_businesses

  validates_presence_of :email
  validates_uniqueness_of :email, :case_sensitive => false, :allow_blank => false, :if => :email_changed?
  validates_format_of :email, :with  => Devise.email_regexp, :allow_blank => true, :if => :email_changed?

  class << self
    def current_user=(user)
      Thread.current[:current_user] = user
    end

    def current_user
      Thread.current[:current_user]
    end

    def find_for_cas_oauth(access_token, signed_in_resource=nil)
      data = access_token.extra

      if signed_in_resource
        signed_in_resource.update_attribute(:drc_uid, data.user)
        signed_in_resource
      elsif user = User.where(:drc_uid => data.user).first
        user
      elsif user = User.where(:email => data.user + "@metododerose.org").first
        user.update_attribute(:drc_uid, data.user)
        user
      else # Create a user with a stub password.
        User.create!(:drc_uid => data.user, :email => data.user + "@metododerose.org")
      end
    end
  end

  def username
    self.drc_uid
  end

  def admin?
    self.has_role? :admin
  end

  def self.create_or_update_from_sso(username)
    lu = self.find_by_drc_uid(username)
    pu = PadmaUser.find username
    if pu
      if lu
        lu.update_attributes(
          email: pu.email,
          name: pu.full_name
        )
      else
        lu = self.create(
          drc_uid: pu.username,
          email: pu.email,
          name: pu.full_name
        )
      end
    end
    lu
  end
  
end
