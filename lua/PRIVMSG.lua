--
-- Retrieve the parsed message.
--
local packet = cjson.decode(redis.call('RPOP', 'lua::parser.PRIVMSG.lua::data'))
local token = packet.token
local sha = redis.sha1hex(token.trailing)
local key = packet.uuid ..'::'.. token.middle[1]
local nick = string.match(token.prefix, "^([^!]+)")

if not redis.call('GET', key ..'::'.. sha ..'::'.. nick) then
  --
  -- Notices are on a user basis and should be stored
  --
  redis.call('RPUSH', key, cjson.encode({
    nick    = nick,
    now    = packet.now,
    line    = token.trailing,
    prefix  = token.prefix
  }))

  --
  -- Prevent duplicate stores
  --
  redis.call('SET', key ..'::'.. sha ..'::'.. nick, 1)

  redis.call('PUBLISH', 'ircb.io', cjson.encode({
    nick    = nick,
    now     = packet.now,
    line    = token.trailing,
    prefix  = token.prefix,
    uuid    = packet.uuid,
    channel = token.middle[1],
    type    = 'PRIVMSG'
  }))
end
