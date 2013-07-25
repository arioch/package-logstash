#!/bin/sh
set -e

git clone https://github.com/logstash/logstash.git upstream
PKG_VERSION=$(cd upstream/; git tag | sort -V | tail -1 | sed -e 's/^v//g')
rm -rf upstream

if [ ! -f logstash-${PKG_VERSION}-flatjar.jar ]
then
  wget https://logstash.objects.dreamhost.com/release/logstash-${PKG_VERSION}-flatjar.jar
fi

if [ ! -f logstash_${PKG_VERSION}_all.deb ]
then
  [ -d build ] && rm -rf build
  mkdir -p build/etc/logstash
  mkdir -p build/etc/init.d
  mkdir -p build/usr/share/logstash
  mkdir -p build/var/log/logstash
  cp logstash-${PKG_VERSION}-flatjar.jar build/usr/share/logstash/logstash.jar
  cp logstash.conf build/etc/logstash/
  cp init build/etc/init.d/logstash
  chmod 755 build/etc/init.d/logstash

  fpm -s dir -t deb \
    --architecture all \
    -n logstash \
    -v ${PKG_VERSION} \
    --prefix / \
    --after-install post-install \
    -C build etc usr

  rm -rf logstash
  #rm -rf logstash-${PKG_VERSION}-flatjar.jar
  rm -rf build
fi

