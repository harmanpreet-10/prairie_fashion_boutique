
ActiveAdmin.register Product do
  permit_params :name, :description, :price,
                :stock_quantity, :category_id, :image

  config.batch_actions = false

  index do
    id_column

    column "Image" do |product|
      if product.image.attached?
        image_tag url_for(product.image.variant(:thumbnail)),
                  width: 70,
                  height: 70,
                  alt: product.name
      else
        status_tag "No Image"
      end
    end

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

  show do
    attributes_table do
      row :id
      row :name
      row :description
      row :category
      row :price
      row :stock_quantity

      row :image do |product|
        if product.image.attached?
          image_tag url_for(product.image.variant(:medium)),
                    width: 300,
                    alt: product.name
        else
          "No image uploaded"
        end
      end

      row :created_at
      row :updated_at
    end
  end

  form html: { multipart: true } do |f|
    f.inputs "Product Details" do
      f.input :name
      f.input :description
      f.input :price
      f.input :stock_quantity
      f.input :category

      f.input :image,
              as: :file,
              input_html: {
                accept: "image/jpeg,image/png,image/webp"
              },
              hint: "Upload a JPEG, PNG, or WebP image (maximum 5 MB)."
    end

    f.actions
  end
end
