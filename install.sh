#!/bin/bash

# Installing Java
sudo apt update -y && sudo apt install -y openjdk-8-jdk openjdk-8-jre

#Create Key
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 640 ~/.ssh/authorized_keys

#Install Hadoop
wget https://dlcdn.apache.org/hadoop/common/hadoop-3.3.4/hadoop-3.3.4.tar.gz
tar xzf hadoop-3.3.4.tar.gz
mv hadoop-3.3.4 hadoop
rm hadoop-3.3.4.tar.gz

# Configure hadoop
# Update ~/.bashrc
printf 'export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
export HADOOP_HOME=/home/ubuntu/hadoop
export HADOOP_INSTALL=$HADOOP_HOME
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export HADOOP_YARN_HOME=$HADOOP_HOME
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin
export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"
export HADOOP_PREFIX=$HADOOP_HOME
export HIVE_HOME=/home/ubuntu/hive
export PATH=$HIVE_HOME/bin:$PATH
export HIVE_CONF_DIR=$HIVE_HOME/conf'>> ~/.bashrc

source ~/.bashrc

#$HADOOP_HOME/etc/hadoop/hadoop-env.sh
echo export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java)))) >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh

# Update core-site.xml
perl -0777 -i -pe 's|<configuration>\n</configuration>|<configuration>
<property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9000</value>
    </property>
</configuration>
|g' $HADOOP_HOME/etc/hadoop/core-site.xml

# Update hdfs-site.xml.xml
echo "<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>

    <property>
        <name>dfs.name.dir</name>
        <value>file://$HADOOP_HOME/hadoopdata/hdfs/namenode</value>
    </property>

    <property>
        <name>dfs.data.dir</name>
        <value>file://$HADOOP_HOME/hadoopdata/hdfs/datanode</value>
    </property>
</configuration>" > $HADOOP_HOME/etc/hadoop/hdfs-site.xml

# Update mapred-site.xml
perl -0777 -i -pe 's|<configuration>|<configuration>
<property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
|g'  $HADOOP_HOME/etc/hadoop/mapred-site.xml

perl -0777 -i -pe 's|<configuration>|<configuration>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
|g'  $HADOOP_HOME/etc/hadoop/yarn-site.xml

#Format hdfs
hdfs namenode -format

#Start Hadoop Server
start-all.sh

# Install Hive
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