var api = (function() {
	'use strict';

	function transformJob(job) {
		try {
			job.body = JSON.parse(job.body);
		} catch(e) {};
		return job;
	}

	function API(mountpoint) {
		this.__mountpoint = mountpoint || '';
	}

	API.prototype.__fetch = function(method, url, body) {
		return fetch(this.__mountpoint + url, {
			method: method,
			headers: new Headers({
				Accept: 'application/json'
			}),
			body: JSON.stringify(body)
		}).then(function(response) {
			var contentType = response.headers.get('Content-Type');
			if( contentType && contentType.includes('application/json') ) {
				return response.json();
			}
			return response.text().then(function(text) {
				throw new Error(text);
			});
		});
	}

	API.prototype.serverInfo = function() {
		return this.__fetch('GET', '/server/info');
	}

	API.prototype.serverReconnect = function() {
		return this.__fetch('PUT', '/server/reconnect');
	}

	API.prototype.listQueues = function() {
		return this.__fetch('GET', '/queues/');
	}

	API.prototype.getQueue = function(name) {
		return this.__fetch('GET', '/queues/' + encodeURIComponent(name));
	}

	API.prototype.getQueueJobs = function(name) {
		return this.__fetch('GET', '/queues/' + encodeURIComponent(name) + '/jobs')
	}

	API.prototype.getJob = function(id) {
		return this.__fetch('GET', '/jobs/' + encodeURIComponent(id)).then(function(job) {
			return transformJob(job);
		});
	}

	API.prototype.ackJob = function(id) {
		return this.__fetch('PUT', '/jobs/' + encodeURIComponent(id) + '/ack');
	}

	API.prototype.delJob = function(id) {
		return this.__fetch('DELETE', '/jobs/' + encodeURIComponent(id));
	}

	return new API('api');
})();
