(function() {
  exports.register = function(server, options, next) {
    var EventEmitter, event_bus, label, namespace, ns;
    EventEmitter = require('events').EventEmitter;
    event_bus = new EventEmitter;
    label = options.config.label || 'notification';
    namespace = options.config.namespace || 'ns';
    ns = server.select(label);
    ns.route(require('./routes')(ns, options));
    server.method(namespace + ".on", function(name, callback) {
      return event_bus.on(name, callback);
    });
    server.method(namespace + ".emit", function(name) {
      return event_bus.emit.apply(event_bus, arguments);
    });
    return next();
  };

  exports.register.attributes = {
    pkg: require('../package.json')
  };

}).call(this);
