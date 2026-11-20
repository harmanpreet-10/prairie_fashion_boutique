
ActiveAdmin.register Product do
  permit_params :name, :description, :price,
                :stock_quantity, :category_id

  index do
    selectable_column
    id_column
    column :name
    column :category
    column :price
    column :stock_quantity
    actions
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
