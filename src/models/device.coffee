module.exports = (options) ->
  
  bucket = options.database

  return class Device
    
    @key: (user_key) -> "ns_u_#{user_key}"

    @find_by_user: (user_key) ->
      bucket.get @key(user_key), true 
