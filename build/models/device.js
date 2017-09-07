(function() {
  module.exports = function(options) {
    var Device, bucket;
    bucket = options.database;
    return Device = (function() {
      function Device() {}

      Device.prototype.NOTIFICATION_SETTING = {
        PREFIX: "ns",
        POSTFIX: "setting"
      };

      Device.key = function(user_key) {
        return "ns_u_" + user_key;
      };

      Device.find_by_user = function(user_key) {
        return bucket.get(this.key(user_key), true);
      };

      Device.set_notification_setting = function(user_key, notification_level) {
        var doc, key;
        key = this._notification_setting_key(user_key);
        doc = {
          notification_level: notification_level
        };
        return bucket.get(key).then(function(d) {
          if (d instanceof Error) {
            return bucket.insert(key, doc);
          } else {
            return bucket.update(key, doc);
          }
        });
      };

      Device._notification_setting_key = function(user_key) {
        return Device.prototype.NOTIFICATION_SETTING.PREFIX + ":" + user_key + ":" + Device.prototype.NOTIFICATION_SETTING.POSTFIX;
      };

      Device.get_notification_setting = function(user_key) {
        var key;
        key = this._notification_setting_key(user_key);
        return bucket.get(key).then(function(d) {
          if (d instanceof Error) {
            return new Error();
          }
          return d.value;
        });
      };

      Device.check_if_user_unsubscribed = function(user_key, notification_type) {
        return this.get_notification_setting(user_key).then(function(setting) {
          if (setting instanceof Error || (options.config.notification_levels == null) || (setting.notification_level == null) || setting.notification_level === options.config.notification_levels.all) {
            return false;
          } else if (setting.notification_level === options.config.notification_levels.none) {
            return true;
          } else if ((options.config.notification_levels[setting.notification_level] != null) && options.config.notification_levels[setting.notification_level].unsubscribed_notifications.indexOf(notification_type) >= 0) {
            return true;
          }
          return false;
        });
      };

      return Device;

    })();
  };

}).call(this);
