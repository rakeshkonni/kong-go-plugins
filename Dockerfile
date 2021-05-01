FROM golang:1.14-stretch AS compiler

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git-core

RUN mkdir /go-plugins

# Copy and compile go-plugins
# Get plugins from local repo
COPY kong-go-plugins /go-plugins/
RUN cd /go-plugins; go mod download; make

RUN git clone https://github.com/Kong/go-pluginserver /usr/src/go-pluginserver
RUN cd /usr/src/go-pluginserver && go build github.com/Kong/go-pluginserver

#####################
## Release image
#####################
FROM kong:2.3-ubuntu

RUN mkdir -p /usr/local/kong \
    && chown -R kong:0 /usr/local/kong \
    && chmod -R g=u /usr/local/kong

# Copy Go files
COPY --from=compiler /go-plugins/*.so /usr/local/kong/
COPY --from=compiler /usr/src/go-pluginserver/go-pluginserver /usr/local/bin/go-pluginserver

ENV KONG_PLUGINSERVER_NAMES="go"
ENV KONG_PLUGINSERVER_GO_SOCKET="/usr/local/kong/go_pluginserver.sock"
ENV KONG_PLUGINSERVER_GO_START_CMD="/usr/local/bin/go-pluginserver -kong-prefix /usr/local/kong/ -plugins-directory /usr/local/kong"
ENV KONG_PLUGINSERVER_GO_QUERY_CMD="/usr/local/bin/go-pluginserver -dump-all-plugins -plugins-directory /usr/local/kong"

USER root
## Install https://github.com/nokia/kong-oidc plugin
RUN luarocks install kong-oidc

USER kong
