module.exports = (options) ->
  
  bucket = options.database

  return class Device

    PREFIX: "ns"
    POSTFIX: "unsubscribe"
    
    @key: (user_key) -> "ns_u_#{user_key}"

    @find_by_user: (user_key) ->
      bucket.get @key(user_key), true

    @unsubscribe: (user_key, notification_level) ->
      key = @_unsubscribe_key(user_key)
      _this = @
      doc = { unsubscribed_notifications: options.config.notification_levels[notification_level].unsubscribed_notifications }
      bucket.get(key)
        .then (d) ->
          if d instanceof Error
            bucket.insert(key, doc)
          else
            bucket.replace(key, doc)

    @_unsubscribe_key: (user_key) ->
      "#{Device::PREFIX}:#{user_key}:#{Device::POSTFIX}"

    @get_unsubscribed_notifications_of_user: (user_key) ->
      key = @_unsubscribe_key(user_key)
      bucket.get(key)
        .then (d) ->
          return [] if d instanceof Error
          d.value.unsubscribed_notifications

    @check_if_user_unsubscribed: (user_key, notification_type) ->
      @get_unsubscribed_notifications_of_user(user_key)
        .then (unsubscribed_notificaions) ->
          if unsubscribed_notificaions instanceof Error || unsubscribed_notificaions == options.config.notification_levels.all.unsubscribed_notifications
            return false
          else if unsubscribed_notificaions == options.config.notification_levels.none.unsubscribed_notifications
            return true
          else if unsubscribed_notificaions.indexOf(notification_type) >= 0
            return true
          false
