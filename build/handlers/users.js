(function() {
  var Boom, _;

  _ = require('lodash');

  Boom = require('boom');

  module.exports = function(server, options) {
    var Device, bucket;
    bucket = options.database;
    Device = require('../models/device')(options);
    return {
      create: function(request, reply) {
        var key, payload;
        payload = request.payload;
        key = Device.key(payload.user_key);
        return bucket.get(key).then(function(d) {
          var doc, value;
          value = [payload.nid];
          if (d instanceof Error) {
            doc = {};
            doc[payload.device] = value;
            return bucket.insert(key, doc);
          } else {
            doc = d.value;
            if (doc[payload.device] == null) {
              doc[payload.device] = [];
            }
            doc[payload.device] = _.union(doc[payload.device], value);
            return bucket.replace(key, doc);
          }
        }).then(function() {
          return reply.success(true);
        });
      },
      remove: function(request, reply) {
        var device, key, nid;
        key = Device.key(request.params.user_key);
        device = request.payload.device;
        nid = request.payload.nid;
        return bucket.get(key).then(function(d) {
          var clear_device_nid;
          if (d instanceof Error || (d.value[device] == null) || d.value[device].indexOf(nid) < 0) {
            return reply(Boom.notFound());
          }
          _.pull(d.value[device], nid);
          if (d.value[device].length === 0) {
            delete d.value[device];
          }
          clear_device_nid = function() {
            if (!d.value['android'] && !d.value['iphone']) {
              return bucket.remove(key);
            } else {
              return bucket.replace(key, d.value);
            }
          };
          return clear_device_nid().then(function(res) {
            if (res instanceof Error) {
              return reply(Boom.badImplementation('something went wrong'));
            }
            return reply.success(true);
          });
        });
      },
      set_notification_setting: function(request, reply) {
        return Device.set_notification_setting(request.params.user_key, request.payload.notification_level).then(function(result) {
          if (result instanceof Error) {
            return reply.badImplementation('something went wrong');
          }
          return reply.success(true);
        });
      }
    };
  };

}).call(this);
