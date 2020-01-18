-- NAMESPACE
BuffLog = {}
ADDON_NAME = "BuffLog"

-- COMMAND
SLASH_BUFFLOG1 = "/bufflog"
SlashCmdList["BUFFLOG"] = function(msg) BuffLog:logBuffs(msg) end

-- INTERFACE
local BuffLogFrame = CreateFrame("Frame") -- Root frame

-- REGISTER EVENTS
BuffLogFrame:RegisterEvent("ADDON_LOADED")

-- REGISTER EVENT LISTENERS
BuffLogFrame:SetScript("OnEvent", function(self, event, arg1, ...) BuffLogFrame:onEvent(self, event, arg1, ...) end);

-- COMMAND HANDLER
function BuffLog:logBuffs(msg)
    local buffs = BuffLog:getBuffs()
    BuffLog:saveBuffs(buffs)
    print("done")
end

-- EVENT HANDLER
function BuffLogFrame:onEvent(self, event, arg1, ...)
    if event == "ADDON_LOADED" then
        if arg1 == ADDON_NAME then
            local colorHex = "2979ff"
            print("|cff"..colorHex..ADDON_NAME.." loaded - /bufflog")
        end
    end
end

-- BUFF LOG FUNCTIONS
function BuffLog:getBuffs()
    if UnitInRaid("player") then
        print('raid')
        return BuffLog:getRaidBuffs()

    elseif UnitInParty("player") then
        print('party')
        return BuffLog:getPartyBuffs()
        
    else
        print('solo')
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
    print("Player: " .. unit)
    local buffs = {}
    for buffIndex = 1, 40 do
        name, _, _, _, _, _, _, _, _, spellId = UnitBuff(unit, buffIndex)
        -- if spellId == nil then
        --     break
        -- end
        if spellId ~= nil then
            print(name .. ": " .. spellId)
            buffs[#buffs + 1] = spellId
        end
    end
    return buffs
end

function BuffLog:saveBuffs(buffs)
    local key = date("%m-%d-%H-%M-%S")
    BuffLog_SavedBuffs = BuffLog_SavedBuffs or {}
    BuffLog_SavedBuffs[key] = buffs
end
