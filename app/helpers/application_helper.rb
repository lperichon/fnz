module ApplicationHelper
  include TzMagic::ApplicationHelper

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
    link_to content_tag("i",class: "icon-list"){}+" "+ _("ver en CRM"), url, options
  end
end
