class TransactionSpliter
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attr_accessor :source
  attr_accessor :targets

  def initialize(attributes={})
    @source= attributes[:source]
    if attributes[:targets]
      @targets= attributes[:targets]
    elsif attributes[:targets_attributes]
      self.targets_attributes=attributes[:targets_attributes]
    end
  end

  def targets_attributes=(attrs={})
    @targets = []
    attrs.values.each do |v|
      @targets << build_target(v)
    end
  end

  def build_target(atrs={})
    target_attributes = source.attributes.merge(atrs).reject { |k, v| k.to_s.in?(%W(id)) }
    Transaction.new target_attributes
  end

  # destroys sources and saves targets
  # blanks external_id
  def do_split!
    if @source.present? || !@targets.empty?
      Transaction.transaction do # transaction method call is a DB Transaction
        @source.destroy!
        @targets.each {|t| t.external_id = nil }
        @targets.each {|t| t.save! }
      end
    end
  end

  def persisted?
    false
  end

  def id
    nil
  end
end
