class SantanderRioArImport < TransactionImport

  require 'roo'

  validates_attachment :upload, :presence => true, :content_type => { :content_type => ["application/xls", "application/vnd.ms-excel"] }

  belongs_to :account
  validates :account, :presence => true

  def process
    return unless status.to_sym.in? [:ready, :queued]

    self.update_attribute(:status, :working)
    n, errs = 0, []

    path = if Rails.env == "development" || Rails.env == "test"
    	upload.path
    else
    	upload.url
    end

    xls = Roo::Spreadsheet.open(path)
    sheet = xls.sheet(xls.sheets[0])
    last_row = sheet.last_row


    (8..last_row).each do |row_index|
      n += 1

      row = sheet.row(row_index)

      # build_from_csv method will map attributes &
      # build new record
      new_record = handle_row(business, row)
      # Save upon valid
      # otherwise collect error records to export
      if new_record && new_record.save
        imported_records << new_record
      else
        errs << row
      end
    end

    self.update_attribute(:status, :finished)

    if errs.empty?
      self.update_attribute(:errors_csv, nil)
    # else
    #   errs.insert(0, Transaction.csv_header)
    #   errCSV = CSV.generate do |csv|
    #     errs.each {|row| csv << row}
    #   end
    #   self.update_attribute(:errors_csv, errCSV)
    end

    return errs.empty?
  end

  def handle_row(business, row)
  	
  	t = business.transactions.find_by_external_id(row[3])
    t = business.transactions.new unless t
    t.creator_id = business.owner_id
    t.transaction_at = row[0]
    t.description = row[2]
    t.external_id = row[3]
    t.amount = row[4].abs
    t.type = row[4] > 0 ? "Credit" : "Debit"
    t.source = account

    return t
  end

end