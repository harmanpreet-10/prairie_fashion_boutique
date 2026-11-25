
ActiveAdmin.register Page do
  permit_params :title, :content

  actions :index, :show, :edit, :update

  config.batch_actions = false

  menu label: "Website Pages"

  index do
    id_column
    column :title
    column :slug
    column :updated_at

    actions
  end

  filter :title
  filter :slug
  filter :updated_at

  show do
    attributes_table do
      row :id
      row :title
      row :slug

      row :content do |page|
        simple_format(page.content)
      end

      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.semantic_errors

    f.inputs "Website Page Content" do
      f.input :title

      f.input :content,
              as: :text,
              input_html: { rows: 15 },
              hint: "Edit the content displayed on the public website."
    end

    f.actions
  end
end
