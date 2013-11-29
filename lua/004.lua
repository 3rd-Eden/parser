--
-- Retrieve the parsed message.
--
local packet = cjson.decode(redis.call('RPOP', 'lua::parser.004.lua::data'))
local token = packet.token
local key = packet.uuid ..'::'.. packet.email

---
-- 004 contains server information about the allowed modes
--
redis.call('HSET', key, 'info', cjson.encode(token.middle));

redis.call('PUBLISH', 'ircb.io', cjson.encode({
  email   = packet.email,
  type    = 'ACCOUNT',
  key     = 'info',
  value   = token.middle
}))
