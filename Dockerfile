FROM alpine:3.20

ARG XRAY_VERSION=26.6.27
ARG TARGETARCH

ENV XRAY_LOCATION_ASSET=/usr/local/share/xray

RUN apk add --no-cache ca-certificates curl unzip gettext \
    && mkdir -p /usr/local/bin /usr/local/share/xray /etc/xray /var/log/xray \
    && case "$TARGETARCH" in \
         amd64) ZIP="Xray-linux-64.zip" ;; \
         arm64) ZIP="Xray-linux-arm64-v8a.zip" ;; \
         *)     echo "Unsupported arch: $TARGETARCH" && exit 1 ;; \
       esac \
    && curl -fsSL "https://github.com/XTLS/Xray-core/releases/download/v${XRAY_VERSION}/${ZIP}" -o /tmp/xray.zip \
    && unzip /tmp/xray.zip -d /tmp/xray \
    && mv /tmp/xray/xray /usr/local/bin/xray \
    && chmod +x /usr/local/bin/xray \
    && curl -fsSL "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat" -o /usr/local/share/xray/geoip.dat \
    && curl -fsSL "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat" -o /usr/local/share/xray/geosite.dat \
    && rm -rf /tmp/xray /tmp/xray.zip

COPY config.template.json /etc/xray/config.template.json
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENV CONFIG_TEMPLATE=/etc/xray/config.template.json
ENV CONFIG_JSON=/etc/xray/config.json

CMD ["/usr/local/bin/entrypoint.sh"]
