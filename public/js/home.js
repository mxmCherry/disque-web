var Home = (function() {
  'use strict';

  return {
    template: `
      <div>
        <div class="alert alert-danger" role="alert" v-if="err"><pre>{{ err + '' }}</pre></div>
        <h1>Clusters</h1>
        <ul class="nav flex-column" v-if="clusters">
          <li class="nav-item" v-for="cluster in clusters">
            <router-link class="nav-link" :to="{ name: 'cluster_info', params: { cluster_id: cluster.id } }">
              {{ cluster.addrs.join(', ') }}
            </router-link>
          </li>
        </ul>
        <p class="lead text-muted" v-if="!clusters">No clusters</p>
      </div>
    `,
    data: function() {
      return {
        clusters: null,
        err: null
      };
    },
    methods: {
      loadClusters: function() {
        var that = this;
        that.err = null;
        api.listClusters().then(function(clusters) {
          that.clusters = clusters;
        }).catch(function(err) {
          that.err = err;
        });
      }
    },
    created: function() {
      this.loadClusters();
    }
  };
})();
