--
-- Retrieve the parsed message.
--
local packet = cjson.decode(redis.call('RPOP', 'lua::parser.RPL_LUSERUNKNOWN.lua::data'))
local token = packet.token
local key = packet.uuid ..'::'.. packet.email ..'::NOTICE'

--
-- RPL_LUSERUNKNOWN: Unknown connection counts.
--
redis.call('RPUSH', key, cjson.encode({
  now = packet.now,
  line = token.middle[1] ..' '.. token.trailing
}))

redis.call('PUBLISH', 'ircb.io', cjson.encode({
  email = packet.email,
  now  = packet.now,
  line  = token.middle[1] ..' '.. token.trailing,
  type  = 'NOTICE'
}))
