Hapi Notification Server
======

[![Build Status](https://travis-ci.org/tectual/hapi-notification-server.svg)](https://travis-ci.org/tectual/hapi-notification-server)
[![npm version](https://badge.fury.io/js/hapi-notification-server.svg)](http://badge.fury.io/js/hapi-notification-server)
[![Coverage Status](https://coveralls.io/repos/tectual/hapi-notification-server/badge.svg?branch=master)](https://coveralls.io/r/tectual/hapi-notification-server?branch=master)

[Hapi Notification Server](https://www.npmjs.com/package/hapi-notification-server) is using couchbase with puffer library to register user devices and send notifications to both android and ios.

* Source code is available at [here](https://github.com/tectual/hapi-notification-server).

## How to use

You have to pass these variables to the plugin.

```yaml
notification:
  host: localhost
  port: 3200
  namespace: ns
  label: notification
  templates: /Users/developer/my_project/ns_templates
  apn:
    cert: path_to_cert
    key: path_to_key
    production: true
  gcm: 1234567890
```

You should start a notification server in your code and also pass configuration to the notification server plugin:
```coffee
server.connection { port: Number(config.server.notification.port), labels: config.server.notification.label }

db = new require('puffer')(config.database)

server.register [ { register: require('hapi-notification-server'), options: { config: config.server.notification, database: db } } ], (err) -> throw err if err
```

## Events
This plugin will add an event bus to decouple your business logic from notification logic.

```coffee
# creating an event
server.methods.ns.on 'experiences.new', (experience_key)->
  # user_doc_keys =  Your logic to find which users should get this notification
  # { "user_keys": [1, 11], "template": "events.new", "data": { "hostel": "Base Sydney", "name": "Manly BBQ" } }
  server.inject {
    url: "#{config.server.notification.host}:#{config.server.notification.port}/messages"
    payload: JSON.stringify(user_doc_keys)
  }, (res) ->

# triggering the event
server.methods.ns.emit 'experiences.new', 'ex_003'
```

## APIs
### POST /users 
**Payload { user_key: 'key', nid: 'notification token', device: 'android | ios' }**

This is used to store user's device in notifcation server.
### DELETE /users/{id}
This will delete a user's device in notifcation server.
### POST /messages 
**Payload { user_keys: ['key1', 'key2', ...], tempalte: 'events.new', data: { name: 'Snow trip', at: '3 days from now' } }**
This will send a message to all users' devices.

## Templates

Path to template folder is defined in the configuration at plugin registration time. Notification Server plugin will use that path and your template name to load android or iphone message format.

If you have your template path set to */Users/developer/my_project/ns_templates* and your template name is 'events.new', Notification Server will try to laod 2 tempaltes:
# /Users/developer/my_project/ns_templates/events/new.android.json
# /Users/developer/my_project/ns_templates/events/new.iphone.json

Android file should be like this (read more at https://www.npmjs.com/package/node-gcm):
```json
{ "data": { "message": "#{hostel} created new event #{name}. Check #{name} now!" } }
```

iPhone file should be like this (read more at https://www.npmjs.com/package/apn):
```json
{ "badge": 0, "sound": "buzz.aiff", "alert": "#{hostel} created new event #{name}. Check #{name} now!", "payload": { "hostel": "#{hostel}" } }
```
