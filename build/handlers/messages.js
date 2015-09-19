(function() {
  var _;

  _ = require('lodash');

  module.exports = function(server, options) {
    var Device, Message, bucket;
    Message = require('../models/message')(options);
    Device = require('../models/device')(options);
    bucket = options.database;
    return {
      post: function(request, reply) {
        var message, payload;
        payload = request.payload;
        message = new Message;
        return message.load(request.payload.template).then(function(template) {
          if (options.config.mock) {
            message.render(payload.data, 'android');
            message.render(payload.data, 'iphone');
          } else {
            _.each(payload.user_keys, function(u) {
              return Device.find_by_user(u).then(function(device) {
                return message.deliver(device, payload.data);
              });
            });
          }
          return reply.success(true);
        }).done();
      }
    };
  };

}).call(this);
