ActiveAdmin.register Rule do
  menu :label => "规则管理", :priority => 1


  permit_params :product, :rule, :producturl

  index do
    selectable_column
    id_column
    column :product
    column :rule
    column :producturl
    actions
  end

  form do |f|
    f.inputs "Admin Details" do
      f.input :product
      f.input :producturl
      f.input :rule
    end
    f.actions
  end

end
