class AddColumnsToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :name, :string
    add_column :users, :phone_number, :string
    add_column :users, :iban, :string
    add_column :users, :bank_account_label, :string
    add_column :users, :api_id, :integer
  end
end
