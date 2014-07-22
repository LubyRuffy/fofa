ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do
    #div class: "blank_slate_container", id: "dashboard_default_message" do
    #  span class: "blank_slate" do
    #    span I18n.t("active_admin.dashboard_welcome.welcome")
    #    small I18n.t("active_admin.dashboard_welcome.call_to_action")
    #  end
    #end

    columns do
      column do

        raw(%q{
<div id="dialog" title="查看数据" style="width:600px, height:400px, overflow:auto">
  <p></p>
</div>
<script>
  $( "#dialog" ).dialog({
      autoOpen: false,
      width: 500,
      height: "auto",
      modal: true
    });
  function show_subdomain_info_click(ip) {
      $( "#dialog" ).html("loading...");
      $( "#dialog" ).load('/search/get_hosts_by_ip.html?ip='+ip).dialog( "open" );
    }

  function remove_black_ips(ip) {
      $( "#dialog" ).html("loading...");
      $( "#dialog" ).load('/search/remove_black_ips.html?ip='+ip).dialog( "open" );
    }

</script>})
      end
    end

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

       column do
         panel "Redis任务队列" do
           ul do
             #  li "process_url任务队列：#{Resque.redis.llen("queue:process_url").to_i}"
             #  li "process_url任务队列：#{Resque.redis.llen("queue:process_url").to_i}"
             Resque.queues.each{|q|
               li "#{q}任务数：#{Resque.redis.llen("queue:#{q}").to_i}"
             }
             li "错误队列：#{Resque::Failure.count}"
           end

         end
       end

       column do
         panel "收录总览" do
           ul do
             li "mysql入库个数：#{Subdomain.count(:id)}"
             li "shpinx索引个数：#{ThinkingSphinx.count}"
           end
         end
       end
    end

    columns do


      column do
        panel "实时根域名排名" do
          ul do
            Resque.redis.redis.zrevrange("rootdomains", 0, 19, :with_scores => true).each{|kv|
              k,v = kv
              li "#{k} : #{v.to_i}"
            }
          end
        end
      end

      column do
        panel "实时IP排名" do
          ul do
            Resque.redis.redis.zrevrange("ips", 0, 19, :with_scores => true).each{|kv|
              k,v = kv
              li "#{k} : #{v.to_i}"
            }
          end
        end
      end

      column do
        panel "黑名单域名（总数：#{Resque.redis.redis.scard("black_domains")}）" do
          ul do
            Resque.redis.redis.smembers("black_domains").sort_by{|x| x}.each{|v|
              li "#{v}"
            }
          end
        end
      end

      column do
        panel "黑名单IP（总数：#{Resque.redis.redis.scard("black_ips")}）" do
          ul do
            Resque.redis.redis.smembers("black_ips").sort_by{|x| x}.each{|v|
              li link_to("#{v}", "javascript:show_subdomain_info_click('#{v}')")+" -- "+link_to("移除黑名单", "javascript:remove_black_ips('#{v}')")
            }
          end
        end
      end
    end


  end # content
end
