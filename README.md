# disque-web

Web client for [disque](https://github.com/antirez/disque)

Single file, dirty code, no tests, but seems to be working ¯\_(ツ)_/¯


## Features

- server info (INFO)
- list queues (QSCAN, all queues are shown in navbar)
- queue stats (QSTATS, queues/NAME page)
- queue jobs (JSCAN, queues/NAME page)
- job stats (SHOW, jobs/ID page)
- job ACK-ing (ACKJOB, jobs/ID page)
- job deleting (DELJOB, jobs/ID page)


## Up and running

WARNING!!!
This app provides no auth, don't expose it publicly!
Or use some auth proxy, like [oauth2_proxy](https://github.com/bitly/oauth2_proxy) or similar.

```bash
git clone TODO
cd TODO
bundle install
```

```bash
DISQUE_ADDRS=127.0.0.1:7711,127.0.0.1:7712 bundle exec rackup
```

Then open [localhost:9292](http://localhost:9292/) in your browser.

If you need different port - specify it as `-p XXXX` for `rackup`:

```bash
DISQUE_ADDRS=127.0.0.1:7711,127.0.0.1:7712 bundle exec rackup -p 3030
```


## Quick try with docker-compose

```
docker-compose up
```

Then open [localhost:9292](http://localhost:9292/) in your browser.


## Docker

```bash
docker build -t disque-web .
```

```bash
docker run -it -p 127.0.0.1:9292:9292 disque-web:latest
```
