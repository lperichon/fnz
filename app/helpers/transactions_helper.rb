module TransactionsHelper

  def bip_tag_id(transaction)
    best_in_place transaction,
                  :tag_id,
                  as: :select,
                  collection: tag_options_for_select,
                  url: business_transaction_path(@business, transaction)
  end

  def tag_options_for_select
    @tag_options_for_select ||= @business.tags.order(:name).map{|t| [t.id, t.name]}
  end

  def agent_options_for_select
    @agent_options_for_select ||= [["",""]]+@business.agents.enabled.map { |i| [i.id, i.name] }
  end
  
  def contact_options_for_select
    @contact_options_for_select ||= [["",""]]+@business.contacts.order(:name).map { |i| [i.id, i.name] }
  end

  def export_to_drive_formula
    csv_url = business_transactions_url(@business, params.merge({secret_key_login: @download_api_key, format: "csv", csv_options: { col_sep: "," }, ts: 1})).gsub("http:","https:")
    "=IMPORTDATA(\"#{csv_url}\")"
  end
end
