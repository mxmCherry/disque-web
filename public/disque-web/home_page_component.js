var HomePageComponent = (function() {
	'use strict';

	return {
		template: `
			<div>
				<h1>
					Info
					<button class="btn btn-link" v-on:click="loadInfo()" :disabled="busy()">Reload</button>
					<button class="btn btn-link" v-on:click="reconnect()" :disabled="busy()">Reconnect</button>
				</h1>
				<pre>{{ info }}</pre>
			</div>
		`,
		data: function() {
			return {
				info: null,
				infoBusy: false,
				reconnectBusy: false
			};
		},
		methods: {
			busy: function() {
				return this.infoBusy || this.reconnectBusy;
			},
			load: function() {
				this.loadInfo();
			},
			loadInfo: function() {
				var that = this;
				that.infoBusy = true;
				api.serverInfo().then(function(info) {
					that.info = info;
					that.infoBusy = false;
				}).catch(function(err) {
					alert(err + '');
					that.infoBusy = false;
				});
			},
			reconnect: function() {
				if( !confirm('Reconnect?') ) {
					return;
				}
				var that = this;
				that.reconnectBusy = true;
				api.serverReconnect().then(function(info) {
					that.infoBusy = true;
					return api.serverInfo().then(function(info) {
						that.infoBusy = false;
						that.reconnectBusy = false;
					}).catch(function(err) {
						that.infoBusy = false;
						throw err;
					});
				}).catch(function(err) {
					alert(err + '');
					that.reconnectBusy = false;
				});
			}
		},
		created: function() {
			this.load();
		}
	};
})();
