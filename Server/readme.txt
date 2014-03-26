
======================
How to build a package
======================
mvn package

========================
How to clean a workspace
========================
mvn clean

==================================
How to generate an Eclipse project
==================================
mvn eclipse:eclipse -Dwtpversion=2.0

============================
How to install JRE on Ubuntu
============================
apt-get -y install default-jre

========================================
How to install Apache Tomcat 6 on Ubuntu
========================================
apt-get -y install tomcat6

===================================
How to install PostgreSQL on Ubuntu
===================================
apt-get -y install postgresql-8.4

============================
How to set postgres password
============================
su postgres
psql template1
ALTER USER postgres WITH PASSWORD 'secret';
\q

=========================================
How to make Apache Tomcat work on 80 port
=========================================
iptables -t nat -I PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8080
iptables -t nat -I OUTPUT -p tcp --dport 80 -j REDIRECT --to-ports 8080

===================================
How to start (stop) Apache Tomcat 6
===================================
/etc/init.d/tomcat6 start
/etc/init.d/tomcat6 stop

=================================
How to access administrator panel
=================================
http://base_url/admin/login
admin:admin

====================================
How to change administrator password
====================================
webapps/ROOT/WEB-INF/security-context.xml

==========================================
How to change database connection settings
==========================================
webapps/ROOT/WEB-INF/jdbc.properties
