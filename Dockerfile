FROM lsiobase/alpine:3.5
MAINTAINER Gonzalo Peci <davyjones@linuxserver.io>, sparklyballs

# environment variables
ENV PYTHON_EGG_CACHE="/config/plugins/.python-eggs"

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"

COPY boost-python-1.56.0-r0.apk /tmp/boost-python-1.56.0-r0.apk
COPY boost-system-1.56.0-r0.apk /tmp/boost-system-1.56.0-r0.apk
COPY libtorrent-rasterbar-0.16.18-r2.apk /tmp/libtorrent-rasterbar-0.16.18-r2.apk

# install runtime packages
RUN \
 apk add --allow-untrusted \
        /tmp/boost-system-1.56.0-r0.apk \
        /tmp/boost-python-1.56.0-r0.apk \
        /tmp/libtorrent-rasterbar-0.16.18-r2.apk && \
 apk add --no-cache \
	ca-certificates \
	libressl2.4-libssl \
        python2 \
	p7zip \
	unrar \
	unzip && \

# install build packages
 apk add --no-cache --virtual=build-dependencies \
	g++ \
	gcc \
	libffi-dev \
	libressl-dev \
	py2-pip \
	python2-dev && \

# install pip packages
 pip install --no-cache-dir -U \
	incremental \
	pip && \
 pip install --no-cache-dir -U \
	crypto \
	mako \
	markupsafe \
	pyopenssl \
	service_identity \
	six \
	twisted \
	zope.interface && \

# build/install deluge
 cd /tmp && \
 wget http://download.deluge-torrent.org/source/deluge-1.3.11.tar.gz && \
 tar -xvzf deluge.1.3.11.tar.gz && \
 cd /tmp/deluge-1.3.11 && \
 python2 setup.py build && \
 python2 setup.py install && \

# cleanup
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/root/.cache && \
 rm -rf \
        /tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 8112 58846 58946 58946/udp
VOLUME /config /downloads
