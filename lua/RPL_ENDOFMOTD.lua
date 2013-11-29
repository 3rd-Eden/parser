--
-- Retrieve the parsed message.
--
local packet = cjson.decode(redis.call('RPOP', 'lua::parser.RPL_ENDOFMOTD.lua::data'))
local token = packet.token
local key = packet.uuid ..'::'.. packet.email
local motd = redis.call('HGET', key, 'motd') ..'\n'.. token.trailing

--
-- RPL_ENDOFMOTD: FINALLY, done.
--
redis.call('HSET', key, 'motd', motd);
redis.call('PUBLISH', 'ircb.io', cjson.encode({
  email   = packet.email,
  type    = 'ACCOUNT',
  key     = 'motd',
  now     = packet.now,
  value   = motd
}))
