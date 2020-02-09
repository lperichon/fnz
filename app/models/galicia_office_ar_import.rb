require "digest"
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
          
          if duplicated_transaction?(new_record)
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
    transaction.attributes = {
      business_id: business.id,
      type: row_type(row),
      source_id: account.id,
      transaction_at: Time.zone.parse(row[0]),
      amount: row_amount(row),
      description: "#{row[1]} #{row[10]}",
      creator_id: business.owner_id,
      state: 'created'
    }
    transaction.external_id = generate_external_id(row)
    return transaction
  end

  def duplicated_transaction?(new_transaction)
    account.transactions.where(external_id: new_transaction.external_id).exists?
  end

  def row_type(row)
    (BigDecimal.new(row[3].gsub(",","."))==0.0)? "Credit" : "Debit"
  end
  def row_amount(row)
    BigDecimal.new(row[(row_type(row)=="Debit")? 3 : 4].gsub(",","."))
  end

  def generate_external_id(row)
    # row incluye el saldo post transaccion,
    # -> 2 movimientos identicos tendrás saldo posterior diferente
    # -> con esto cada movimiento, aunque sea igual  a otro tiene un ID unico
    Digest::SHA2.hexdigest row.to_s
  end

end
