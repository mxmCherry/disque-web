var ClusterQueue = (function() {
  'use strict';

  return {
    template: `
      <div>
        <div class="alert alert-danger" role="alert" v-if="err"><pre>{{ err + '' }}</pre></div>

        <div v-if="queue">
          <h1>{{ queue.name }}</h1>
          <pre>{{ queue }}</pre>
        </div>
        <p class="lead text-muted" v-if="!queue">No queue</p>

        <div v-if="jobs">
          <h2>Jobs</h2>
          <ul class="nav flex-column" v-if="jobs">
            <li class="nav-item" v-for="job in jobs">
              <router-link class="nav-link" :to="{ name: 'cluster_job', params: { job_id: job.id } }">
                {{ job.id }}
              </router-link>
            </li>
          </ul>
        </div>
        <p class="lead text-muted" v-if="!jobs">No jobs</p>

      </div>
    `,
    data: function() {
      return {
        queue: null,
        jobs: null,
        err: null
      };
    },
    methods: {
      load: function() {
        this.loadQueue();
        this.loadJobs();
      },
      loadQueue: function() {
        var that = this;
        that.err = null;
        api.getQueue(that.$route.params.cluster_id, that.$route.params.queue_name).then(function(queue) {
          that.queue = queue;
        }).catch(function(err) {
          that.err = err;
        });
      },
      loadJobs: function() {
        var that = this;
        that.err = null;
        api.listQueueJobs(that.$route.params.cluster_id, that.$route.params.queue_name).then(function(jobs) {
          that.jobs = jobs;
        }).catch(function(err) {
          that.err = err;
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
})();
