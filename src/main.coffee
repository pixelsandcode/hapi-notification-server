exports.register = (server, options, next) ->

  EventEmitter = require('events').EventEmitter
  event_bus = new EventEmitter

  label = options.config.label || 'notification'
  namespace = options.config.namespace || 'ns'

  ns = server.select label
  ns.route require('./routes') ns, options

  server.method "#{namespace}.on", (name, callback) ->
    event_bus.on name, callback

  server.method "#{namespace}.emit", (name) ->
    event_bus.emit.apply event_bus, arguments

  next()

exports.register.attributes = {
  pkg: require('../package.json')
}

