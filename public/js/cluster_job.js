var ClusterJob = (function() {
  'use strict';

  return {
    template: `
      <div>
        <div class="alert alert-danger" role="alert" v-if="err"><pre>{{ err + '' }}</pre></div>
        <div v-if="job">
          <h1>
            {{ job.id }}

            <button class="btn btn-link" v-on:click="ackJob()" v-if="ackStatus === null && delStatus === null">
              ACK
            </button>
            <span class="text-secondary" v-if="ackStatus !== null">ACK: {{ ackStatus }}</span>

            <button class="btn btn-link" v-on:click="delJob()" v-if="ackStatus === null && delStatus === null">
              DEL
            </button>
            <span class="text-secondary" v-if="delStatus !== null">DEL: {{ delStatus }}</span>

          </h1>

          <p class="lead">
            Queue: <router-link :to="{ name: 'cluster_queue', params: { queue_name: job.queue } }">{{ job.queue }}</router-link>
          </p>

          <pre>{{ job }}</pre>
        </div>
        <p class="lead text-muted" v-if="!job">No job</p>
      </div>
    `,
    data: function() {
      return {
        job: null,
        ackStatus: null,
        delStatus: null,
        err: null
      };
    },
    methods: {
      loadJob: function() {
        var that = this;
        that.err = null;
        api.getJob(that.$route.params.cluster_id, that.$route.params.job_id).then(function(job) {
          that.job = job;
        }).catch(function(err) {
          that.err = err;
        });
      },
      delJob: function() {
        var that = this;
        if( !confirm('DEL ' + that.$route.params.job_id + '?') ) {
          return;
        }
        that.err = null;
        api.delJob(that.$route.params.cluster_id, that.$route.params.job_id).then(function(status) {
          that.delStatus = status;
        }).catch(function(err) {
          that.err = err;
        });
      },
      ackJob: function() {
        var that = this;
        if( !confirm('ACK ' + that.$route.params.job_id + '?') ) {
          return;
        }
        that.err = null;
        api.ackJob(that.$route.params.cluster_id, that.$route.params.job_id).then(function(status) {
          that.ackStatus = status;
        }).catch(function(err) {
          that.err = err;
        });
      }
    },
    watch: {
      $route: function() {
        this.loadJob();
      }
    },
    created: function() {
      this.loadJob();
    }
  };
})();
