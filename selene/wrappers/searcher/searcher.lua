local selene = require("selene")

local libenv = {}
setmetatable(libenv, { __index = _G })
selene.load(libenv)

local lib = {}

lib.libenv = libenv

local _table_blacklist = { "_ENV", "_G" }
do
  local t = {}
  for _, v in pairs(_table_blacklist) do
    t[v] = true
  end
  _table_blacklist = t
end

local function selene_loader(name, path)
  local env = {}
  setmetatable(env, { __index = _G })
  local file = assert(io.open(path, 'rb'))
  local source = file:read("*a")
  file:close()
  local result = assert(libenv.load(libenv._selene._parse(source), path, 'bt', env))(name)
  if result then
    return result
  end
  local api = {}
  for k, v in pairs(env) do
    if not _table_blacklist[k] then
      api[k] = v
    end
  end
  return api
end

local function selene_searcher(name)
  local path, msg = package.searchpath(name, package.path)
  if path then
    return selene_loader, path
  else
    return nil, msg
  end
end

local function parser()
  return selene.parser
end

function lib.load(index)
  index = index or 2
  local searchers = package.searchers or package.loaders
  if searchers then
    parser() --load the parser
    table.insert(searchers, index, selene_searcher)
  end
end

function lib.unload()
  local searchers = package.searchers or package.loaders
  if searchers then
    for i = 1, #searchers do
      if searchers[i] == selene_searcher then
        table.remove(searchers, i)
        break
      end
    end
  end
end

return lib
