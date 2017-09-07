(function() {
  var _;

  _ = require('lodash');

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
        return reply.nice('Not implemented yet!!!!!');
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
