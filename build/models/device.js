(function() {
  module.exports = function(options) {
    var Device, bucket;
    bucket = options.database;
    return Device = (function() {
      function Device() {}

      Device.key = function(user_key) {
        return "ns_u_" + user_key;
      };

      Device.find_by_user = function(user_key) {
        return bucket.get(this.key(user_key), true);
      };

      return Device;

    })();
  };

}).call(this);
