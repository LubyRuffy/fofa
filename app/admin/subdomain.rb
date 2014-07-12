ActiveAdmin.register Subdomain do
  menu :label => "网站列表", :priority => 3
  
  # See permitted parameters documentation:
  # https://github.com/gregbell/active_admin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #  permitted = [:permitted, :attributes]
  #  permitted << :other if resource.something?
  #  permitted
  # end

  index do
    selectable_column
    id_column
    column :host
    column :ip
    column :title
    column :header
    column :lastupdatetime
    column :lastchecktime
    actions
  end
  
end
