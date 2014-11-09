ActiveAdmin.register Rule do

  belongs_to :user, :optional => true
  navigation_menu :user

  menu :label => "规则管理", :priority => 1

  permit_params :product, :rule, :producturl, :published, :user_id, :category_ids=> [:id]

  index do
    selectable_column
    id_column
    column :product
    column :rule
    column :producturl
    column :user
    column :published

    column :categories do |post|
      table_for post.categories.order('title ASC') do
        column do |category|
          link_to category.title, [ :admin, category ]
        end
      end
    end

    actions
  end

  show do
    attributes_table do
      row :title
      row :product
      row :rule
      row :producturl
      row :user
      row :published
      table_for rule.categories.order('title ASC') do
        column "Categories" do |category|
          link_to category.title, [ :admin, category ]
        end
      end
    end
  end

  form do |f|
    f.inputs "Admin Details" do
      f.input :product
      f.input :producturl
      f.input :rule
      f.input :user
      f.input :published

      f.input :categories, :multiple => true, as: :check_boxes, :collection => Category.published
      #f.input :categories, :as => :check_boxes
    end
    f.actions
  end

  batch_action "发布" do |selection|
    Rule.find(selection).each do |post|
      unless post.published
        post.published = true
        post.save

        post.user.add_points(100, category: 'rule')
      end
    end
    redirect_to :back
  end

  batch_action "取消发布" do |selection|
    Rule.find(selection).each do |post|
      if post.published
        post.published = false
        post.save
        post.user.subtract_points(100, category: 'rule')
      end
    end
    redirect_to :back
  end

  # This is the place to write the controller and you don't need to add any path in routes.rb
  controller do
    def update
      rule = Rule.find(params[:id])
      rule.categories.delete_all
      categories = params[:rule][:category_ids]
      categories.shift
      categories.each do |category_id|
        rule.categories << Category.find(category_id.to_i)
      end
      redirect_to resource_path(rule)
    end
  end

end
