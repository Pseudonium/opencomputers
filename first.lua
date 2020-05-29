local component = require("component")
local sides = require("sides")

local x = component.transposer
local db = {}

local dump_side = sides.top
local sort_side = sides.south

function seeAll()
  --Return a representation of the sorted inventory
  local size = x.getInventorySize(sort_side)
  for i=1,size,1 do
    local y = x.getStackInSlot(sort_side, i)
    if type(y) == "table" then
      print(string.format("%-30s %-20s (%s)", y.name, y.label, y.size))
    end
  end
end

function create_database()
  --Create internal database based off of the sorted inventory
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
  --Return the sort inventory slot associated with the label, or 0 if none found
  if db[label] then
    return db[label].slot
  else
    return 0
  end
end

function dump()
  --Dump contents of dump chest into system, where possible, without overflowing the system
  local size = x.getInventorySize(dump_side)
  for i=1,size,1 do
    local y = x.getStackInSlot(dump_side, i)
    if type(y) == "table" then
      dumpStackInSlot(i)
    else
      break
    end
  end
end

function dumpStackInSlot(slot)
  --Dump contents of slot in dump chest into system, if possible, without overflowing the system
  local stack = x.getStackInSlot(dump_side, slot)
  local sort_slot = getSlot(stack.label)
  if sort_slot == 0 then
    break
  end
  local max_size = x.getSlotMaxStackSize(sort_side, sort_slot)
  local current_size = x.getSlotStackSize(sort_side, sort_slot)
  local remaining = max_size - current_size
  local transfer_count = math.min(stack.size, remaining)
  x.transferItem(dump_side, sort_side, transfer_count, slot, sort_slot)
end

create_database()

seeAll()

dump()