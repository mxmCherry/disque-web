var ClusterHome = (function() {
  'use strict';

  return {
    template: `
      <div>
        <div class="alert alert-danger" role="alert" v-if="err"><pre>{{ err + '' }}</pre></div>
        <div v-if="cluster">
          <h1>{{ cluster.addrs.join(', ') }}</h1>
          <pre>{{ cluster.info }}</pre>
        </div>
        <p class="lead text-muted" v-if="!cluster">No cluster</p>
      </div>
    `,
    data: function() {
      return {
        cluster: null,
        err: null
      }
    },
    methods: {
      loadCluster: function() {
        var that = this;
        that.err = null;
        api.getCluster(that.$route.params.cluster_id).then(function(cluster) {
          that.cluster = cluster;
        }).catch(function(err) {
          that.err = err;
        });
      }
    },
    watch: {
      $route: function() {
        this.loadCluster();
      }
    },
    created: function() {
      this.loadCluster();
    }
  };
})();
