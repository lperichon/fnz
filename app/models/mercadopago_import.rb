class MercadopagoImport < TransactionImport

  belongs_to :account
  validates :account, presence: true

  def process
    return unless status.to_sym.in? [:ready, :queued]
    self.update_attribute(:status, :working)
    n, errs = 0, []
    path = if Rails.env == "development" || Rails.env == "test"
    	upload.path
    else
    	upload.url
    end
    columns = nil

    backuped_timezone = Time.zone
    Time.zone = business.time_zone

    @quote_char = "|" # MercadoPago export no separa con comillas y no escapa las comillas en descripciones de productos, etc.
    begin
      CSV.parse(open(path,"r:ISO-8859-1"), 
                col_sep: ";",
                quote_char: @quote_char,
                headers: true,
               ) do |row|
        columns = row.size

        # build new record
        new_record = nil
        begin
          new_record = handle_row(business, row)
          
          # Save upon valid
          # otherwise collect error records to export
          if new_record && new_record.save
            imported_records << new_record
          else
            errs << [row, record_errors(new_record) ].flatten
          end
        rescue => e
          errs << [row, e.to_s ].flatten
        end
      end
    rescue CSV::MalformedCSVError => e
      # MercadoPago export no separa con comillas y no escapa las comillas en descripciones de productos, etc.
      if e.message.match(/Illegal quoting in line/)
        if @quote_char == "|"

          # remove imported records
          imported_records.destroy_all
          # change quote_char
          @quote_char = "~"
          # and retry
          retry
        else
          errs << [_("El archivo tiene un formato inválido"), e.message ]
          raise e
        end
      else
        errs << [_("El archivo tiene un formato inválido"), e.message ]
        raise e
      end
    rescue => e
      raise e
      errs << [_("El archivo tiene un formato inválido"), e.message ]
    end


    self.update_attribute(:status, :finished)

    if errs.empty?
      self.update_attribute(:errors_csv, nil)
     else
       errs.insert(0, Transaction.csv_header)
       errCSV = CSV.generate do |csv|
         errs.each {|row| csv << row}
       end
       self.update_attribute(:errors_csv, errCSV)
    end

    Time.zone = backuped_timezone

    return errs.empty?
  end

  # MP headers have spanish text AND key
  # returns header by key, ignoring spanish text
  def header(row, key)
    row.headers.select{|h| h.match(key) }.first
  end

  def value_for(row,key)
    header(row,key).nil?? nil : row[header(row,key)]
  end

  def description_for(row)
    desc = ""
    desc << (value_for(row,"reason") || "")
    desc << " "
    desc << (value_for(row,"counterpart_name") || "")
    desc << " - "
    desc << (value_for(row,"status") || "")
  end

  def handle_row(business, row)
    t = business.transactions.find_by_external_id(value_for(row,"operation_id").to_s)
    t = business.transactions.new unless t
    t.creator_id = business.owner_id
    t.transaction_at = value_for(row,"date_created")
    t.description = description_for(row)
    t.external_id = value_for(row,"operation_id")
    t.amount = BigDecimal.new(value_for(row,"transaction_amount")).abs
    t.type = BigDecimal.new(value_for(row,"transaction_amount")) > 0 ? "Credit" : "Debit"
    t.state = case value_for(row,"status")
    when "approved"
      "created"
    when "rejected"
      "pending"
    when "in_process"
      "pending"
    else 
      "pending"
    end
    t.source = account

    return t
  end
end
