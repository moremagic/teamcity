FROM centos
MAINTAINER moremagic <itoumagic@gmail.com>

# Install wget etc...
RUN yum install -y passwd openssh-server openssh-clients initscripts
RUN yum install -y install java-1.6.0-* java-1.7.0-* java-1.8.0-* git wget curl tar zip \
    && yum -y update

# ssh
RUN echo 'root:root' | chpasswd
RUN /usr/sbin/sshd-keygen

# teamcity
RUN wget http://download-cf.jetbrains.com/teamcity/TeamCity-9.1.3.tar.gz \
    && tar zxvf TeamCity-9.1.3.tar.gz

# nginx
RUN rpm -ivh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
RUN yum install -y nginx
RUN openssl genrsa -out key.pem 1024
RUN openssl req  -new -newkey rsa:4096 -days 365 -nodes -subj "/C=/ST=/L=/O=/CN=AAAA" -keyout key.pem -out csr.pem
RUN openssl x509 -req -days 365 -in csr.pem -signkey key.pem -out cert.pem
RUN mv *.pem /etc/nginx/
ADD teamcity-ssl.conf /etc/nginx/conf.d/

RUN printf '#!/bin/bash \n\
export JAVA_HOME=/usr/lib/jvm/java-openjdk/ \n\
mkdir -p /TeamCity/buildAgent/logs/ \n\
/TeamCity/bin/runAll.sh start \n\
nginx \n\
/usr/sbin/sshd -D \n\
tail -f /var/null  \n\
' >> /etc/service.sh \
    && chmod +x /etc/service.sh

EXPOSE 22 80 443 8111
CMD /etc/service.sh
