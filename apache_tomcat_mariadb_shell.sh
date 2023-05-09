#!/bin/bash

apt install -y vim
apt install -y net-tools
apt install -y openssl
apt install -y apache2
apt install -y openjdk-11-jdk
apt install -y libapache2-mod-jk
apt install -y mariadb-server

cd /usr/local/src
FILE="apache-tomcat-8.5.81.tar.gz"

JDKPATH="/usr/lib/jvm/java-11-openjdk-amd64"
SEDJDKPATH="\/usr\/lib\/jvm\/java-11-openjdk-amd64"

TEMPSTR="";
TEMPSTR=`sed -n -e '/workers.java_home=/p' /etc/libapache2-mod-jk/workers.properties`

echo $TEMPSTR

sed -i -e 's/\/usr\/lib\/jvm\/default-java/\/usr\/lib\/jvm\/java-11-openjdk-amd64/g' /etc/libapache2-mod-jk/workers.properties
sed -i -e 's/\/usr\/share\/tomcat8/\/usr\/local\/tomcat/g' /etc/libapache2-mod-jk/workers.properties
sed -i -e 's/ajp13_worker/safety/g' /etc/libapache2-mod-jk/workers.properties
sed -i -e 's/DocumentRoot \/var\/www\/html/DocumentRoot \/home\/safety\/www\n        JkMount \/* safety/g' /etc/apache2/sites-available/000-default.conf


#sed는 라인 기준이다. 줄바꿈을 사용 할수 없음... 치환하는 결과물은 줄바꿈 포함 가능
#sed -i -e 's/<!-- Define an AJP 1.3 Connector on port 8009 -->\n    <!--/<!-- Define an AJP 1.3 Connector on port 8009 -->/g' /usr/local/tomcat/conf/server.xml
#sed -i -e 's/redirectPort="8443" \/>\n    -->/secretRequired="false"\n               redirectPort="8443" \/>\n/g' /usr/local/tomcat/conf/server.xml

#TEMPSTR=grep -nA0 '<!-- Define an AJP 1.3 Connector on port 8009 -->' /usr/local/tomcat/conf/server.xml
if [ ! -e $FILE ]; then

echo "tomcat 설치"
    wget https://dlcdn.apache.org/tomcat/tomcat-8/v8.5.88/bin/apache-tomcat-8.5.88-fulldocs.tar.gz
    #wget https://mirror.navercorp.com/apache/tomcat/tomcat-8/v8.5.81/bin/apache-tomcat-8.5.81.tar.gz
    tar xvf apache-tomcat-8.5.88.tar.gz
    cp -rf apache-tomcat-8.5.88 /usr/local/tomcat
        
fi

TEMPSTR=`sed -n -e '/Context docBase/p' \/usr\/local\/tomcat\/conf\/server.xml`

echo $TEMPSTR

if [ -z "$TEMPSTR" ]; then
    sed -i 's/unpackWARs="true" autoDeploy="true">/unpackWARs="true" autoDeploy="true">\n\n      <Context docBase="safety" path="\/" reloadable="ture" \/>/g' /usr/local/tomcat/conf/server.xml
fi

#---여기부터는 server.xml 을 수정하는 부분이다.
TEMPSTR=`grep -nA0 '<!-- Define an AJP 1.3 Connector on port 8009 -->' /usr/local/tomcat/conf/server.xml` #해당 라인을 포함한 줄을 찾>는다.
RESULTARRAY=($(echo $TEMPSTR | tr ":" "\n")) #라인번호만 추출
LINEN=$((${RESULTARRAY[0]} + 1)) # 라인번호에서 1을 더한다. 그러면 <!--이놈이 있는 줄임.
TEMPSTR=`sed -n "$LINEN"'p'  /usr/local/tomcat/conf/server.xml`
DLINE="$LINEN"'d'  #숫자 뒤에 d를 붙이면 삭제를 의미함.
if [[ "$TEMPSTR" =~ "<!--" ]]; then
    sed -i "$DLINE" /usr/local/tomcat/conf/server.xml #해당 라인을 지워버린다.
fi

LINEN=$((${RESULTARRAY[0]} + 5)) # 라인번호에서 1을 더한다. 그러면 <!--이놈이 있는 줄임.

TEMPSTR=`sed -n "$LINEN"'p'  /usr/local/tomcat/conf/server.xml`
DLINE="$LINEN"'d'  #숫자 뒤에 d를 붙이면 삭제를 의미함.
if [[ "$TEMPSTR" =~ "-->" ]]; then
    sed -i "$DLINE" /usr/local/tomcat/conf/server.xml #해당 라인을 지워버린다.
fi

sed -i 's/address="::1"/address="0.0.0.0"/g' /usr/local/tomcat/conf/server.xml
sed -i 's/port="8009"$/port="8009" secretRequired="false"/g' /usr/local/tomcat/conf/server.xml


mkdir /usr/local/tomcat/webapps/safety
touch /usr/local/tomcat/webapps/safety/index.html
#sed -i 's/^$/<h1>hello!<\/h1>/g' /usr/local/tomcat/webapps/safety/index.html
echo "<h1>hello!</h1>" > /usr/local/tomcat/webapps/safety/index.html
echo "tomcat safety index.html 생성 완료"


JAVACPATH=`which javac`
CommandResult=`sed -n -e '/JAVA_HOME/p' /etc/profile`
# 파일 안에 JAVA_HOME 이 있으면 사용 아래 코드 사용 안함.
echo $CommandResult
#echo "JAVA_HOME 이미 존재함, path export 로직 skip"


#FILE="/etc/init.d/tomcat"
#
#if [ ! -e $FILE ]; then
#    touch /etc/init.d/tomcat
#    chmod 755 /etc/init.d/tomcat
#    echo "#!/bin/bash" >> /etc/init.d/tomcat
#    echo "case \$1 in" >> /etc/init.d/tomcat
#    echo "start)" >> /etc/init.d/tomcat
#    echo "sh /usr/local/tomcat/bin/startup.sh" >> /etc/init.d/tomcat
#    echo ";;" >> /etc/init.d/tomcat
#    echo "stop)" >> /etc/init.d/tomcat
#    echo "sh /usr/local/tomcat/bin/shutdown.sh" >> /etc/init.d/tomcat
#    echo ";;" >> /etc/init.d/tomcat
#    echo "restart)" >> /etc/init.d/tomcat
#    echo "sh /usr/local/tomcat/bin/shutdown.sh" >> /etc/init.d/tomcat
#    echo "sleep 2" >> /etc/init.d/tomcat
#    echo "sh /usr/local/tomcat/bin/startup.sh" >> /etc/init.d/tomcat
#    echo ";;" >> /etc/init.d/tomcat
#    echo "esac" >> /etc/init.d/tomcat
#    echo "exit 0" >> /etc/init.d/tomcat
#    sleep 5
#    sudo systemctl enable tomcat
#fi
#



FILE="/etc/systemd/system/tomcat.service"


if [ ! -e $FILE ]; then
    touch /etc/systemd/system/tomcat.service
    chmod 755 /etc/systemd/system/tomcat.service
        echo "[Unit]" >> /etc/systemd/system/tomcat.service
        echo "Description=tomcat8" >> /etc/systemd/system/tomcat.service
        echo "After=syslog.target network.target" >> /etc/systemd/system/tomcat.service
        echo "" >> /etc/systemd/system/tomcat.service
        echo "[Service]" >> /etc/systemd/system/tomcat.service
        echo "Type=forking" >> /etc/systemd/system/tomcat.service
        echo "" >> /etc/systemd/system/tomcat.service
        echo "Environment="JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk-amd64/"" >> /etc/systemd/system/tomcat.service
        echo "Environment="JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk-amd64/"" >> /etc/systemd/system/tomcat.service
        echo "Environment="CATALINA_HOME=/usr/local/tomcat"" >> /etc/systemd/system/tomcat.service
        echo "Environment="CATALINA_BASE=/usr/local/tomcat"" >> /etc/systemd/system/tomcat.service
        echo "" >> /etc/systemd/system/tomcat.service
        echo "ExecStart=/usr/local/tomcat/bin/startup.sh" >> /etc/systemd/system/tomcat.service
        echo "ExecStop=/usr/local/tomcat/bin/shutdown.sh" >> /etc/systemd/system/tomcat.service
        echo "" >> /etc/systemd/system/tomcat.service
        echo "User=root" >> /etc/systemd/system/tomcat.service
        echo "Group=root" >> /etc/systemd/system/tomcat.service
        echo "UMask=0007" >> /etc/systemd/system/tomcat.service
        echo "RestartSec=10" >> /etc/systemd/system/tomcat.service
        echo "" >> /etc/systemd/system/tomcat.service
        echo "[Install]" >> /etc/systemd/system/tomcat.service
        echo "WantedBy=multi-user.target" >> /etc/systemd/system/tomcat.service
    sleep 5
    sudo systemctl enable tomcat
fi



sudo systemctl start tomcat
sudo systemctl restart tomcat

if [ "$CommandResult" == "" ] ; then

    readlink -f $JAVACPATH
    echo -e "JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64" >> /etc/profile
    echo -e "export JAVA_HOME" >> /etc/profile
    source /etc/profile
    echo -e "CATALINA_HOME=/usr/local/tomcat" >> /etc/profile
    echo -e "PATH=$PATH:$CATALINA_HOME/bin" >> /etc/profile
    echo -e "CLASSPATH=.:$JAVA_HOME/lib/tools.jar:$CATALINA_HOME/lib-jsp-api.jar:$CATALINA_HOME/lib/servlet-api.jar" >> /etc/profile
    echo -e "export CATALINA_HOME PATH" >> /etc/profile
    source /etc/profile
fi

CommandResult=`sed -n -e '/\[mysqld\]/p' /etc/mysql/my.cnf`
if [ "$CommandResult" == "" ]; then
    sed -i 's/\[client-server\]/\[client\]\n\ndefault\-character\-set = utf8mb4\n\n\[mysql\]\ndefault\-character\-set = utf8mb4\n\n\[mysqld\]\ncharacter\-set\-client\-handshake = FALSE\ncharacter\-set\-server = utf8mb4\ncollation\-server = utf8mb4_unicode_ci\n\n\[client\-server\]/g' /etc/mysql/my.cnf

fi

sudo systemctl restart apache2
sudo systemctl status apache2
sudo systemctl enable tomcat
sudo systemctl restart tomcat
sudo systemctl status tomcat
sudo systemctl restart mariadb
sudo systemctl status mariadb

mkdir /home/
mkdir /home/safety/www
chmod 755 -R /home/safety/www

echo $JAVA_HOME
echo $CATALINA_HOME
echo $CLASSPATH_HOME

netstat -ntlop



ufw enable
ufw allow 22
ufw allow 80
ufw allow 8009
ufw allow 8080
ufw allow 8005
ufw allow 3306
ufw reload

