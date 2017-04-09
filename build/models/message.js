(function() {
  var APN, Fs, GCM, Path, Q, _;

  _ = require('lodash');

  Path = require('path');

  Fs = require('fs');

  Q = require('q');

  APN = require('apn');

  GCM = require('node-gcm');

  module.exports = function(options) {
    var Message;
    return Message = (function() {
      function Message() {}

      Message.prototype.load = function(template) {
        var _this, android, filename, iphone;
        this.templates = {
          android: null,
          iphone: null
        };
        _this = this;
        filename = template.replace(/\./, '/');
        android = Path.join(options.config.templates, filename + ".android.json");
        iphone = Path.join(options.config.templates, filename + ".iphone.json");
        return Q.all([Q.nfcall(Fs.readFile, android, "utf-8"), Q.nfcall(Fs.readFile, iphone, "utf-8")]).then(function(templates) {
          return _this.templates = {
            android: _.trim(templates[0]),
            iphone: _.trim(templates[1])
          };
        });
      };

      Message.prototype.render = function(data, type) {
        var tmpl, vars;
        tmpl = this.templates[type];
        vars = _.uniq(tmpl.match(/#\{[^\}\{]+\}/g));
        _.each(vars, function(value, key) {
          var ref, v;
          v = (ref = _.get(data, _.trim(value, '#{}'))) != null ? ref : '';
          return tmpl = tmpl.replace(new RegExp(value, 'g'), v);
        });
        return tmpl.replace(/#\{[^\}\{]+\}/g, '');
      };

      Message.prototype.deliver = function(device, data) {
        var e;
        try {
          if (device instanceof Error) {
            return false;
          }
          return _.each(device, function(sids, type) {
            var msg;
            msg = JSON.parse(this.render(data, type));
            if (type === 'iphone') {
              return this.deliver_to_iphone(sids, msg);
            } else if (type === 'android') {
              return this.deliver_to_android(sids, msg);
            }
          }, this);
        } catch (error) {
          e = error;
          return console.log(e);
        }
      };

      Message.prototype.apn = function() {
        return this.apn_connection || (this.apn_connection = new APN.Provider(options.config.apn.provider));
      };

      Message.prototype.gcm = function() {
        return this.gcm_connection || (this.gcm_connection = new GCM.Sender(options.config.gcm));
      };

      Message.prototype.deliver_to_iphone = function(sids, msg) {
        var note;
        this.apn();
        note = new APN.Notification;
        note.topic = options.config.apn.bundle_id;
        _.each(msg, function(v, k) {
          return note[k] = v;
        });
        return _.each(sids, function(sid) {
          return this.apn_connection.send(note, sid);
        }, this);
      };

      Message.prototype.deliver_to_android = function(sids, msg) {
        var note;
        this.gcm();
        note = new GCM.Message;
        _.each(msg, function(v, k) {
          return note[k] = v;
        });
        return this.gcm_connection.send(note, sids);
      };

      return Message;

    })();
  };

}).call(this);
