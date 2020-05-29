local component = require("component")
local sides = require("sides")

local x = component.transposer
local db = {}

local dump_side = sides.top
local sort_side = sides.south

function seeAll()
  local size = x.getInventorySize(sort_side)
  for i=1,size,1 do
    local y = x.getStackInSlot(sort_side, i)
    if type(y) == "table" then
      print(string.format("%-30s %-20s (%s)", y.name, y.label, y.size))
    end
  end
end

function create_database()
  local size = x.getInventorySize(sort_side)
  for i=1,size,1 do
    local y = x.getStackInSlot(sort_side, i)
    if type(y) == "table" then
      local entry = {}
      entry.name = y.name
      entry.size = y.size
      entry.slot = i
      db[y.label] = entry
    end
  end
end

function getSlot(label)
  if db[label] then
    return db[label].slot
  else
    return 0
  end
end

function dump()
  local size = x.getInventorySize(dump_side)
  for i=1,size,1 do
    local y = x.getStackInSlot(dump_side, i)
    if type(y) == "table" then
      slot = getSlot(y.label)
      if slot ~= 0 then
        x.transferItem(dump_side, sort_side, y.size, i, slot)
      end
    else
      break
    end
  end
end

create_database()

seeAll()

dump()