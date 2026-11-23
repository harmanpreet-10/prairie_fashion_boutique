class AddTaxDetailsToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :province, :string
    add_column :orders, :subtotal, :decimal, precision: 10, scale: 2
    add_column :orders, :gst_amount, :decimal, precision: 10, scale: 2, default: 0
    add_column :orders, :pst_amount, :decimal, precision: 10, scale: 2, default: 0
    add_column :orders, :hst_amount, :decimal, precision: 10, scale: 2, default: 0
  end
end