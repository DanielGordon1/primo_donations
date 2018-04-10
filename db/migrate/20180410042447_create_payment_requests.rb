class CreatePaymentRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :payment_requests do |t|
      t.integer :amount_in_cents
      t.string :currency
      t.string :description
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
