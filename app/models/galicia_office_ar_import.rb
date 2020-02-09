##
#
# Importa Export de Galicia OFFICE - ˝csv ampliado"
#
class GaliciaOfficeArImport < TransactionImport
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

    begin
      CSV.parse(open(path,"r:ISO-8859-1"),col_sep: ";") do |row|
        columns = row.size
        n += 1
        # SKIP: header, and first row
        next if n <= 2

        # build new record
        new_record = nil
        begin
          new_record = handle_row(business, row)
          
          if duplicated_transaction?(business,new_record)
            # this record is already registered
            errs << [row, _("transacción ya registrada")].flatten
            next
          end

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
    rescue => e
      raise e
      errs << [_("El archivo tiene un formato inválido"), e.message ]
    end

    self.update_attribute(:status, :finished)

    if errs.empty?
      self.update_attribute(:errors_csv, nil)
    else
      errs.insert(0, [Transaction.csv_header[0..columns-1],"error"].flatten )
      errCSV = CSV.generate do |csv|
        errs.each {|row| csv << row}
      end
      self.update_attribute(:errors_csv, errCSV)
    end

    Time.zone = backuped_timezone

    return errs.empty?
  end

  def handle_row(business, row)
    transaction = Transaction.new
    type = (BigDecimal.new(row[3].gsub(",","."))==0.0)? "Credit" : "Debit"
    transaction.attributes = {
      business_id: business.id,
      type: type,
      source_id: account.id,
      transaction_at: Time.zone.parse(row[0]),
      amount: BigDecimal.new(row[(type=="Debit")? 3 : 4].gsub(",",".")),
      description: "#{row[1]} #{row[10]}",
      creator_id: business.owner_id,
      state: 'created'
    }
    return transaction
  end

  def duplicated_transaction?(business,new_transaction)
    scope = account.transactions.where(
      type: new_transaction.type,
      transaction_at: new_transaction.transaction_at,
      amount: new_transaction.amount,
      description: new_transaction.description
    )
    if scope.exists?
      # found possible duplicate
      if self.transactions.where(id: scope.first.id).exists?
        # but its another row from same import, not duplicate
        false
      else
        true
      end
    else
      false
    end
  end

end
