FROM nginx:alpine

LABEL maintainer="Gluu Inc. <support@gluu.org>"

# ===============
# Alpine packages
# ===============
RUN apk update && apk add --no-cache \
    openssl \
    py-pip


# =====
# nginx
# =====
RUN mkdir -p /etc/certs
RUN openssl dhparam -out /etc/certs/dhparams.pem 2048
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# Ports for nginx
EXPOSE 80
EXPOSE 443

# ======
# Python
# ======
RUN pip install -U pip \
    && pip install "consulate==0.6.0"

# ===============
# consul-template
# ===============
ENV CONSUL_TEMPLATE_VERSION 0.19.4

RUN wget -q https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.tgz -O /tmp/consul-template.tgz \
    && tar xf /tmp/consul-template.tgz -C /usr/bin/ \
    && chmod +x /usr/bin/consul-template \
    && rm /tmp/consul-template.tgz

# ==========
# misc stuff
# ==========
LABEL vendor="Gluu Federation"

ENV GLUU_KV_HOST localhost
ENV GLUU_KV_PORT 8500

RUN mkdir -p /opt/scripts /opt/templates
COPY templates/gluu_https.conf.ctmpl /opt/templates/
COPY scripts /opt/scripts/

RUN chmod +x /opt/scripts/entrypoint.sh
CMD ["/opt/scripts/wait-for-it", "/opt/scripts/entrypoint.sh"]
