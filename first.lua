local component = require("component")
local sides = require("sides")
local event = require("event")

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
      entry.label = y.label
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
    return
  else
    x.transferItem(dump_side, sort_side, stack.size, slot, sort_slot)
  end
end

function firstEmptySlot()
  --Determine the first empty slot in the dump chest
  local size = x.getInventorySize(dump_side)
  for i=1,size,1 do
    local y = x.getStackInSlot(dump_side, i)
    if type(y) ~= "table" then
      return i
    end
  end
  return 0
end

function retrieve(label, amount)
  --Attempt to retrieve that amount of item from the system
  local sort_slot = getSlot(label)
  if sort_slot ~= 0 then
    local empty = 0
    local available = db[label].size
    if amount > available then print(string.format("Warning! You have requested more than in the system, sending all available %s instead.", label)) end
    while amount > 64 do
      empty = firstEmptySlot()
      x.transferItem(sort_side, dump_side, 64, sort_slot, empty)
      amount = amount - 64
    end
    empty = firstEmptySlot()
    x.transferItem(sort_side, dump_side, amount, sort_slot, empty)
  else
    print(string.format("Item %s not in system.", label))
  end
end

function displayEntry(e)
  --Prints the entry to the console
  print(string.format("%-30s %-20s (%s)", e.name, e.label, e.size))
end

function search(s)
  --Find all labels that contain s as a substring
  for label, entry in pairs(db) do
    if string.find(label, s) then
      displayEntry(entry)
    end
  end
end

create_database()

seeAll()

event.listen("touch", dump)