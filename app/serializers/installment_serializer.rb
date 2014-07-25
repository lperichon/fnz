class InstallmentSerializer < ActiveModel::Serializer
  attributes :value, :due_on, :status
end