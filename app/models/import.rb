class Import < ActiveRecord::Base
  require 'csv'

  belongs_to :business
  has_attached_file :upload, :url => "/system/imports/:attachment/:id_partition/:style/:filename"

  validates :business, :presence => true
  validates_attachment :upload, :presence => true

  #attr_accessible :upload, :business_id, :status, :type, :account_id, :description, :archived

  before_create :set_defaults

  VALID_STATUS = [:ready, :working, :finished]

  def process
    return unless status.to_sym.in? [:ready, :queued]

    self.update_attribute(:status, :working)
    n, errs = 0, []

    backuped_timezone = Time.zone
    Time.zone = business.time_zone

    headers = nil
    columns = nil
    begin
      CSV.parse(read_uploaded_file, headers: true) do |row|
        headers = row.headers
        columns = row.size
        n += 1

        # build_from_csv method will map attributes &
        # build new record
        new_record = nil
        begin
          new_record = handle_row(business, row)
          # Save upon valid
          # otherwise collect error records to export
          if new_record && new_record.save
            imported_records << new_record
          else
            errs << [row.fields, record_errors(new_record) ].flatten
          end
        rescue => e
          errs << [row.fields, e.to_s ].flatten
        end
      end
    rescue => e
      errs << [_("El archivo tiene un formato inválido"), e.message ]
    end

    self.update_attribute(:status, :finished)

    if errs.empty?
      self.update_attribute(:errors_csv, nil)
    else
      header = if headers.compact.empty?
        Transaction.csv_header[0..columns-1]
      else
        headers
      end
      errs.insert(0, [header,"error"].flatten )
      errCSV = CSV.generate do |csv|
        errs.each {|row| csv << row}
      end
      self.update_attribute(:errors_csv, errCSV)
    end

    Time.zone = backuped_timezone

    return errs.empty?
  end

  def read_uploaded_file
    Paperclip.io_adapters.for(upload).read
  end

  def record_errors(record)
    if record
      record.errors.messages.to_a.map{|m| m.join(" ") }.join(" - ")
    else
      "couldnt process"
    end
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
