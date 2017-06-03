local shell = require("shell")
if _G._selene and _G._selene.liveMode then
  shell.execute("lua", nil, ...)
else
  local env = setmetatable({}, {__index = _ENV})
  local parser = require("selene.parser")
  local selene = require("selene")
  selene.load(env)
  env._PROMPT = "selene> "
  local oldload = env.load
  env.load = function(ld, src, mv, loadenv)
    if type(ld) == "function" then
      local s = ""
      local nws = ld()
      while nws and #nws > 0 do
        s = s .. nws
        nws = ld()
      end
      ld = s
    end
    ld = parser.parse(ld)
    return oldload(ld, src, mv, loadenv)
  end
  shell.execute("lua", env, ...)
end
