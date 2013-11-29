--
-- Retrieve the parsed message.
--
local packet = cjson.decode(redis.call('RPOP', 'lua::parser.265.lua::data'))
local token = packet.token
local key = packet.uuid ..'::'.. packet.email ..'::NOTICE'

--
-- 265: Local users (related to network)
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
