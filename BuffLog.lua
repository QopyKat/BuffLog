-- NAMESPACE
local _, BuffLog = ...
BuffLog.ADDON_NAME = "BuffLog"
BuffLog.lastTimeLogged = 0

-- COMMAND
SLASH_BUFFLOG1 = "/bufflog"
SlashCmdList["BUFFLOG"] = function(msg)
    BuffLog:slashCommands(msg)
end

-- INTERFACE
local BuffLogFrame = CreateFrame("Frame") -- Root frame

-- REGISTER EVENTS
BuffLogFrame:RegisterEvent("ADDON_LOADED")
BuffLogFrame:RegisterEvent("UNIT_HEALTH")
BuffLogFrame:RegisterEvent("TAXIMAP_OPENED")

-- REGISTER EVENT LISTENERS
BuffLogFrame:SetScript("OnEvent", function(self, event, arg1, ...) 
    BuffLogFrame:onEvent(self, event, arg1, ...) 
end);

-- COMMAND HANDLER
function BuffLog:slashCommands(msg)
  local command, rest = strsplit(" ", msg, 2)
  if command == "clear" then
    BuffLog_SavedBuffs = {}
    print("BuffLog SavedVariables cleared.")
  else
    BuffLog:logBuffs()
  end
end

-- EVENT HANDLER
function BuffLogFrame:onEvent(self, event, arg1, ...)
    
    if event == "ADDON_LOADED" then
        if arg1 == BuffLog.ADDON_NAME then
            local colorHex = "2979ff"
            print("|cff"..colorHex..BuffLog.ADDON_NAME.." loaded - /bufflog")
        end
    end

    -- TRIGGER ON EVENT THAT FIRES A LOT
    if event == "UNIT_HEALTH" or event == "UNIT_POWER" then
      -- ONLY COLLECT BUFFS IF WE HAVNT DONE IT FOR AT LEAST 2 SECONDS
      if time() - BuffLog.lastTimeLogged <= 2 then return end
      
      -- CHECK IF WE'RE IN A RAID INSTANCE
      local inInstance, instanceType = IsInInstance()
      if inInstance and instanceType == "raid" then
        BuffLog:logBuffs()
        BuffLog.lastTimeLogged = time()
      end
    end

    -- CLEAR SAVED VARIABLES WHENEVER TALKING TO FLIGHTPATH
    -- AND THE VARIABLES ARE MORE THAN 5 HOURS OLD
    if event == "TAXIMAP_OPENED" then
        if not BuffLog_LastLog then return end
        if time() - BuffLog_LastLog > 18000 then
            BuffLog_SavedBuffs = {}
            print("BuffLog SavedVariables cleared.")
        end
    end
end

-- BUFF LOG FUNCTIONS
function BuffLog:logBuffs()
  local buffs = BuffLog:getBuffs()
  BuffLog:saveBuffs(buffs)
  print("Buffs Logged")
end


function BuffLog:getBuffs()
    if UnitInRaid("player") then
        return BuffLog:getRaidBuffs()

    elseif UnitInParty("player") then
        return BuffLog:getPartyBuffs()

    else
        return BuffLog:getPlayerbuffs()
    end
end

function BuffLog:getPlayerbuffs()
  local buffs = {}
  buffs[UnitGUID("player")] = BuffLog:getUnitBuffs("player")
  return buffs
end

function BuffLog:getPartyBuffs()
  local buffs = BuffLog:getPlayerbuffs()
  for i = 1, GetNumGroupMembers() - 1 do
      unit = "party" .. i
      buffs[UnitGUID(unit)] = BuffLog:getUnitBuffs(unit)
  end
  return buffs
end

function BuffLog:getRaidBuffs()
  local buffs = {}
  for i = 1, GetNumGroupMembers() do
      unit = "raid" .. i
      buffs[UnitGUID(unit)] = BuffLog:getUnitBuffs(unit)
  end
  return buffs
end

function BuffLog:getUnitBuffs(unit)
  local buffs = {}
  for buffIndex = 1, 40 do
      _, _, _, _, _, _, _, _, _, spellId = UnitBuff(unit, buffIndex)
      if spellId ~= nil then
          buffs[#buffs + 1] = spellId
      end
  end
  return buffs
end

function BuffLog:saveBuffs(buffs)
    local key = date("%m-%d-%H-%M-%S")
    BuffLog_SavedBuffs = BuffLog_SavedBuffs or {}
    BuffLog_SavedBuffs[key] = buffs
    BuffLog_LastLog = time()
end
