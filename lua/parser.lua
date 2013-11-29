--
-- Retrieve the JSON document with all the details and unpack it so we can start
-- doing some data analytics on it.
--
local key = assert(KEYS[1], 'Should have a key');
local data = assert(ARGV[1], 'Should have received parser instructions.')
local packet = cjson.decode(data)

--
-- Check for a dedicated parser for this specific event
--
local dedicated = redis.call('GET', 'lua::parser.'.. packet.command ..'.lua')
if dedicated and _G['f_'.. dedicated] then
  redis.call('LPUSH', 'lua::parser.'.. packet.command ..'.lua::data', data);
  return _G['f_'.. dedicated]()
else
  --
  -- Check for a general parser instead.
  --
  local parser = redis.call('GET', 'lua::parser.grammar.lua')
  if parser and _G['f_'.. parser] then
    redis.call('LPUSH', 'lua::parser.grammar.lua::data', data);
    return _G['f_'.. dedicated]()
  else
    return redis.error_reply('No parser available for command '.. packet.command)
  end
end
