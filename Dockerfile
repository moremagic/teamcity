FROM centos
MAINTAINER moremagic <itoumagic@gmail.com>

# Install wget etc...
RUN yum install -y passwd openssh-server openssh-clients initscripts
RUN yum install -y install java-1.7.0-* git wget curl tar zip \
    && yum -y update

# ssh
RUN echo 'root:root' | chpasswd
RUN /usr/sbin/sshd-keygen

# teamcity
RUN wget http://download-cf.jetbrains.com/teamcity/TeamCity-9.1.3.tar.gz \
    && tar zxvf TeamCity-9.1.3.tar.gz

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
