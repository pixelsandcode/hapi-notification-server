Joi = require 'joi'
_   = require 'lodash'

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
      path: "/users/{user_key}"
      config: {
        handler: Users.remove
        description: "Clear user's notification id"
        tags: ['user', 'notification']
        validate: {
          payload: {
            nid: Joi.string().required()
            device: Joi.string().required().valid('iphone','android')
          }
        }
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
    {
      method: 'POST'
      path: "/users/{user_key}/notifications/setting"
      config: {
        handler: Users.set_notification_setting
        description: 'Set notification setting for user'
        tags: ['users', 'notification']
        validate: {
          payload: {
            notification_level: Joi.string().valid( _.keys(options.config.notification_levels) )
          }
        }
      }
    }
    {
      method: 'GET'
      path: "/messages/levels"
      config: {
        handler: Messages.get_notification_levels
        description: 'Return existing notification levels'
        tags: ['message', 'notification']
      }
    }
  ]
