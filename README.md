fofa 2.0
==

简介
---
fofa的理想是建立一个针对全球范围的最全的网站数据信息库，提供给网民（更多的是安全技术研究人员）进行查询。比如可以做CMS识别等等。

运行环境：redis、mysql、sphinx

主页：[http://fofa.so](http://fofa.so)

运行
---
```
$ git clone https://github.com/LubyRuffy/fofa.git
$ cd fofa
$ bundle install
配置和启动es
配置和启动redis
配置和启动mysql
配置database.yml，编辑es,redis和mysql服务器地址端口
如果MySQL结构都建立了，es和redis都启动了，那么：
$ rake fofa:restart_all
```

elasticsearch配置
---
搭建好es服务器，然后配置database.yml。

mysql配置
---
搭建好服务器，然后配置database.yml。通过rake db:schema:load来生成数据库结构，这时数据是空的。

redis配置
---
搭建好服务器，然后配置database.yml。


管理web服务器:
---
* rake fofa:start_unicorn
* rake fofa:stop_unicorn
* rake fofa:restart_unicorn

管理worker
---
worker就是用来执行任务的（也就是爬虫）

* rake fofa:start_workers
* rake fofa:stop_workers
* rake fofa:restart_workers

查看任务：
---
本机调试时可以通过127.0.0.1/sidekiq来查看任务队列执行情况。


附带工具：
---
* db_link_crawler.rb 从数据库中取body分析所有url提交到任务队列的工具
* analysis_fingerprint_from_urls.rb 提供满足某cms指纹的几个URL，自动分析出查询的关键字
* anaylysis_daemon.rb 放到crontab -e里面执行的脚本，用于更新统计报表
* link_crawler.rb 输入一个其实url，递归爬行host的工具，只爬首页
* addhost.rb 测试模拟处理url的工具，可以制定是否强制刷新（默认90天内更新的不会处理）

可选cron任务：
---
* 每天3点更新一下统计数据：
    03 00 * * * $SS_DIR/fofa/tools/anaylysis_daemon.rb >> $SS_DIR/analysis_cms_crontab.log

查看redis任务队列：
---
watch -n 5 redis-cli -hlocahost llen fofa:queue:process_url
如果数据库不同，记得修改-n参数
watch -n 5 redis-cli -n 15 -hlocahost llen fofa:queue:process_url


漏洞测试：
---
```
./fofacli/fofacli.rb elasticsearch_rce_CVE-2014-3120.rb 'fofaquery=(header="application/json" && body="build_hash") || body="You Know, for Search"' e
./fofacli/fofacli.rb oa80000_default_account.rb fofaquery='body="/OAapp/WebObjects/OAapp.woa"' e
通过FOFA_PROXY=1.1.1.1:8080这种形式来设置代理
```

数据导入（主要是exploits）：
---
初次结构建立：RAILS_ENV=production rake db:migrate
每次更新exploits后：
RAILS_ENV=production ./tools/import_exploits_to_db.rb


处理URL需要注意的坑：
---
* 一个主机带所有端口的形式，这种一般是用来做关键字的垃圾数据，丢弃
* 一个ip用不同的进制形式表现，也是做关键字的垃圾数据，丢弃。参考：http://www.pc-help.org/obscure.htm
* 很多GFW原因导致不可以访问的网站需要丢弃（在尝试请求多次失败后，自动加入黑名单，不用去配置）
* 泛解析域名，通常是随机生成固定的字符串，大多也是做游戏广告等关键字的垃圾站，丢弃

