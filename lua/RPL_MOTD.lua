--
-- Retrieve the parsed message.
--
local packet = cjson.decode(redis.call('RPOP', 'lua::parser.RPL_MOTD.lua::data'))
local token = packet.token
local key = packet.uuid ..'::'.. packet.email

--
-- RPL_MOTD: More MOTD, because they can a fucking much as they want.
--
redis.call('HSET', key, 'motd', redis.call('HGET', key, 'motd') ..'\n'.. token.trailing);
