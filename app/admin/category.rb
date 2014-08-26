ActiveAdmin.register Category do

  belongs_to :user, :optional => true
  navigation_menu :category

  menu :label => "分组管理", :priority => 5

  permit_params :user_id, :title, :published, :rule_ids => []

  index do
    selectable_column
    id_column
    column :title
    column :user
    column :published

    column :rules do |catgory|
      table_for catgory.rules.order('id desc') do
        column do |rule|
          link_to rule.product, [ :admin, rule ]
        end
      end
    end

    actions
  end

  show do
    attributes_table do
      row :title
      row :user
      row :published
      table_for category.rules.order('id desc') do
        column "Rules" do |rule|
          link_to rule.product, [ :admin, rule ]
        end
      end
    end
  end

  form do |f|
    f.inputs "Admin Details" do
      f.input :title
      f.input :user
      f.input :published

      f.input :rules, :multiple => true, as: :check_boxes, :collection => Rule.published
      #f.input :categories, :as => :check_boxes
    end
    f.actions
  end

  batch_action "发布" do |selection|
    Category.find(selection).each do |post|
      unless post.published
        post.published = true
        post.save
      end
    end
    redirect_to :back
  end

  batch_action "取消发布" do |selection|
    Category.find(selection).each do |post|
      if post.published
        post.published = false
        post.save
      end
    end
    redirect_to :back
  end

  # This is the place to write the controller and you don't need to add any path in routes.rb
=begin
  controller do
    def update
      category = Category.find(params[:id])
      category.rules.delete_all
      rules = params[:category][:rule_ids]
      rules.shift
      rules.each do |rule_id|
        category.rules << Rule.find(rule_id.to_i)
      end
      redirect_to resource_path(category)
    end
  end
=end

end
