# USAGE

**start things up**

```
# create keys and certs
ssl/ssl_certs.sh generate

# startup containers
docker-compose up -d

# alternately, start w/out the client
docker-compose redis rabbit sensu
```

**tear things down**

```
# stop containers
docker-compose down

# remove keys and certs
ssl/ssl_certs.sh clean
```
