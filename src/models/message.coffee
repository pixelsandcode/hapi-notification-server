_    = require 'lodash'
Path = require 'path'
Fs   = require 'fs'
Q    = require 'q'
APN  = require 'apn'
FBAdmin  = require 'firebase-admin'

module.exports = (options) ->

  return class Message

    load: (template) ->
      @templates = { android: null, iphone: null }
      _this = @
      filename = template.replace(/\./,'/')
      android = Path.join options.config.templates, "#{filename}.android.json"
      iphone = Path.join options.config.templates, "#{filename}.iphone.json"
      Q.all([
        Q.nfcall(Fs.readFile, android, "utf-8"),
        Q.nfcall(Fs.readFile, iphone, "utf-8")
        ]).then( (templates) ->
          _this.templates = { android: _.trim(templates[0]), iphone: _.trim(templates[1]) }
        )

    render: (data, type)->
      tmpl = @templates[type]
      vars = _.uniq tmpl.match /#\{[^\}\{]+\}/g
      _.each vars, (value, key) ->
        v = _.get(data, _.trim(value,'#{}')) ? ''
        tmpl = tmpl.replace new RegExp(value, 'g'), v
      tmpl.replace /#\{[^\}\{]+\}/g, ''
  
    deliver: (device, data)->
      try 
        return false if device instanceof Error
        _.each  device, 
                (sids, type) ->
                  msg = JSON.parse @render( data, type )
                  if type == 'iphone'
                    @deliver_to_iphone sids, msg
                  else if type == 'android'
                    @deliver_to_android sids, msg
                , @
      catch e
        console.log e
    
    apn: -> @apn_connection ||= new APN.Connection options.config.apn
    
    # gcm: -> @gcm_connection ||= new GCM.Sender options.config.gcm
    fcm: -> @fcm_connection ||= new FBAdmin.initializeApp {
      credential: admin.credential.cert({
        projectId: options.config.fcm.projectId,
        privateKey: options.config.fcm.privateKey,
        clientEmail: options.config.fcm.privateKey,
      })  ,
      databaseURL: options.config.fcm.databaseURL,
    }

    deliver_to_iphone: (sids, msg)->
      @apn()
      note = new APN.Notification
      _.each msg, (v,k)-> note[k] = v
      _.each  sids,
              (sid)->
                device = new APN.Device sid
                @apn_connection.pushNotification note, device
              , @

    deliver_to_android: (sids, msg)->
      @fcm()
      note = new FBAdmin.messaging()
      _.each msg, (v,k)-> note[k] = v
      @gcm_connection.messaging(). send note, sids
