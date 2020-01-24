class TransactionSpliter
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attr_accessor :source
  attr_accessor :targets

  def initialize(attributes={})
    @source= attributes[:source]
    @targets= attributes[:targets]
  end

  def targets_attributes=(attrs={})

  end

  def persisted?
    false
  end

  def id
    nil
  end
end
