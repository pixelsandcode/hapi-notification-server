_ = require 'lodash'
Boom = require 'boom'

module.exports = (server, options) -> 
  
  bucket = options.database

  Device = require('../models/device')(options)

  {
    create: (request, reply) ->
      payload = request.payload
      key = Device.key payload.user_key
      bucket.get( key ).then( (d) ->
        value = [payload.nid]
        if d instanceof Error
          doc = {}
          doc[payload.device] = value
          bucket.insert( key, doc )
        else
          doc = d.value
          doc[payload.device] = [] unless doc[payload.device]?
          doc[payload.device] = _.union doc[payload.device], value
          bucket.replace( key, doc )
      ).then -> reply.success true

    remove: (request, reply) ->
      key = Device.key request.params.user_key
      bucket.remove(key)
        .then (res) ->
          return reply Boom.notFound() if res instanceof Error
          reply.success true

    set_notification_setting: (request, reply) ->
      Device.set_notification_setting(request.params.user_key, request.payload.notification_level)
      .then (result) ->
        return reply.badImplementation 'something went wrong' if result instanceof Error
        reply.success true
  }
