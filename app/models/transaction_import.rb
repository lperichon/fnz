class TransactionImport < Import
  has_and_belongs_to_many :trans,
                          class_name: "Transaction",
                          join_table: "imports_transactions",
                          foreign_key: "import_id"
  alias_method :imported_records, :trans

  validates_attachment :upload, :presence => true
  validates_attachment_content_type :upload, content_type: %W(text/plain text/csv)

  before_destroy :destroy_transactions

  REQUIRED_HEADERS = %W(source_account_name transaction_at amount)
  OPTIONAL_HEADERS = %W(description tag_name agent_padma_id contact_full_name contact_padma_id state external_id)
  DEFAULT_HEADERS = REQUIRED_HEADERS + OPTIONAL_HEADERS

  def handle_row(business, row)
    if has_headers?(row)
      if value_for(row, "external_id").blank?
        build_trans(row)
      else
        tran = business.trans.find_by_external_id(value_for(row,"external_id"))
        build_trans(row, tran)
      end
    else
      Transaction.build_from_csv(business, row)
    end
  end

  def has_headers?(row)
    !row.headers.compact.empty?
  end

  # @param row [CSV::Row] con headers
  def build_trans(row, tran = nil)
    tran = Transaction.new if tran.nil?
    amount = BigDecimal(value_for(row, "amount"))
    type = amount > 0 ? "Credit" : "Debit"

    state = value_for(row, "state")
    unless state.blank?
      state = state.downcase
    end

    tran.attributes = {
      :business_id => business.id,
      :type => type,
      :source_id => business.accounts.find_or_create_by(name: value_for(row, "source_account_name")).id,
      :transaction_at => value_for(row, "transaction_at"),
      :amount => amount.abs(),
      :description => value_for(row, "description"),
      :creator_id => business.owner_id,
      :state => ['created', 'pending', 'reconciled'].include?(state) ? state : 'created'
    }

    unless value_for(row, "external_id").blank?
      tran.external_id = value_for(row, "external_id")
    end

    # Agent
    unless value_for(row, "agent_padma_id").blank?
      tran.agent_id = business.agents.enabled.where(padma_id: value_for(row, "agent_padma_id")).first
    end

    # Contact
    if !value_for(row, "contact_padma_id").blank?
      tran.contact_id = business.contacts.get_by_padma_id(value_for(row, "contact_padma_id").strip).try(:id)
      if tran.contact_id.nil?
        raise "couldnt find contact"
      end
    elsif !value_for(row, "contact_full_name").blank?
      tran.contact_id = business.contacts.where(name: value_for(row, "contact_full_name").strip).first.try(:id)
      if tran.contact_id.nil?
        raise "couldnt find contact"
      end
    end

    tags_str = value_for(row, "tag_name")
    unless tags_str.blank?
      tags_str.split(';').each do |tag_name|
        tag = Tag.find_or_create_by(business_id: business.id, name: tag_name)
        tran.tags << tag
      end
    end

    tran
  end

  def value_for(row, key)
    header(row,key).nil?? nil : row[header(row,key)]
  end

  def header(row, key)
    row.headers.detect { |h| h == key }
  end

  def destroy_transactions
    trans.readonly(false).destroy_all
  end

end
