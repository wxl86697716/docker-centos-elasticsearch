FROM centos:7

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.10

RUN yum -y install wget gpg
RUN wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64"
RUN wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64.asc"
RUN export GNUPGHOME="$(mktemp -d)"
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu
RUN rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc
RUN chmod +x /usr/local/bin/gosu
RUN gosu nobody true

ENV key="46095ACC8548582C1A2699A9D27D666CD88E42B4"
RUN export GNUPGHOME="$(mktemp -d)"
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"
#RUN gpg --export "$key" > /etc/apt/trusted.gpg.d/elastic.gpg
RUN rm -rf "$GNUPGHOME"
#RUN apt-key list

RUN rpm --import http://packages.elasticsearch.org/GPG-KEY-elasticsearch
RUN echo "" > /etc/yum.repos.d/elasticsearch.repo
RUN echo "[elasticsearch-2.x]" >> /etc/yum.repos.d/elasticsearch.repo
RUN echo "name=Elasticsearch repository for 2.x packages" >> /etc/yum.repos.d/elasticsearch.repo
RUN echo "baseurl=http://packages.elasticsearch.org/elasticsearch/2.x/centos" >> /etc/yum.repos.d/elasticsearch.repo
RUN echo "gpgcheck=1" >> /etc/yum.repos.d/elasticsearch.repo
RUN echo "gpgkey=http://packages.elasticsearch.org/GPG-KEY-elasticsearch" >> /etc/yum.repos.d/elasticsearch.repo
RUN echo "enabled=1" >> /etc/yum.repos.d/elasticsearch.repo
RUN echo "" >> /etc/yum.repos.d/elasticsearch.repo

RUN yum -y install java-1.8.0-openjdk
RUN rm -rf /var/lib/apt/lists/*

ENV ELASTICSEARCH_VERSION 2.4.5-1
ENV ELASTICSEARCH_DEB_VERSION 2.4.5-1

RUN rm -rf /usr/lib/sysctl.d/elasticsearch.conf
RUN yum -y install "elasticsearch-$ELASTICSEARCH_VERSION"
RUN rm -rf /var/lib/apt/lists/*

ENV PATH /usr/share/elasticsearch/bin:$PATH

WORKDIR /usr/share/elasticsearch

RUN for path in \
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

COPY docker-entrypoint.sh /
RUN chmod 755 /docker-entrypoint.sh

EXPOSE 9200 9300
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["elasticsearch"]
