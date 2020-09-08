module ApplicationHelper
  include TzMagic::ApplicationHelper

  def page_title(title)
    content_for(:title){ title }
    title
  end

  def css_class_id(obj)
    "its_#{obj.class.to_s}#{obj.id}"
  end

  def memberships_link_active?
    controller.controller_name == "memberships" && controller.action_name != 'index'
  end

  def inscriptions_link_active?
    controller.controller_name == "inscriptions"
  end

  def closures_link_active?
    controller.controller_name == "closures"
  end

  def reports_active?
    (controller.controller_name == "memberships" && controller.action_name == 'index') ||
    (controller.controller_name == "installments" && controller.action_name == 'index')
  end

  def link_to_list_in_crm(contacts,options={})
    url = "#{Crm::URL}/contacts?"
    contacts.each do |c|
      url << "contact_search[ids][]=#{c.padma_id}&"
    end
    %W(full_name membership_name membership_ends_on membership_value membership_payment_type last_seen_at).each do |col_name|
      url << "contact_search[chosen_columns][]=#{col_name}&"
    end
    url << "search_name=#{_("Export FNZ Membresías")}"
    link_to content_tag("i",class: "icon-list"){}+" "+ _("ver en CRM"), url, options
  end
end
