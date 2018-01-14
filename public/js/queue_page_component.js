var QueuePageComponent = (function() {
	'use strict';

	return {
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
})();
