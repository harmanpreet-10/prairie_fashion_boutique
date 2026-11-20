
class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.string :customer_name, null: false
      t.string :email, null: false
      t.text :shipping_address, null: false
      t.decimal :total, precision: 10, scale: 2, null: false

      t.timestamps
    end
  end
end
