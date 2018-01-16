var ClusterHome = (function() {
  'use strict';

  return {
    template: `
      <div>
        <div v-if="cluster">
          <h1>{{ cluster.addrs.join(', ') }}</h1>
          <pre>{{ cluster.info }}</pre>
        </div>
        <p class="lead text-muted" v-if="!cluster">No cluster</p>
      </div>
    `,
    data: function() {
      return {
        cluster: null
      }
    },
    methods: {
      loadCluster: function() {
        var that = this;
        api.getCluster(that.$route.params.cluster_id).then(function(cluster) {
          that.cluster = cluster;
        }).catch(function(err) {
          alert(err + '');
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
