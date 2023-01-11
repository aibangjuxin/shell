FROM ubuntu:20.04
MAINTAINER lex@test.com
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
#RUN mkdir /tmp/nginx/ && apt-get update && apt-get install build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev libgd-dev libxml2 libxml2-dev uuid-dev make unbound -y
RUN mkdir /tmp/nginx/ && apt-get update && apt-get install build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev libgd-dev libxml2 libxml2-dev uuid-dev make unbound dnsutils curl net-tools -y
ADD nginx-1.20.1.tar.gz /tmp/nginx
RUN mkdir -p /var/log/nginx/ && chmod -R 755 /var/log/nginx/ && touch /var/log/nginx/error.log && touch /var/log/nginx/access.log && chmod 755 /var/log/nginx/error.log && chmod 755 /var/log/nginx/access.log && cd /tmp/nginx/nginx-1.20.1 && ./configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module --with-threads --with-stream --with-stream_ssl_preread_module --with-stream_ssl_module --with-debug && make && make install && cd && rm -fr /tmp/nginx && apt-get clean && apt-get autoclean && ln -sf /dev/stderr /var/log/nginx/error.log && ln -sf /dev/stdout /var/log/nginx/access.log 
# need enhance it for COPY
COPY nginx.conf /etc/nginx/nginx.conf
COPY unbound.conf /etc/unbound/unbound.conf.d/
COPY block-example.com.conf /etc/unbound/unbound.conf.d/
COPY sub.conf /etc/unbound/unbound.conf.d/
#forward request and error logs to docker log collector
#RUN ln -sf /dev/stderr /var/log/nginx/error.log && ln -sf /dev/stdout /var/log/nginx/access.log

EXPOSE 443
COPY wrapper.sh /opt/wrapper.sh
RUN chmod +x /opt/wrapper.sh
CMD /opt/wrapper.sh
