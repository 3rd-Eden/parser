--
-- Retrieve the parsed message.
--
local packet = cjson.decode(redis.call('RPOP', 'lua::parser.003.lua::data'))
local token = packet.token
local key = packet.uuid ..'::'.. packet.email ..'::NOTICE'

---
-- 003 is the server creation data, a.k.a. a NOTICE
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
