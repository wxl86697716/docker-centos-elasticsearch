FROM centos:7.3.1611

MAINTAINER xiaolong<xiaolong19880403@163.com>

ENV GOSU_VERSION 1.10
ENV key="46095ACC8548582C1A2699A9D27D666CD88E42B4"
ENV ELASTICSEARCH_VERSION 2.4.5-1
ENV ELASTICSEARCH_DEB_VERSION 2.4.5-1
ENV PATH /usr/share/elasticsearch/bin:$PATH

RUN yum -y install wget gpg java-1.8.0-openjdk && yum clean all && \
 wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64" && \
 wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64.asc" && \
 export GNUPGHOME="$(mktemp -d)" && \
 gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
 gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu && \
 rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc && \
 chmod +x /usr/local/bin/gosu && \
 gosu nobody true && \
 export GNUPGHOME="$(mktemp -d)" && \
 gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" && \
#gpg --export "$key" > /etc/apt/trusted.gpg.d/elastic.gpg && \
 rm -rf "$GNUPGHOME" && \
#apt-key list && \
 rpm --import http://packages.elasticsearch.org/GPG-KEY-elasticsearch && \
 echo "" > /etc/yum.repos.d/elasticsearch.repo && \
 echo "[elasticsearch-2.x]" >> /etc/yum.repos.d/elasticsearch.repo && \
 echo "name=Elasticsearch repository for 2.x packages" >> /etc/yum.repos.d/elasticsearch.repo && \
 echo "baseurl=http://packages.elasticsearch.org/elasticsearch/2.x/centos" >> /etc/yum.repos.d/elasticsearch.repo && \
 echo "gpgcheck=1" >> /etc/yum.repos.d/elasticsearch.repo && \
 echo "gpgkey=http://packages.elasticsearch.org/GPG-KEY-elasticsearch" >> /etc/yum.repos.d/elasticsearch.repo && \
 echo "enabled=1" >> /etc/yum.repos.d/elasticsearch.repo && \
 echo "" >> /etc/yum.repos.d/elasticsearch.repo && \
 rm -rf /var/lib/apt/lists/* && \
 rm -rf /usr/lib/sysctl.d/elasticsearch.conf && \
 yum -y install "elasticsearch-$ELASTICSEARCH_VERSION" && yum clean all && \
#groupadd elasticsearch && \
#useradd -d /home/elasticsearch elasticsearch -g elasticsearch -G root && \
 rm -rf /var/lib/apt/lists/*

WORKDIR /usr/share/elasticsearch

COPY docker-entrypoint.sh /
RUN chmod 755 /docker-entrypoint.sh && \
 for path in \
  ./data \
  ./logs \
  ./config \
  ./config/scripts \
 ; do \
  mkdir -p "$path"; \
  chown -R elasticsearch:elasticsearch "$path"; \
 done

COPY config ./config

VOLUME /usr/share/elasticsearch/data

EXPOSE 9200 9300
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["elasticsearch"]
