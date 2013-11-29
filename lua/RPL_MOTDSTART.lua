--
-- Retrieve the parsed message.
--
local packet = cjson.decode(redis.call('RPOP', 'lua::parser.RPL_MOTDSTART.lua::data'))
local token = packet.token
local key = packet.uuid ..'::'.. packet.email

--
-- RPL_MOTDSTART: Start of the motd message. Who gives a fuck about that.
--
redis.call('HSET', key, 'motd', token.trailing);
