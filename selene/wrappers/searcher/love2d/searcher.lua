local selene = require("selene")

local libenv = {}
setmetatable(libenv, { __index = _G })
libenv.table.unpack = table.unpack or unpack
selene.load(libenv)

local lib = {}

lib.libenv = libenv

local function selene_loader(path)
  return function(name)
    local source = love.filesystem.read(path)
    local f = assert(libenv.load(libenv._selene._parse(source), path))
    local result = f(name)
    if result then
      return result
    end
  end
end

local function selene_searcher(name)
  local _errors = {}

  local fname = name:gsub("%.", "/")

  for pattern in love.filesystem.getRequirePath():gmatch("[^;]+") do

    local fpath = pattern:gsub("%?", fname)
    if love.filesystem.getInfo(fpath, "file") then
      return selene_loader(fpath)
    else
      table.insert(_errors, "\tno file '" .. fpath .. "'")
    end
  end

  return table.concat(_errors, "\n")
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
