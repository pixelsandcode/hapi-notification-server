_ = require 'lodash'

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
      reply.nice 'Not implemented yet!!!!!'
  }
