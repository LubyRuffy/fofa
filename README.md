fofa
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
配置和启动sphinx
配置和启动mysql
配置和启动redis
配置database.yml，编辑redis和mysql服务器地址端口
配置thinking_sphinx.yml，编辑sphinx的服务器地址端口
如果MySQL结构都建立了，sphinx和redis都启动了，那么：
$ rake fofa:restart_all
```

sphinx配置
---
1. 配置config/sphinx.conf.template，修改服务器ip和帐号信息，默认的模板是5个sphinx分布式服务器的，如果只是单个，需要做相应的修改(可以参考config/development.sphinx.conf.template）。
2. 启动sphinx索引查询服务：
    1. 主服务器：searchd -c ./distributed_sphinx.conf -i
    2. 集群服务器：
```
searchd -c ./distributed_sphinx.conf -i idx1p1
searchd -c ./distributed_sphinx.conf -i idx1p2
searchd -c ./distributed_sphinx.conf -i idx1p3
            ......
            ......
searchd -c ./distributed_sphinx.conf -i idx1p10
```
3. 在每个分布式sphinx服务器上，通过crontab执行定期索引
    1. 增量索引放到主服务器
```
#每分钟执行执行一次
*/1 * * * * indexer -c $SS_DIR/distributed_sphinx.conf idx1delta --rotate >> $SS_DIR/sphinx_crontab_delta.log
```
    2. 每个分布式服务器写入定时任务，处理不同的index分区
```
主服务器：
01 00 * * * indexer -c $SS_DIR/distributed_sphinx.conf idx1p0 --rotate >> $SS_DIR/sphinx_crontab.log
集群服务器：
    01 00 * * * indexer -c $SS_DIR/distributed_sphinx.conf idx1p1 --rotate >> $SS_DIR/sphinx_crontab.log
    01 00 * * * indexer -c $SS_DIR/distributed_sphinx.conf idx1p2 --rotate >> $SS_DIR/sphinx_crontab.log
    …………………………
    …………………………
    01 00 * * * indexer -c $SS_DIR/distributed_sphinx.conf idx1p10 --rotate >> $SS_DIR/sphinx_crontab.log
```

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
* 每5分钟执行一次增量索引：
    */1 * * * * indexer -c $SS_DIR/distributed_sphinx.conf idx1delta --rotate >> $SS_DIR/sphinx_crontab_delta.log

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
```

Sphinx安装：
---
```
sudo yum install mysql-devel
wget http://www.sphinx-search.com/downloads/sphinx-for-chinese-2.2.1-dev-r4311.tar.gz
tar zxvf sphinx-for-chinese-2.2.1-dev-r4311.tar.gz
cd sphinx-for-chinese-2.2.1-dev-r4311
./configure
make
sudo make install

wget http://sphinx-for-chinese.googlecode.com/files/xdict_1.1.tar.gz
tar zxvf xdict_1.1.tar.gz
~/sphinx-for-chinese-2.2.1-dev-r4311/src/mkdict ./xdict_1.1.txt  xdict
sudo mkdir -p /usr/local/sphinx-for-chinese/etc/
sudo cp xdict /usr/local/sphinx-for-chinese/etc/
```