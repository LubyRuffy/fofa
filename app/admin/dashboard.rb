ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do
    #div class: "blank_slate_container", id: "dashboard_default_message" do
    #  span class: "blank_slate" do
    #    span I18n.t("active_admin.dashboard_welcome.welcome")
    #    small I18n.t("active_admin.dashboard_welcome.call_to_action")
    #  end
    #end

    # Here is an example of a simple dashboard with columns and panels.
    #
    columns do
       column do
         panel "最新用户（总数：#{User.count(:id)}）" do
           ul do
             User.order(id: :desc).limit(5).map do |user|
               li link_to(user.email, admin_user_path(user))
             end
           end
         end
       end

       column do
         panel "最新规则（总数：#{Rule.count(:id)}）" do
           ul do
             Rule.order(id: :desc).limit(5).map do |rule|
               li link_to(rule.rule, admin_user_path(rule))
             end
           end
         end
       end
    end

    columns do
      column do
        panel "Info" do
          para "Welcome to ActiveAdmin."
        end
      end

      column do
        panel "Info" do
          para "Welcome to ActiveAdmin."
        end
      end

      column do
        panel "Info" do
          para "Welcome to ActiveAdmin."
        end
      end
    end
  end # content
end
