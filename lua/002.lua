--
-- Retrieve the parsed message.
--
local packet = cjson.decode(redis.call('RPOP', 'lua::parser.002.lua::data'))
local token = packet.token
local key = packet.uuid ..'::'.. packet.email ..'::NOTICE'

---
-- 002 is a welcome message from the IRC server, a.k.a. a NOTICE
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
