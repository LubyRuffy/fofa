ActiveAdmin.register User do

  sidebar "Rule Details", only: [:show, :edit] do
    ul do
      li link_to("Rule", admin_user_rules_path(user))
    end
  end

  menu :label => "用户管理", :priority => 4
  permit_params :email, :password, :password_confirmation, :isadmin

  index do
    selectable_column
    id_column
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    column :isadmin
    actions
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at
  filter :isadmin, :as => :select,  :collection => [['TRUE', true],['FALSE', false]]
  #filter :isadmin, as: :radio, collection: [ ['所有', nil],['是', true],['否', false] ], label: '是否管理员？'

  form do |f|
    f.inputs "Admin Details" do
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :isadmin
      #f.input :avatar_file_name, :as => :file, :hint => f.template.image_tag(f.object.avatar_file_name)
    end
    f.actions
  end

end
