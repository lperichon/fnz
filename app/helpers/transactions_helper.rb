module TransactionsHelper

  def bip_tag_id(transaction)
    best_in_place transaction,
                  :tag_id,
                  as: :select,
                  collection: tag_options_for_select,
                  url: business_transaction_path(@business, transaction)
  end

  def accounts_options_for_select
    @accounts_options_for_select ||= @business.accounts.order("name").map {|i| [i.id, i.name]}
  end

  def tag_options_for_select
    @tag_options_for_select ||= @business.tags.order(:name).map{|t| [t.id, t.name]}
  end

  def inverted_tag_options_for_select
    @inverted_tag_options_for_select ||= tag_options_for_select.map{|o| [o[1],o[0]]}
  end

  def agent_options_for_select(transaction=nil)
    @agent_options_for_select ||= [["",""]]+@business.agents.enabled.map { |i| [i.id, i.name] }
    if transaction && !transaction.agent_id.in?(@agent_options_for_select.map{|a| a[0] })
      @agent_options_for_select << if transaction.agent
        [transaction.agent.id,transaction.agent.name]
      else
        [transaction.agent_id,"??????"]
      end
    end
    @agent_options_for_select
  end
  
  def contact_options_for_select
    @contact_options_for_select ||= [["",""]]+@business.contacts.order(:name).map { |i| [i.id, i.name] }
  end

  def export_to_drive_formula
    csv_url = business_transactions_url(@business, params.merge({secret_key_login: @download_api_key, format: "csv", csv_options: { col_sep: "," }, ts: 1})).gsub("http:","https:")
    "=IMPORTDATA(\"#{csv_url}\")"
  end
end
