class Import < ActiveRecord::Base
  require 'csv'

  belongs_to :business
  has_attached_file :upload, :url => "/system/imports/:attachment/:id_partition/:style/:filename"


  validates :business, :presence => true
  validates_attachment :upload, :presence => true, :content_type => { :content_type => "text/csv" }

  attr_accessible :upload, :business_id, :status, :type

  before_create :set_defaults

  VALID_STATUS = [:ready, :working, :finished]

  def process
    return unless status.to_sym == :ready

    self.update_attribute(:status, :working)
    n, errs = 0, []
    CSV.parse(open(upload.path)) do |row|
      n += 1
      # SKIP: header i.e. first row OR blank row
      next if n == 1 or row.join.blank?

      # build_from_csv method will map attributes &
      # build new record
      new_record = handle_row(business, row)
      # Save upon valid
      # otherwise collect error records to export
      if new_record.save
        imported_records << new_record
      else
        errs << row
      end
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

    return errs.empty?
  end
  # Override this on child class
  # @param [Business]
  # @param [CSV::Row]
  # @return New record
  def handle_row(business, row)

  end

  private

  def set_defaults
    if self.status.nil?
      self.status = :ready
    end
  end
end