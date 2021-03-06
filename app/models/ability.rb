class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.has_role? :admin
      can :manage, :all
    end

    can :manage, Admpart, :business => {:transactions_enabled => true}
    can :manage, Transaction, :business => {:transactions_enabled => true}
    can :manage, Account, :business => {:transactions_enabled => true}
    can :manage, BalanceCheck

    can :manage, Tag, :business => {:transactions_enabled => true}
    cannot :destroy, Tag, system_name: Tag::VALID_SYSTEM_NAMES
    
    can :manage, Import, :business => {:transactions_enabled => true}
    can :manage, User, :business => {:share_enabled => true}
  end
end
