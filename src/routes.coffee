Joi = require 'joi'

module.exports = (server, options) ->

  Users = require('./handlers/users') server, options
  Messages = require('./handlers/messages') server, options
  
  [
    {
      method: 'POST'
      path: "/users"
      config: {
        handler: Users.create
        description: 'Store user with notification id'
        tags: ['user', 'notification']
        validate: {
          payload: {
            user_key: Joi.string().required()
            nid: Joi.string().required()
            device: Joi.string().required().valid('iphone','android')
          }
        }
      }
    }
    {
      method: 'DELETE'
      path: "/users/{id}"
      config: {
        handler: Users.remove
        description: "Clear user's notification id"
        tags: ['user', 'notification']
      }
    }
    {
      method: 'POST'
      path: "/messages"
      config: {
        handler: Messages.post
        description: 'Send a notification to users by user_key'
        tags: ['message', 'notification']
        validate: {
          payload: {
            user_keys: Joi.array().required()
            template: Joi.string().required()
            data: Joi.object().required()
          }
        }
      }
    }
 
  ]
