(function() {
  module.exports = function(options) {
    var Device, bucket;
    bucket = options.database;
    return Device = (function() {
      function Device() {}

      Device.prototype.PREFIX = "ns";

      Device.prototype.POSTFIX = "unsubscribe";

      Device.key = function(user_key) {
        return "ns_u_" + user_key;
      };

      Device.find_by_user = function(user_key) {
        return bucket.get(this.key(user_key), true);
      };

      Device.unsubscribe = function(user_key, notification_level) {
        var _this, doc, key;
        key = this._unsubscribe_key(user_key);
        _this = this;
        doc = {
          unsubscribed_notifications: options.config.notification_levels[notification_level].unsubscribed_notifications
        };
        return bucket.get(key).then(function(d) {
          if (d instanceof Error) {
            return bucket.insert(key, doc);
          } else {
            return bucket.replace(key, doc);
          }
        });
      };

      Device._unsubscribe_key = function(user_key) {
        return Device.prototype.PREFIX + ":" + user_key + ":" + Device.prototype.POSTFIX;
      };

      Device.get_unsubscribed_notifications_of_user = function(user_key) {
        var key;
        key = this._unsubscribe_key(user_key);
        return bucket.get(key).then(function(d) {
          if (d instanceof Error) {
            return [];
          }
          return d.value.unsubscribed_notifications;
        });
      };

      Device.check_if_user_unsubscribed = function(user_key, notification_type) {
        return this.get_unsubscribed_notifications_of_user(user_key).then(function(unsubscribed_notificaions) {
          if (unsubscribed_notificaions instanceof Error || unsubscribed_notificaions === options.config.notification_levels.all.unsubscribed_notifications) {
            return false;
          } else if (unsubscribed_notificaions === options.config.notification_levels.none.unsubscribed_notifications) {
            return true;
          } else if (unsubscribed_notificaions.indexOf(notification_type) >= 0) {
            return true;
          }
          return false;
        });
      };

      return Device;

    })();
  };

}).call(this);
