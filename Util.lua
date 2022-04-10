local _, FieldGuide = ...

local GetNumSkillLines, GetSkillLineInfo = GetNumSkillLines, GetSkillLineInfo

FieldGuide.factions = {
    ["darnassus"] = 69,
    ["darkspear_trolls"] = 530,
    ["stormwind"] = 72,
    ["ironforge"] = 47,
    ["gnomeregan_exiles"] = 54,
    ["orgrimmar"] = 76,
    ["thunder_bluff"] = 81,
    ["undercity"] = 68,
    ["cenarion_circle"] = 609,
    ["booty_bay"] = 21,
    ["theramore"] = 108
}

FieldGuide.maps = {
    ["stormwind"] = 1453,
    ["ironforge"] = 1455,
    ["darnassus"] = 1457,
    ["orgrimmar"] = 1454,
    ["thunder_bluff"] = 1456,
    ["undercity"] = 1458,
    ["elwynn_forest"] = 1429,
    ["dun_morogh"] = 1426,
    ["teldrassil"] = 1438,
    ["tirisfal_glades"] = 1420,
    ["durotar"] = 1411,
    ["swamp_of_sorrows"] = 1435,
    ["felwood"] = 1448,
    ["moonglade"] = 1450,
    ["mulgore"] = 1412,
    ["feralas"] = 1444,
    ["stranglethorn_vale"] = 1434,
    ["stonetalon_mountains"] = 1442,
    ["ashenvale"] = 1440,
    ["loch_modan"] = 1432,
    ["dustwallow_marsh"] = 1445
}

local continents = {
    [1453] = 0, -- Eastern Kingdoms.
    [1455] = 0,
    [1457] = 1, -- Kalimdor.
    [1454] = 1,
    [1456] = 1,
    [1458] = 0,
    [1429] = 0,
    [1426] = 0,
    [1438] = 1,
    [1420] = 0,
    [1411] = 1,
    [1435] = 0,
    [1448] = 1,
    [1450] = 1,
    [1412] = 1,
    [1444] = 1,
    [1434] = 0,
    [1442] = 1,
    [1440] = 1,
    [1432] = 0,
    [1445] = 1
}

FieldGuide.pinPool = {}

-- Returns a pin from the pin pool, and creates one if there is none free.
function FieldGuide:getPin()
    for _, pin in pairs(FieldGuide.pinPool) do
        if not pin.used then
            pin.used = true
            return pin
        end
    end
    FieldGuide.pinPool[#FieldGuide.pinPool + 1] = CreateFrame("Button", nil, nil, "FieldGuidePinTemplate")
    local pin = FieldGuide.pinPool[#FieldGuide.pinPool]
    pin.used = true
    return pin
end

-- Copies the given table and returns the copy. If no table is given, this returns nil.
function FieldGuide.copy(original)
    local copy = {}
    if type(original) == "table" then
        for k, v in pairs(original) do
            copy[k] = v
        end
    else
        return nil
    end
    return copy
end

-- Returns the current continent of the given map.
function FieldGuide.getContinent(map)
    return continents[map]
end

-- Returns true if the weapon skill with the given name is known to the player, false if not.
function FieldGuide.isWeaponKnown(name)
    for i = 1, GetNumSkillLines() do
        if name == GetSkillLineInfo(i) then
            return true
        end
    end
    return false
end

function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function pairsByKeys (t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
      i = i + 1
      if a[i] == nil then return nil
      else return a[i], t[a[i]]
      end
    end
    return iter
  end

function getTableSize(t)
    local count = 0

    if t ~= nil then
        for a,b in pairsByKeys(t) do
            count = count + 1
        end
    end

    return count
end
