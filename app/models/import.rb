class Import < ActiveRecord::Base
  require 'csv'
  belongs_to :business
  has_attached_file :upload

  validates :business, :presence => true
  validates_attachment :upload, :presence => true, :content_type => { :content_type => "text/csv" }

  attr_accessible :upload, :business_id

  def process
    n, errs = 0, []
    CSV.parse(open(upload.path)) do |row|
      n += 1
      # SKIP: header i.e. first row OR blank row
      next if n == 1 or row.join.blank?
      puts row
      # build_from_csv method will map attributes &
      # build new record
      transaction = Transaction.build_from_csv(business, row)
      # Save upon valid
      # otherwise collect error records to export
      if transaction.save
        #TODO: transactions << transaction
      else
        puts transaction.errors.full_messages
        #TODO: persist errs on DB as text
        errs << row
      end
    end

    return errs.empty?
    # Export Error file for later upload upon correction
    # TODO: move to controller /businesses/id/imports/id/errors
    #if errs.any?
    #  errFile ="errors_#{Date.today.strftime('%d%b%y')}.csv"
    #  errs.insert(0, Transaction.csv_header)
    #  errCSV = CSV.generate do |csv|
    #    errs.each {|row| csv << row}
    #  end
    #  send_data errCSV, :type => 'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment; filename=#{errFile}.csv"
    #else
    #  flash[:notice] = I18n.t('transaction.import.success')
    #  redirect_to import_url #GET
    #end
  end
end