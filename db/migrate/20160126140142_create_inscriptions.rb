class CreateInscriptions < ActiveRecord::Migration
  def change
  	create_table "inscriptions", :force => true do |t|
	    t.integer  "business_id"
	    t.integer  "contact_id"
	    t.decimal  "value",        :precision => 8, :scale => 2, :default => 0.0, :null => false
	    t.decimal "balance",       :precision => 8, :scale => 2, :default => 0.0, :null => false
	    t.integer  "payment_type_id"
	    t.integer  "external_id"
	    t.string  "observations"
	    t.datetime "created_at"
	    t.datetime "updated_at"
	end

	create_table "inscriptions_transactions", :force => true do |t|
	    t.integer "inscription_id"
	    t.integer "transaction_id"
	end
  end
end
