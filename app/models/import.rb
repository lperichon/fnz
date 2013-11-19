class Import < ActiveRecord::Base
  require 'csv'

  belongs_to :business
  has_attached_file :upload
  has_and_belongs_to_many :transactions

  validates :business, :presence => true
  validates_attachment :upload, :presence => true, :content_type => { :content_type => "text/csv" }

  attr_accessible :upload, :business_id, :status

  before_create :set_defaults

  VALID_STATUS = [:ready, :working, :finished]

  def process
    n, errs = 0, []
    CSV.parse(open(upload.path)) do |row|
      n += 1
      # SKIP: header i.e. first row OR blank row
      next if n == 1 or row.join.blank?

      # build_from_csv method will map attributes &
      # build new record
      transaction = Transaction.build_from_csv(business, row)
      # Save upon valid
      # otherwise collect error records to export
      if transaction.save
        transactions << transaction
      else
        errs << row
      end
    end

    if errs.empty?
      self.update_attribute(:errors_csv, nil)
    else
      errs.insert(0, Transaction.csv_header)
      errCSV = CSV.generate do |csv|
        errs.each {|row| csv << row}
      end
      self.update_attribute(:errors_csv, errCSV)
    end

    return errs.empty?
  end

  private

  def set_defaults
    if self.status.nil?
      self.status = :ready
    end
  end
end