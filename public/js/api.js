var api = (function() {
  'use strict';

  function transformJob(job) {
    try {
      job.body = JSON.parse(job.body);
    } catch(e) {};
    return job;
  }

  function Api(mountpoint) {
    this.__mountpoint = mountpoint || '';
  }

  Api.prototype.__fetch = function(method, url, body) {
    return fetch(this.__mountpoint + url, {
      method: method,
      headers: new Headers({
        Accept: 'application/json'
      }),
      body: JSON.stringify(body),
      credentials: 'include'
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

  Api.prototype.listClusters = function() {
    return this.__fetch('GET', '/clusters/');
  }

  Api.prototype.getCluster = function(id) {
    return this.__fetch('GET', '/clusters/' + encodeURIComponent(id));
  }

  Api.prototype.listQueues = function(clusterId) {
    return this.__fetch('GET', '/clusters/' + encodeURIComponent(clusterId) + '/queues');
  }

  Api.prototype.getQueue = function(clusterId, queueName) {
    return this.__fetch('GET', '/clusters/' + encodeURIComponent(clusterId) + '/queues/' + encodeURIComponent(queueName));
  }

  Api.prototype.listQueueJobs = function(clusterId, queueName) {
    return this.__fetch('GET', '/clusters/' + encodeURIComponent(clusterId) + '/queues/' + encodeURIComponent(queueName) + '/jobs')
  }

  Api.prototype.getJob = function(clusterId, jobId) {
    return this.__fetch('GET', '/clusters/' + encodeURIComponent(clusterId) + '/jobs/' + encodeURIComponent(jobId)).then(transformJob);
  }

  Api.prototype.delJob = function(clusterId, jobId) {
    return this.__fetch('DELETE', '/clusters/' + encodeURIComponent(clusterId) + '/jobs/' + encodeURIComponent(jobId));
  }

  Api.prototype.ackJob = function(clusterId, jobId) {
    return this.__fetch('PUT', '/clusters/' + encodeURIComponent(clusterId) + '/jobs/' + encodeURIComponent(jobId) + '/ack');
  }

  return new Api('api');
})();
