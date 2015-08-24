#!/usr/bin/env bash
table=$1
export JDBC_IMPORTER_HOME='/xxx/xxx'
bin=$JDBC_IMPORTER_HOME/bin/jdbc
lib=$JDBC_IMPORTER_HOME/plugins/jdbc/lib
echo $bin
echo $lib

select='select * from'

cmd="{
\"type\" : \"jdbc\",
        \"jdbc\" : {
        \"url\" : \"jdbc:mysql://127.0.0.1:3306/xxx\",
        \"user\" : \"root\",
        \"password\" : \"\",
        \"sql\" : \"${select} \`${table}\`\",
        \"index\" : \"sgk\",
        \"type\" : \"${table}\",
        \"elasticsearch\" : {
          \"cluster\" : \"xxx\",
          \"host\" : \"127.0.0.1\",
          \"port\" : 9300
          }
        }
}"

echo "$cmd"
echo "$cmd" | java \
             -cp "${lib}/*" \
             -Dlog4j.configurationFile=${bin}/log4j2.xml \
             org.xbib.tools.Runner \
             org.xbib.tools.JDBCImporter