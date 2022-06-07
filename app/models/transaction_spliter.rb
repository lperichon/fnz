class TransactionSpliter
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attr_accessor :source
  attr_accessor :targets

  attr_accessor :auto_generate_n_targets

  def initialize(attributes={})
    @source= attributes[:source]
    if attributes[:targets]
      @targets= attributes[:targets]
    elsif attributes[:targets_attributes]
      self.targets_attributes=attributes[:targets_attributes]
    end
    @auto_generate_n_targets= attributes[:auto_generate_n_targets]
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
        @targets.each {|t| t.external_id = nil; t.save! }
      end
    end
  end

  def do_n_split!
    n = @auto_generate_n_targets.to_i
    if @source.present? && n > 0
      if @source.report_at.nil? || @source.is_a?(Transfer)
        raise ArgumentError, "source transaction must have a report_at date and cant be Transfer"
      end
      Transaction.transaction do # transaction method call is a DB Transaction
        @targets = []
        n.times do |i|
          t = @source.dup

          t.tag_id = @source.tag_id
          t.agent_id = @source.agent_id
          t.contact_id = @source.contact_id

          t.description += " (#{i+1}/#{n})"
          t.amount_cents = (@source.amount_cents / n).to_i
          t.report_at = @source.report_at + i.months

          @targets << t
        end
        if @targets.sum { |t| t.amount_cents } != @source.amount_cents
          last_target = @targets.last
          @targets.last.amount_cents = @source.amount_cents - @targets.select { |s| s != last_target }.sum { |t| t.amount_cents }
        end
        @targets.each { |t| t.external_id = nil; t.save! }
        @source.destroy!
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
