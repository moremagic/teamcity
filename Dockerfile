FROM centos:centos6
MAINTAINER moremagic <itoumagic@gmail.com>

# Install wget etc...
RUN yum install -y wget tar java-1.7.0-* passwd openssh-server initscripts \
    && yum -y update

# ssh
RUN ssh-keygen -h -t rsa -f /etc/ssh/ssh_host_rsa_key \
    && ssh-keygen -h -t dsa -f /etc/ssh/ssh_host_dsa_key \
    && echo "root" | passwd --stdin root

# teamcity
RUN wget http://download-cf.jetbrains.com/teamcity/TeamCity-9.1.1.tar.gz \
    && tar zxvf TeamCity-9.1.1.tar.gz

RUN printf '#!/bin/bash \n\
export JAVA_HOME=/usr/lib/jvm/java-openjdk/ \n\
mkdir -p /TeamCity/buildAgent/logs/ \n\
/TeamCity/bin/runAll.sh start \n\
/usr/sbin/sshd -D \n\
tail -f /var/null  \n\
' >> /etc/service.sh \
    && chmod +x /etc/service.sh

EXPOSE 22 8111
CMD /etc/service.sh
