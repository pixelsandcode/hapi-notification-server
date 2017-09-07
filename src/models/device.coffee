module.exports = (options) ->
  
  bucket = options.database

  return class Device

    NOTIFICATION_SETTING:
      PREFIX: "ns"
      POSTFIX: "setting"
    
    @key: (user_key) -> "ns_u_#{user_key}"

    @find_by_user: (user_key) ->
      bucket.get @key(user_key), true

    @set_notification_setting: (user_key, notification_level) ->
      key = @_notification_setting_key(user_key)
      doc = { notification_level: notification_level }
      bucket.get(key)
        .then (d) ->
          if d instanceof Error
            bucket.insert(key, doc)
          else
            bucket.update(key, doc)

    @_notification_setting_key: (user_key) ->
      "#{Device::NOTIFICATION_SETTING.PREFIX}:#{user_key}:#{Device::NOTIFICATION_SETTING.POSTFIX}"

    @get_notification_setting: (user_key) ->
      key = @_notification_setting_key(user_key)
      bucket.get(key)
        .then (d) ->
          return new Error() if d instanceof Error
          d.value

    @check_if_user_unsubscribed: (user_key, notification_type) ->
      @get_notification_setting(user_key)
        .then (setting) ->
          if setting instanceof Error || !options.config.notification_levels? || !setting.notification_level? || setting.notification_level == options.config.notification_levels.all
            return false
          else if setting.notification_level == options.config.notification_levels.none
            return true
          else if options.config.notification_levels[setting.notification_level]? and options.config.notification_levels[setting.notification_level].unsubscribed_notifications.indexOf(notification_type) >= 0
            return true
          false
