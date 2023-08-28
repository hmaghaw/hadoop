wget https://dlcdn.apache.org/hive/hive-3.1.3/apache-hive-3.1.3-bin.tar.gz
tar xzf apache-hive-3.1.3-bin.tar.gz
mv apache-hive-3.1.3-bin hive
rm apache-hive-3.1.3-bin.tar.gz

export HIVE_CONF_DIR=$HIVE_HOME/conf
cd $HIVE_CONF_DIR
mv hive-default.xml.template hive-default.xml

# Add HADOOP_HOME to hive-env.sh
mv hive-env.sh.template hive-env.sh

echo export HADOOP_HOME=$HADOOP_HOME >> hive-env.sh

hdfs dfs -mkdir /tmp
hdfs dfs -mkdir /user
hdfs dfs -mkdir /user/hive
hdfs dfs -mkdir /user/hive
hdfs dfs -mkdir /user/hive/warehouse

$HADOOP_HOME/bin/hadoop fs -chmod g+w /user/hive/warehouse
$HADOOP_HOME/bin/hadoop fs -chmod g+w /tmp

cd $HIVE_HOME/bin
schematool -dbType derby -initSchema
