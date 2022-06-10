#!/bin/perl -w

use strict;
MAIN:{
        #`docker run -d --name=myapache -p 80:80  -v /var/webdata:/usr/local/apache2/htdocs myapache`;
        #`docker run -d --name=myapache -p 80:80  -v /var/webdata:/usr/local/apache2/htdocs -v /usr/local/myapache:/usr/local/apache2/conf myapache_v20`;
        #`docker run -d --name=myapache -p 80:80  -v /var/webdata:/usr/local/apache2/htdocs myapache_v23`;#original
        `docker run -d --name=myapache -p 80:80 -v /var/webdata:/usr/local/apache2/htdocs myapache_v120`;#original
        #`docker run -d --name=myapache -p 80:80  -v /var/webdata:/usr/local/apache2/htdocs myapache_v30`;#original
    #`docker run -d --name=mytomcat -p 8080:8080 -p 8009:8009 -v /var/webapps:/usr/local/tomcat/webapps tomcat:8`;
    #`docker run -d --name=mytomcat -p 8080:8080 -p 8009:8009 -v /var/webapps:/usr/local/tomcat/webapps mytomcat_v2`;
    #`docker run -d --name=mytomcat -p 8080:8080 -p 8009:8009 -p 8005:8005 -v /var/webapps:/usr/local/tomcat/webapps mytomcat_v120`;
    `docker run -d --name=mytomcat -p 8080:8080 -p 8009:8009 -p 8005:8005 -v /var/webapps:/usr/local/tomcat/webapps xpjis20/imgtech_safety_tomcat`;
    #`docker run -d --name=mytomcat -p 8080:8080 -p 8009:8009 -p 8005:8005 -v imgtech_safety_tomcat`;

    `docker run --detach --name safety_db -p 3306:3306 -v /db/safetydb/data:/var/lib/mysql --env MARIADB_USER=cnu --env MARIADB_PASSWORD=qwer1234! --env MARIADB_ROOT_PASSWORD=qwer1234!  mariadb_v10:latest`;

    my @dockerCommandresult = `docker ps -a`;
    foreach(@dockerCommandresult){
        print $_;
    }

}


# 위의 세가지 docker image는 docker image를 받고서 실행해야 함.
# 주석처리 되어 있지 않은 부분을 알아서 수정하거나 추가해서 작업하도록 함

