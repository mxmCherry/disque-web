require 'disque'
require 'grape'

class DisqueClient < Disque

  # https://github.com/antirez/disque#info
  def info
    call 'INFO'
  end

  # https://github.com/antirez/disque#show-job-id
  def show(job_id)
    job = call 'SHOW', job_id
    job.is_a?(Array) ? Hash[*job] : job
  end

  # https://github.com/antirez/disque#ackjob-jobid1-jobid2--jobidn
  def ackjob(*job_ids)
    call 'ACKJOB', *job_ids
  end

  # https://github.com/antirez/disque#deljob-job-id--job-id
  def deljob(*job_ids)
    call 'DELJOB', *job_ids
  end

  # https://github.com/antirez/disque#qstat-queue-name
  def qstat(queue)
    stat = call 'QSTAT', queue
    Hash[*stat]
  end

  # https://github.com/antirez/disque#qscan-count-count-busyloop-minlen-len-maxlen-len-importrate-rate
  def qscan(count: 0, busyloop: false, minlen: 0, maxlen: 0, importrate: 0)
    scan do |cursor|
      args = ['QSCAN']
      args << 'COUNT'      << count      if count && count > 0
      args << 'BUSYLOOP'                 if busyloop
      args << 'MINLEN'     << minlen     if minlen && minlen > 0
      args << 'MAXLEN'     << maxlen     if maxlen && maxlen > 0
      args << 'IMPORTRATE' << importrate if importrate && importrate > 0
      args
    end
  end

  # https://github.com/antirez/disque#jscan-cursor-count-count-busyloop-queue-queue-state-state1-state-state2--state-staten-reply-allid
  def jscan(count: 0, busyloop: false, queue: nil, state: nil, reply: 'all')
    scan do |cursor|
      args = ['JSCAN', cursor]
      args << 'COUNT'    << count if count && count > 0
      args << 'BUSYLOOP'          if busyloop
      args << 'QUEUE'    << queue if queue

      Array(state).each do |s|
        args << 'STATE' << s
      end if state

      args << 'REPLY' << reply if reply
      args
    end.lazy.map do |item|
      item.is_a?(Array) ? Hash[*item] : item
    end
  end

  private

    def scan(&make_args)
      Enumerator.new do |y|
        cursor = '0'
        loop do
          args = make_args.call(cursor)
          cursor, items = call *args
          items.each do |item|
            y << item
          end
          break if cursor == '0' || items.length == 0
        end
      end
    end

end

module DisqueWeb
  INDEX_PAGE = <<-HTML
    <!DOCTYPE html>
    <html>
      <head>
        <meta name="robots" content="none">

        <!-- TODO: copy this to dist/ or something so it can work offline -->
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-beta.3/css/bootstrap.min.css" integrity="sha384-Zug+QiDoJOrZ5t4lssLdxGhVrurbmBWopoEl+M6BdEfwnCJZtKxi1KgxUyJq13dy" crossorigin="anonymous">

      </head>
      <body class="container-fluid">

        <div id="app"></div>

        <!-- TODO: copy this to dist/ or something so it can work offline -->
        <script src="https://cdn.jsdelivr.net/npm/vue"></script>
        <script src="https://unpkg.com/vue-router/dist/vue-router.js"></script>

        <script>
          (function() {
            'use strict';

            function transformJob(job) {
              try {
                job.body = JSON.parse(job.body);
              } catch(e) {};
              return job;
            }

            function DisqueWebApi(mountpoint) {
              this.__mountpoint = ''; // must not end with slash, leave blank for root
            }

            DisqueWebApi.prototype.__fetch = function(method, url, body) {
              // url must start with slash
              return fetch(this.__mountpoint + url, {
                method: method,
                headers: new Headers({
                  Accept: 'application/json'
                }),
                body: JSON.stringify(body)
              }).then(function(response) {
                return response.json();
              });
            }

            DisqueWebApi.prototype.serverInfo = function() {
              return this.__fetch('GET', '/server/info');
            }

            DisqueWebApi.prototype.serverReconnect = function() {
              return this.__fetch('PUT', '/server/reconnect');
            }

            DisqueWebApi.prototype.listQueues = function() {
              return this.__fetch('GET', '/queues/');
            }

            DisqueWebApi.prototype.getQueue = function(name) {
              return this.__fetch('GET', '/queues/' + encodeURIComponent(name));
            }

            DisqueWebApi.prototype.getQueueJobs = function(name) {
              return this.__fetch('GET', '/queues/' + encodeURIComponent(name) + '/jobs')
            }

            DisqueWebApi.prototype.getJob = function(id) {
              return this.__fetch('GET', '/jobs/' + encodeURIComponent(id)).then(function(job) {
                return transformJob(job);
              });
            }

            DisqueWebApi.prototype.ackJob = function(id) {
              return this.__fetch('PUT', '/jobs/' + encodeURIComponent(id) + '/ack');
            }

            DisqueWebApi.prototype.delJob = function(id) {
              return this.__fetch('DELETE', '/jobs/' + encodeURIComponent(id));
            }

            var api = new DisqueWebApi();

            var Home = {
              template: `
                <div>
                  <h1>
                    Info
                    <button class="btn btn-link" v-on:click="loadInfo()" :disabled="busy()">Reload</button>
                    <button class="btn btn-link" v-on:click="reconnect()" :disabled="busy()">Reconnect</button>
                  </h1>
                  <pre>{{ info }}</pre>
                </div>
              `,
              data: function() {
                return {
                  info: null,
                  infoBusy: false,
                  reconnectBusy: false
                };
              },
              methods: {
                busy: function() {
                  return this.infoBusy || this.reconnectBusy;
                },
                load: function() {
                  this.loadInfo();
                },
                loadInfo: function() {
                  var that = this;
                  that.infoBusy = true;
                  api.serverInfo().then(function(info) {
                    that.info = info;
                    that.infoBusy = false;
                  }).catch(function(err) {
                    alert(err + '');
                    that.infoBusy = false;
                  });
                },
                reconnect: function() {
                  if( !confirm('Reconnect?') ) {
                    return;
                  }
                  var that = this;
                  that.reconnectBusy = true;
                  api.serverReconnect().then(function(info) {
                    that.infoBusy = true;
                    return api.serverInfo().then(function(info) {
                      that.infoBusy = false;
                      that.reconnectBusy = false;
                    }).catch(function(err) {
                      that.infoBusy = false;
                      throw err;
                    });
                  }).catch(function(err) {
                    alert(err + '');
                    that.reconnectBusy = false;
                  });
                }
              },
              created: function() {
                this.load();
              }
            };

            var Queue = {
              template: `
                <div>
                  <div v-if="queue">
                    <h1>
                      {{ queue.name || 'Unnamed queue (does not exist?..)'}}
                      <button class="btn btn-link" v-on:click="load()" :disabled="busy()">Reload</button>
                    </h1>
                    <pre>{{ queue }}</pre>
                    <div v-if="jobs">
                      <h2>
                        Jobs
                        <button class="btn btn-link" v-on:click="loadJobs()" :disabled="busy()">Reload</button>
                      </h2>
                      <ol>
                        <li v-for="job in jobs">
                          <router-link :to="{ name: 'job', params: { id: job } }">{{ job }}</router-link>
                        </li>
                      </ol>
                    </div>
                  </div>
                  <div v-if="!queue">
                    <p class="lead text-muted">No queue</p>
                  </div>
                </div>
              `,
              data: function() {
                return {
                  queue: null,
                  jobs: null,
                  queueBusy: false,
                  jobsBusy: false
                };
              },
              methods: {
                busy: function() {
                  return this.queueBusy || this.jobsBusy;
                },
                load: function() {
                  this.loadQueue();
                  this.loadJobs();
                },
                loadQueue: function() {
                  var that = this;
                  that.queueBusy = true;
                  api.getQueue(this.$route.params.name).then(function(queue) {
                    that.queue = queue;
                    that.queueBusy = false;
                  }).catch(function(err) {
                    alert(err + '');
                    that.queueBusy = false;
                  });
                },
                loadJobs: function() {
                  var that = this;
                  that.jobsBusy = true;
                  api.getQueueJobs(this.$route.params.name).then(function(jobs) {
                    that.jobs = jobs;
                    that.jobsBusy = false;
                  }).catch(function(err) {
                    alert(err + '');
                    that.jobsBusy = false;
                  });
                }
              },
              watch: {
                $route: function() {
                  this.load();
                }
              },
              created: function() {
                this.load();
              }
            };

            var Job = {
              template: `
                <div>
                  <div v-if="job">
                    <h1>
                      {{ job.id }}

                      <button class="btn btn-link" v-on:click="load()" :disabled="busy()">Reload</button>

                      <button class="btn btn-link" v-on:click="ackJob()" v-if="ackStatus === null && delStatus === null" :disabled="busy()">ACK</button>
                      <small class="text-secondary" v-if="ackStatus !== null">ACK: {{ ackStatus }}</small>

                      <button class="btn btn-link" v-on:click="delJob()" v-if="delStatus === null" :disabled="busy()">DEL</button>
                      <small class="text-secondary" v-if="delStatus !== null">DEL: {{ delStatus }}</small>
                    </h1>
                    <p class="lead">
                      Queue: <router-link :to="{ name: 'queue', params: { name: job.queue } }">{{ job.queue }}</router-link>
                    </p>
                    <pre>{{ job }}</pre>
                  </div>
                  <div v-if="!job">
                    <p class="lead text-muted">No job {{ $route.params.id }}</p>
                  </div>
                </div>
              `,
              data: function() {
                return {
                  job: null,
                  ackStatus: null,
                  delStatus: null,
                  jobBusy: false
                };
              },
              methods: {
                busy: function() {
                  return this.jobBusy;
                },
                load: function() {
                  this.loadJob();
                },
                loadJob: function() {
                  var that = this;
                  that.jobBusy = true;
                  api.getJob(this.$route.params.id).then(function(job) {
                    that.job = job;
                    that.jobBusy = false;
                  }).catch(function(err) {
                    alert(err + '');
                    that.jobBusy = false;
                  });
                },
                ackJob: function() {
                  if( !confirm('ACK job ' + this.$route.params.id + '?') ) {
                    return;
                  }
                  var that = this;
                  that.jobBusy = true;
                  api.ackJob(this.$route.params.id).then(function(status) {
                    that.ackStatus = status;
                    that.jobBusy = false;
                  }).catch(function(err) {
                    alert(err + '');
                    that.jobBusy = false;
                  });
                },
                delJob: function() {
                  if( !confirm('DEL job ' + this.$route.params.id + '?') ) {
                    return;
                  }
                  var that = this;
                  that.jobBusy = true;
                  api.delJob(this.$route.params.id).then(function(status) {
                    that.delStatus = status;
                    that.jobBusy = false;
                  }).catch(function(err) {
                    alert(err + '');
                    that.jobBusy = false;
                  });
                }
              },
              created: function() {
                this.load();
              }
            };

            new Vue({
              el: '#app',
              template: `
                <div>
                  <nav class="navbar navbar-expand-lg navbar-light bg-light">
                    <router-link class="navbar-brand" :to="{ name: 'home' }">DisqueWeb</router-link>
                    <div class="navbar-collapse">
                      <ul class="navbar-nav mr-auto" v-if="queues">
                        <router-link
                          tag="li"
                          class="nav-item"
                          active-class="active"
                          :to="{ name: 'queue', params: { name: queue } }"
                          v-for="queue in queues"
                        ><a class="nav-link">{{ queue }}</a></router-link>
                      </ul>
                      <!-- TODO: reload queues (probs, on reconnect?) -->
                    </div>
                    <span class="navbar-text" v-if="!queues">
                      Queues not loaded
                    </span>
                  </nav>
                  <router-view></router-view>
                </div>
              `,
              data: function() {
                return {
                  queues: null
                };
              },
              methods: {
                loadQueues: function() {
                  var that = this;
                  api.listQueues().then(function(queues) {
                    that.queues = queues;
                  }).catch(function(err) {
                    alert(err + '');
                  });
                }
              },
              router: new VueRouter({
                routes: [
                  { name: 'home',  path: '/',             component: Home  },
                  { name: 'queue', path: '/queues/:name', component: Queue },
                  { name: 'job',   path: '/jobs/:id',     component: Job   }
                ]
              }),
              created: function() {
                this.loadQueues();
              }
            });
          })();
        </script>
      </body>
    </html>
  HTML

  class API < Grape::API
    content_type :json, 'application/html; charset=utf-8'
    content_type :html, 'text/html; charset=utf-8'
    default_format :json

    class << self
      def disque_client
        disque_reconnect! unless @disque_client
        @disque_client
      end

      def disque_reconnect!
        @disque_client ||= DisqueClient.new(ENV['DISQUE_ADDRS'] || '127.0.0.1:7711')
      end
    end

    helpers do
      def disque_client
        API.disque_client
      end

      def disque_reconnect!
        API.disque_reconnect!
      end
    end

    # wget -qSO- --header 'Accept: text/html' 127.0.0.1:9292
    get do
      body INDEX_PAGE
    end

    resource :server do
      resource :info do
        get do
          disque_client.info
        end
      end
      resource :reconnect do
        put do
          disque_reconnect!
          true
        end
      end
    end


    resource :queues do
      get do
        disque_client.qscan.to_a
      end
      route_param :queue_name do
        get do
          disque_client.qstat params[:queue_name]
        end
        resource :jobs do
          get do
            disque_client.jscan(queue: params[:queue_name], reply: 'id').to_a
          end
        end
      end
    end

    resource :jobs do
      get do
        disque_client.jscan.to_a
      end
      route_param :job_id do
        get do
          disque_client.show params[:job_id]
        end
        delete do
          disque_client.deljob params[:job_id]
        end
        resource :ack do
          put do
            disque_client.ackjob params[:job_id]
          end
        end
      end
    end

  end
end
