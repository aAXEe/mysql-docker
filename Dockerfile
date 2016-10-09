FROM phusion/baseimage:0.9.19
MAINTAINER Simon Elsbrock <simon@iodev.org>

ENV LANG en_US.UTF-8
ENV DEBIAN_FRONTEND noninteractive

RUN \
    # see http://anonscm.debian.org/cgit/pkg-mysql/mysql-5.5.git/tree/debian/mysql-server-5.5.preinst#n112
    addgroup --system mysql ;\
    adduser --system --disabled-login --ingroup mysql --no-create-home \
      --home /nonexistent --gecos "MySQL Server" --shell /bin/false \
      mysql

RUN \
    echo "Acquire::Languages \"none\";\nAPT::Install-Recommends \"true\";\nAPT::Install-Suggests \"false\";" > /etc/apt/apt.conf ;\
    echo "Europe/Berlin" > /etc/timezone && dpkg-reconfigure tzdata ;\
    locale-gen en_US.UTF-8 en_DK.UTF-8 de_DE.UTF-8 ;\
    apt-get -q -y update ;\
    apt-get install -y mysql-server-5.5 pwgen ;\
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ;\
	rm -rf /var/lib/mysql/* && mkdir -p /var/lib/mysql

RUN sed -Ei 's/^(bind-address|log)/#&/' /etc/mysql/my.cnf
ADD mysqld_charset.cnf /etc/mysql/conf.d/mysqld_charset.cnf

RUN \
    mkdir /etc/service/mysql;\
    echo "#!/bin/sh\nmysqld" > /etc/service/mysql/run

VOLUME  ["/etc/mysql", "/var/lib/mysql"]

ADD docker-entrypoint.sh /etc/rc.local

EXPOSE 3306
