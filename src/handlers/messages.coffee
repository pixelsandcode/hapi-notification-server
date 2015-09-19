_    = require 'lodash'

module.exports = (server, options) -> 

  Message = require('../models/message')(options)
  Device = require('../models/device')(options)
  
  bucket = options.database

  {
    post: (request, reply) ->
      payload = request.payload
      message = new Message
      message.load(request.payload.template).then( (template) ->
        if options.config.mock
          message.render payload.data, 'android'
          message.render payload.data, 'iphone'
        else
          _.each payload.user_keys, (u) ->
            Device.find_by_user(u).then (device) ->
              message.deliver( device, payload.data )
        reply.success true
      ).done()
  }
