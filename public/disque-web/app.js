var App = (function() {
	'use strict';

	return {
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
				{ name: 'home',  path: '/',             component: HomePageComponent  },
				{ name: 'queue', path: '/queues/:name', component: QueuePageComponent },
				{ name: 'job',   path: '/jobs/:id',     component: JobPageComponent   }
			]
		}),
		created: function() {
			this.loadQueues();
		}
	};
})();
