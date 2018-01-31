var Cluster = (function() {
  'use strict';

  return {
    template: `
      <div>
        <nav class="navbar navbar-expand-lg navbar-light bg-light">
          <router-link class="navbar-brand" :to="{ name: 'home' }">Clusters</router-link>
          <div class="navbar-collapse">
            <ul class="navbar-nav">
              <router-link
                tag="li"
                class="nav-item"
                active-class="active"
                :to="{ name: 'cluster_info', params: { cluster_id: $route.params.cluster_id } }"
              >
                <a class="nav-link">Cluster</a>
              </router-link>
            </ul>
            <ul class="navbar-nav mr-auto" v-if="queues">
              <router-link
                tag="li"
                class="nav-item"
                active-class="active"
                :to="{ name: 'cluster_queue', params: { queue_name: queue.name } }"
                v-for="queue in queues"
              >
                <a class="nav-link">{{ queue.name }}</a>
              </router-link>
            </ul>
            <span class="navbar-text" v-if="!queues">No queues</span>
          </div>
        </nav>
        <div class="alert alert-danger" role="alert" v-if="err"><pre>{{ err + '' }}</pre></div>
        <router-view></router-view>
      </div>
    `,
    data: function() {
      return {
        queues: null,
        err: null
      };
    },
    methods: {
      loadQueues: function() {
        var that = this;
        that.err = null;
        api.listQueues(that.$route.params.cluster_id).then(function(queues) {
          that.queues = queues.sort(function(a, b) {
            return a.name < b.name ? -1 : b.name < a.name ? 1 : 0;
          });
        }).catch(function(err) {
          that.err = err;
        });
      }
    },
    created: function() {
      this.loadQueues();
    }
  };
})();
