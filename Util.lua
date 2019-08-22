local _, FieldGuide = ...

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
    ["stormwind"] = 84,
    ["ironforge"] = 87,
    ["darnassus"] = 89,
    ["orgrimmar"] = 85,
    ["thunder_bluff"] = 88,
    ["undercity"] = 90,
    ["elwynn_forest"] = 37,
    ["dun_morogh"] = 27,
    ["teldrassil"] = 57,
    ["tirisfal_glades"] = 18,
    ["durotar"] = 1,
    ["swamp_of_sorrows"] = 51,
    ["felwood"] = 77,
    ["moonglade"] = 80,
    ["mulgore"] = 7,
    ["feralas"] = 69,
    ["stranglethorn_vale"] = 224,
    ["stonetalon_mountains"] = 65,
    ["ashenvale"] = 63,
    ["loch_modan"] = 48,
    ["dustwallow_marsh"] = 70
}

local continents = {
    [84] = 0, -- Eastern Kingdoms.
    [87] = 0,
    [89] = 1, -- Kalimdor.
    [85] = 1,
    [88] = 1,
    [90] = 0,
    [37] = 0,
    [27] = 0,
    [57] = 1,
    [18] = 0,
    [1] = 1,
    [51] = 0,
    [77] = 1,
    [80] = 1,
    [7] = 1,
    [69] = 1,
    [224] = 0,
    [65] = 1,
    [63] = 1,
    [48] = 0,
    [70] = 1
}

-- FieldGuide.maps = {
    -- ["stormwind"] = 1453,
    -- ["ironforge"] = 1455,
    -- ["darnassus"] = 1457,
    -- ["orgrimmar"] = 1454,
    -- ["thunder_bluff"] = 1456,
    -- ["undercity"] = 1458,
    -- ["elwynn_forest"] = 1429,
    -- ["dun_morogh"] = 1426,
    -- ["teldrassil"] = 1438,
    -- ["tirisfal_glades"] = 1420,
    -- ["durotar"] = 1411,
    -- ["swamp_of_sorrows"] = 1435,
    -- ["felwood"] = 1448,
    -- ["moonglade"] = 1450,
    -- ["mulgore"] = 1412,
    -- ["feralas"] = 1444,
    -- ["stranglethorn_vale"] = 1434,
    -- ["stonetalon_mountains"] = 1442,
    -- ["ashenvale"] = 1440,
    -- ["loch_modan"] = 1432,
    -- ["dustwallow_marsh"] = 1445
-- }

-- local continents = {
    -- [1453] = 0, -- Eastern Kingdoms.
    -- [1455] = 0,
    -- [1457] = 1, -- Kalimdor.
    -- [1454] = 1,
    -- [1456] = 1,
    -- [1458] = 0,
    -- [1429] = 0,
    -- [1426] = 0,
    -- [1438] = 1,
    -- [1420] = 0,
    -- [1411] = 1,
    -- [1435] = 0,
    -- [1448] = 1,
    -- [1450] = 1,
    -- [1412] = 1,
    -- [1444] = 1,
    -- [1434] = 0,
    -- [1442] = 1,
    -- [1440] = 1,
    -- [1432] = 0,
    -- [1445] = 1
-- }

FieldGuide.pinPool = {}

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

function FieldGuide.getContinent(map)
    return continents[map]
end
