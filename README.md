fofa
====

启动整个系统：
---
bundle install
1、启动sphinx索引查询服务
    searchd -c ./distributed_sphinx.conf
2、通过crontab执行定期索引（目前是10台服务器分布式索引，每天一次全量）
    01 00 * * * indexer -c $SS_DIR/distributed_sphinx.conf idx1p0 --rotate >> $SS_DIR/sphinx_crontab.log
    */1 * * * * indexer -c $SS_DIR/distributed_sphinx.conf idx1delta --rotate >> $SS_DIR/sphinx_crontab_delta.log
3、启动redis和mysql
4、启动rails服务器: 
    rake assets:precompile RAILS_ENV=production
    unicorn_rails -E production -D 
5、启动resque worker:
    rake fofa:start_workers
目前mysql、redis和sphinx的主服务器还有web服务器都在一台，resque的worker目前暂时不需要分布式，因为每天用户提交的量还很小。

执行resque worker：
---
rake fofa:start_workers
rake fofa:stop_workers
rake fofa:restart_workers

查看任务：
---
本机调试时可以通过127.0.0.1/resque_web来查看任务队列执行情况。
