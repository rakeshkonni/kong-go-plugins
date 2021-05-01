# kong-go-plugins

Forked the example plugins from https://github.com/Kong/go-plugins

The focus of this repo is more on building a docker image of kong with custom plugins.

kong version: 2.3.x

List of plugins installed
- go plugins in the example
- https://github.com/nokia/kong-oidc (to showcase external plugin along with custom go plugins)


Build docker:
```
docker build -t kong-with-plugin .
```

Running docker:
```
docker run -ti --rm
-e "KONG_DATABASE=off"
-e "KONG_PLUGINS=bundled,hello,log,oidc"
-e "KONG_PROXY_LISTEN=0.0.0.0:8000"
-e "KONG_GO_PLUGINSERVER_EXE=/usr/local/bin/go-pluginserver"
-e "KONG_GO_PLUGINS_DIR=/usr/local/kong"
-p 8000:8000
kong-with-plugin
```

https://github.com/Kong/kong/issues/6840
