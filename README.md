# disque-web

Web client for [Disque](https://github.com/antirez/disque)

WARNING!!!

This is quick-and-dirty Disque web client (though seems to be working fine). Use at your own risk.

WARNING!!!

This app exposes all job data and allows ACK-ing/deleting jobs, but provides no auth, so better don't expose it publicly.

Or use some auth proxy, like [oauth2_proxy](https://github.com/bitly/oauth2_proxy).


## Features

- multi-cluster (double-comma `,,` separated, see Usage section)
- server info ([INFO](https://github.com/antirez/disque#info))
- list queues ([QSCAN](https://github.com/antirez/disque#qscan-count-count-busyloop-minlen-len-maxlen-len-importrate-rate), navbar)
- queue stats ([QSTAT](https://github.com/antirez/disque#qstat-queue-name), queues/NAME page)
- queue jobs ([JSCAN](https://github.com/antirez/disque#jscan-cursor-count-count-busyloop-queue-queue-state-state1-state-state2--state-staten-reply-allid), queues/NAME page)
- job stats ([SHOW](https://github.com/antirez/disque#show-job-id), jobs/ID page)
- job ACK-ing ([ACKJOB](https://github.com/antirez/disque#ackjob-jobid1-jobid2--jobidn), jobs/ID page)
- job deleting ([DELJOB](https://github.com/antirez/disque#deljob-job-id--job-id), jobs/ID page)


## Usage

### With [docker](https://www.docker.com/)

```bash
docker run -it \
  -p 127.0.0.1:9292:9292 \
  -e DISQUE_ADDRS=127.0.0.1:7711,127.0.0.1:7712,,127.0.0.1:7713,127.0.0.1:7714 \
  mxmcherry/disque-web:latest
```

`DISQUE_ADDRS` must be accessible from docker network.

Double-comma (`,,`) separates different Disque clusters, in this example:

- cluster 0: `127.0.0.1:7711,127.0.0.1:7712`
- cluster 1: `127.0.0.1:7713,127.0.0.1:7714`

### With [docker-compose](https://docs.docker.com/compose/)

```bash
git clone https://github.com/mxmCherry/disque-web.git
cd disque-web
```

```
docker-compose up
```

It should be available on [localhost:9292](http://localhost:9292/).

Provided [docker-compose.yml](docker-compose.yml) does the following:

- runs disque server
- seeds it with dummy data
- exposes disque-web interface on `127.0.0.1:9292`

### With [ruby](https://www.ruby-lang.org/)/[rack(up)](https://github.com/rack/rack)

```bash
git clone https://github.com/mxmCherry/disque-web.git
cd disque-web
bundle install
```

```bash
DISQUE_ADDRS=127.0.0.1:7711,127.0.0.1:7712 bundle exec rackup -o 127.0.0.1 -p 9292 -E deployment
```

It should be available on [localhost:9292](http://localhost:9292/).

### Caveats

Never try to consume API, exposed by this project, programmatically. It is done solely for project UI implementation and may/will change.


## TODO

- [ ] lock buttons when data is being loaded? (like ACK/DEL on job page)
- [ ] better errors (show [bootstrap alert](https://getbootstrap.com/docs/4.0/components/alerts/) instead of js `alert(...)`?)
- [ ] proper reconnect with all data reload (probably, right in [Home](public/js/home.js) page component)
- [ ] queue job counts in navbar ([QSTAT](https://github.com/antirez/disque#qstat-queue-name) `len` attribute? Load asynchronously by frontend (`fetch cluster/ID/jobs/NAME` for each job?))
- [ ] queue page, jobs list - filter by job state? Or make tabs for [each state](https://github.com/antirez/disque#disque-state-machine)?
- [ ] queue page, jobs list - case-insensitive search? (by job JSON? Also with `job['body'] = JSON.load job['body']` on backend?)
- [ ] auto-renew (some) data each N seconds? (like job counts in navbar?)
- [ ] [rspec](http://rspec.info/) tests for [Disque::Client](lib/disque/client.rb)
