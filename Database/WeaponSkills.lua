local _, FieldGuide = ...

-- Copies the given table and returns the copy. If no table is given, this returns nil.
FieldGuide.shallowTableCopy = function(original)
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

local weapons = {
    ["bows"] = {
        ["name"] = "Bows",
        ["rank"] = 1,
        ["cost"] = 1000,
        ["texture"] = "Interface/ICONS/inv_weapon_bow_05",
        ["id"] = 264
    },
    ["crossbows"] = {
        ["name"] = "Crossbows",
        ["rank"] = 1,
        ["cost"] = 1000,
        ["texture"] = "Interface/ICONS/inv_weapon_crossbow_01",
        ["id"] = 5011
    },
    ["daggers"] = {
        ["name"] = "Daggers",
        ["rank"] = 1,
        ["cost"] = 1000,
        ["texture"] = "Interface/ICONS/ability_steelmelee",
        ["id"] = 1180
    },
    ["fistWeapons"] = {
        ["name"] = "Fist Weapons",
        ["rank"] = 1,
        ["cost"] = 1000,
        ["texture"] = "Interface/ICONS/inv_gauntlets_04",
        ["id"] = 15590
    },
    ["guns"] = {
        ["name"] = "Guns",
        ["rank"] = 1,
        ["cost"] = 1000,
        ["texture"] = "Interface/ICONS/inv_weapon_rifle_01",
        ["id"] = 266
    },
    ["oneHandedAxes"] = {
        ["name"] = "One-Handed Axes",
        ["rank"] = 1,
        ["cost"] = 1000,
        ["texture"] = "Interface/ICONS/inv_axe_01",
        ["id"] = 196
    },
    ["oneHandedMaces"] = {
        ["name"] = "One-Handed Maces",
        ["rank"] = 1,
        ["cost"] = 1000,
        ["texture"] = "Interface/ICONS/inv_mace_01",
        ["id"] = 198
    },
    ["oneHandedSwords"] = {
        ["name"] = "One-Handed Swords",
        ["rank"] = 1,
        ["cost"] = 1000,
        ["texture"] = "Interface/ICONS/ability_meleedamage",
        ["id"] = 201
    },
    ["polearms"] = {
        ["name"] = "Polearms",
        ["rank"] = 1,
        ["cost"] = 10000,
        ["texture"] = "Interface/ICONS/inv_spear_06",
        ["id"] = 200
    },
    ["staves"] = {
        ["name"] = "Staves",
        ["rank"] = 1,
        ["cost"] = 1000,
        ["texture"] = "Interface/ICONS/inv_staff_08",
        ["id"] = 227
    },
    ["thrown"] = {
        ["name"] = "Thrown",
        ["rank"] = 1,
        ["cost"] = 1000,
        ["texture"] = "Interface/ICONS/inv_throwingknife_02",
        ["id"] = 2567
    },
    ["twoHandedAxes"] = {
        ["name"] = "Two-Handed Axes",
        ["rank"] = 1,
        ["cost"] = 1000,
        ["texture"] = "Interface/ICONS/inv_axe_04",
        ["id"] = 197
    },
    ["twoHandedMaces"] = {
        ["name"] = "Two-Handed Maces",
        ["rank"] = 1,
        ["cost"] = 1000,
        ["texture"] = "Interface/ICONS/inv_mace_04",
        ["id"] = 199
    },
    ["twoHandedSwords"] = {
        ["name"] = "Two-Handed Swords",
        ["rank"] = 1,
        ["cost"] = 1000,
        ["texture"] = "Interface/ICONS/ability_meleedamage",
        ["id"] = 202
    },
    ["wands"] = {
        ["name"] = "Wands",
        ["rank"] = 1,
        ["cost"] = 1000,
        ["texture"] = "Interface/ICONS/ability_shootwand",
        ["id"] = 5009
    },
}

FieldGuide.WEAPONS = {
    { -- Warrior.
        FieldGuide.shallowTableCopy(weapons.bows),
        FieldGuide.shallowTableCopy(weapons.crossbows),
        FieldGuide.shallowTableCopy(weapons.daggers),
        FieldGuide.shallowTableCopy(weapons.fistWeapons),
        FieldGuide.shallowTableCopy(weapons.guns),
        FieldGuide.shallowTableCopy(weapons.oneHandedAxes),
        FieldGuide.shallowTableCopy(weapons.oneHandedMaces),
        FieldGuide.shallowTableCopy(weapons.oneHandedSwords),
        FieldGuide.shallowTableCopy(weapons.polearms),
        FieldGuide.shallowTableCopy(weapons.staves),
        FieldGuide.shallowTableCopy(weapons.thrown),
        FieldGuide.shallowTableCopy(weapons.twoHandedAxes),
        FieldGuide.shallowTableCopy(weapons.twoHandedMaces),
        FieldGuide.shallowTableCopy(weapons.twoHandedSwords)
    },
    { -- Paladin.
        FieldGuide.shallowTableCopy(weapons.oneHandedAxes),
        FieldGuide.shallowTableCopy(weapons.oneHandedMaces),
        FieldGuide.shallowTableCopy(weapons.oneHandedSwords),
        FieldGuide.shallowTableCopy(weapons.polearms),
        FieldGuide.shallowTableCopy(weapons.twoHandedAxes),
        FieldGuide.shallowTableCopy(weapons.twoHandedMaces),
        FieldGuide.shallowTableCopy(weapons.twoHandedSwords)
    },
    { -- Hunter.
        FieldGuide.shallowTableCopy(weapons.bows),
        FieldGuide.shallowTableCopy(weapons.crossbows),
        FieldGuide.shallowTableCopy(weapons.daggers),
        FieldGuide.shallowTableCopy(weapons.fistWeapons),
        FieldGuide.shallowTableCopy(weapons.guns),
        FieldGuide.shallowTableCopy(weapons.oneHandedAxes),
        FieldGuide.shallowTableCopy(weapons.oneHandedSwords),
        FieldGuide.shallowTableCopy(weapons.polearms),
        FieldGuide.shallowTableCopy(weapons.staves),
        FieldGuide.shallowTableCopy(weapons.thrown),
        FieldGuide.shallowTableCopy(weapons.twoHandedAxes),
        FieldGuide.shallowTableCopy(weapons.twoHandedSwords)
    },
    { -- Rogue.
        FieldGuide.shallowTableCopy(weapons.bows),
        FieldGuide.shallowTableCopy(weapons.crossbows),
        FieldGuide.shallowTableCopy(weapons.daggers),
        FieldGuide.shallowTableCopy(weapons.fistWeapons),
        FieldGuide.shallowTableCopy(weapons.guns),
        FieldGuide.shallowTableCopy(weapons.oneHandedMaces),
        FieldGuide.shallowTableCopy(weapons.oneHandedSwords),
        FieldGuide.shallowTableCopy(weapons.thrown)
    },
    { -- Priest.
        FieldGuide.shallowTableCopy(weapons.daggers),
        FieldGuide.shallowTableCopy(weapons.oneHandedMaces),
        FieldGuide.shallowTableCopy(weapons.staves),
        FieldGuide.shallowTableCopy(weapons.wands)
    },
    { -- Shaman.
        FieldGuide.shallowTableCopy(weapons.oneHandedAxes),
        FieldGuide.shallowTableCopy(weapons.oneHandedMaces),
        FieldGuide.shallowTableCopy(weapons.staves),
        FieldGuide.shallowTableCopy(weapons.twoHandedAxes),
        FieldGuide.shallowTableCopy(weapons.twoHandedMaces)
    },
    { -- Mage.
        FieldGuide.shallowTableCopy(weapons.daggers),
        FieldGuide.shallowTableCopy(weapons.oneHandedSwords),
        FieldGuide.shallowTableCopy(weapons.staves),
        FieldGuide.shallowTableCopy(weapons.wands)
    },
    { -- Warlock.
        FieldGuide.shallowTableCopy(weapons.daggers),
        FieldGuide.shallowTableCopy(weapons.oneHandedSwords),
        FieldGuide.shallowTableCopy(weapons.staves),
        FieldGuide.shallowTableCopy(weapons.wands)
    },
    { -- Druid.
        FieldGuide.shallowTableCopy(weapons.daggers),
        FieldGuide.shallowTableCopy(weapons.oneHandedMaces),
        FieldGuide.shallowTableCopy(weapons.staves),
        FieldGuide.shallowTableCopy(weapons.wands)
    },
}