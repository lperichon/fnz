class MembershipImport < Import
  has_and_belongs_to_many :memberships, join_table: 'membership_imports_memberships'
  alias_method :imported_records, :memberships

  def handle_row(business, row)
    Membership.build_from_csv(business, row)
  end

end
