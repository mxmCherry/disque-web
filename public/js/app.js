(function() {
  'use strict';

  new Vue({
    el: '#app',
    template: `
      <div>
        <router-view></router-view>
      </div>
    `,
    router: new VueRouter({
      routes: [
        {
          name: 'home',
          path: '/',
          component: Home
        },
        {
          name: 'cluster',
          path: '/cluster/:cluster_id',
          component: Cluster,
          children: [
            { name: 'cluster_info',  path: '',                   component: ClusterHome },
            { name: 'cluster_queue', path: 'queues/:queue_name', component: ClusterQueue },
            { name: 'cluster_job',   path: 'jobs/:job_id',       component: ClusterJob }
          ]
        },
      ]
    })
  });
})();
