
ActiveAdmin.register Product do
  permit_params :name, :description, :price,
                :stock_quantity, :category_id

  config.batch_actions = false

  index do
    id_column

    column :name
    column :category
    column :price
    column :stock_quantity

    actions defaults: false do |product|
      item "View", resource_path(product)
      text_node " | "

      item "Edit", edit_resource_path(product)
      text_node " | "

      span do
        form action: admin_product_path(product),
             method: "post",
             style: "display:inline;" do

          input type: "hidden",
                name: "_method",
                value: "delete"

          input type: "hidden",
                name: "authenticity_token",
                value: helpers.form_authenticity_token

          input type: "submit",
                value: "Delete",
                onclick: "return confirm('Delete this product permanently?');",
                style: "color:red;background:none;border:none;cursor:pointer;text-decoration:underline;"
        end
      end
    end
  end

  filter :name
  filter :category
  filter :price

  form do |f|
    f.inputs "Product Details" do
      f.input :name
      f.input :description
      f.input :price
      f.input :stock_quantity
      f.input :category
    end

    f.actions
  end
end
