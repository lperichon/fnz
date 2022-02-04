FactoryBot.define do
  factory :recurrent_transaction do
    type {"Debit"}
    description {'Test Transaction'}
    amount {3.5}
    business
    source
  end
end
