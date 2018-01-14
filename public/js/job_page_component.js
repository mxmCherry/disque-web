var JobPageComponent = (function() {
	'use strict';

	return {
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
})();
