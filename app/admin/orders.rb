
ActiveAdmin.register Order do
  menu priority: 4, label: "Orders"

  actions :index, :show

  config.sort_order = "created_at_desc"

  includes :order_items

  filter :id
  filter :customer_name
  filter :email
  filter :created_at

  index title: "Customer Orders" do
    selectable_column
    id_column

    column "Customer", :customer_name
    column :email

    column "Items" do |order|
      order.order_items.sum(&:quantity)
    end

    column "Total" do |order|
      number_to_currency(order.total)
    end

    column "Order Date", :created_at

    actions defaults: false do |order|
      item "View", resource_path(order)
    end
  end

  show title: proc { |order| "Order ##{order.id}" } do
    attributes_table do
      row :id
      row :customer_name
      row :email
      row :shipping_address

      row("Order Total") do |order|
        number_to_currency(order.total)
      end

      row :created_at
    end

    panel "Purchased Products" do
      table_for resource.order_items.includes(:product) do
        column("Product") { |item| item.product.name }
        column :quantity

        column("Unit Price") do |item|
          number_to_currency(item.unit_price)
        end

        column("Line Total") do |item|
          number_to_currency(item.unit_price * item.quantity)
        end
      end
    end
  end
end
