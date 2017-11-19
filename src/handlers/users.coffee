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
      device = request.payload.device
      nid = request.payload.nid
      bucket.get(key)
        .then (d) ->
          return reply Boom.notFound() if d instanceof Error || !d.value[device]? || d.value[device].indexOf(nid) < 0
          _.pull(d.value[device], nid)
          delete d.value[device] if d.value[device].length == 0
          clear_device_nid = () ->
            if(!d.value['android'] and !d.value['iphone'])
              return bucket.remove(key)
            else
              return bucket.replace(key, d.value)
          clear_device_nid()
            .then (res) ->
              return reply Boom.badImplementation('something went wrong') if res instanceof Error
              reply.success true

    set_notification_setting: (request, reply) ->
      Device.set_notification_setting(request.params.user_key, request.payload.notification_level)
      .then (result) ->
        return reply.badImplementation 'something went wrong' if result instanceof Error
        reply.success true
  }
