--
-- Retrieve the parsed message.
--
local packet = cjson.decode(redis.call('RPOP', 'lua::parser.001.lua::data'))
local token = packet.token
local key = packet.uuid ..'::'.. packet.email

---
-- A 001 is an indication that the /nick has been set.
--
redis.call('HSET', key, 'nick', token.middle);

redis.call('PUBLISH', 'ircb.io', cjson.encode({
  email   = packet.email,
  type    = 'ACCOUNT',
  key     = 'nick',
  value   = token.middle
}))

if token.trailing then
  redis.call('RPUSH', key ..'::NOTICE', cjson.encode({
    now = packet.now,
    line = token.trailing
  }))

  redis.call('PUBLISH', 'ircb.io', cjson.encode({
    email = packet.email,
    now  = packet.now,
    line  = token.trailing,
    type  = 'NOTICE'
  }))
end
