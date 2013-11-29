--
-- retrieve the parsed message.
--
local packet = cjson.decode(redis.call('RPOP', 'lua::parser.RPL_LUSERME.lua::data'))
local token = packet.token
local key = packet.uuid ..'::'.. packet.email ..'::NOTICE'

--
-- RPL_LUSEROP: Information about local connections
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
