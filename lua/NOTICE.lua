--
-- Retrieve the parsed message.
--
local packet = cjson.decode(redis.call('RPOP', 'lua::parser.NOTICE.lua::data'))
local token = packet.token
local key = packet.uuid ..'::'.. packet.email ..'::NOTICE'

--
-- Notices are on a user basis and should be stored
--
redis.call('RPUSH', key, cjson.encode({
  now = packet.now,
  line = token.trailing
}))

redis.call('PUBLISH', 'ircb.io', cjson.encode({
  email = packet.email,
  now  = packet.now,
  line  = token.trailing,
  type  = 'NOTICE'
}))
