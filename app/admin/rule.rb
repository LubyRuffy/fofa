ActiveAdmin.register Rule do

  belongs_to :user, :optional => true
  navigation_menu :user

  menu :label => "规则管理", :priority => 1

  permit_params :product, :rule, :producturl, :published

  index do
    selectable_column
    id_column
    column :product
    column :rule
    column :producturl
    column :user
    column :published
    actions
  end

  form do |f|
    f.inputs "Admin Details" do
      f.input :product
      f.input :producturl
      f.input :rule
      f.input :user
      f.input :published
    end
    f.actions
  end

end
