local _, FieldGuide = ...

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
        weapons.bows,
        weapons.crossbows,
        weapons.daggers,
        weapons.fistWeapons,
        weapons.guns,
        weapons.oneHandedAxes,
        weapons.oneHandedMaces,
        weapons.oneHandedSwords,
        weapons.polearms,
        weapons.staves,
        weapons.thrown,
        weapons.twoHandedAxes,
        weapons.twoHandedMaces,
        weapons.twoHandedSwords
    },
    { -- Paladin.
        weapons.oneHandedAxes,
        weapons.oneHandedMaces,
        weapons.oneHandedSwords,
        weapons.polearms,
        weapons.twoHandedAxes,
        weapons.twoHandedMaces,
        weapons.twoHandedSwords
    },
    { -- Hunter.
        weapons.bows,
        weapons.crossbows,
        weapons.daggers,
        weapons.fistWeapons,
        weapons.guns,
        weapons.oneHandedAxes,
        weapons.oneHandedSwords,
        weapons.polearms,
        weapons.staves,
        weapons.thrown,
        weapons.twoHandedAxes,
        weapons.twoHandedSwords
    },
    { -- Rogue.
        weapons.bows,
        weapons.crossbows,
        weapons.daggers,
        weapons.fistWeapons,
        weapons.guns,
        weapons.oneHandedMaces,
        weapons.oneHandedSwords,
        weapons.thrown
    },
    { -- Priest.
        weapons.daggers,
        weapons.oneHandedMaces,
        weapons.staves,
        weapons.wands
    },
    { -- Shaman.
        weapons.oneHandedAxes,
        weapons.oneHandedMaces,
        weapons.staves,
        weapons.twoHandedAxes,
        weapons.twoHandedMaces
    },
    { -- Mage.
        weapons.daggers,
        weapons.oneHandedSwords,
        weapons.staves,
        weapons.wands
    },
    { -- Warlock.
        weapons.daggers,
        weapons.oneHandedSwords,
        weapons.staves,
        weapons.wands
    },
    { -- Druid
        weapons.daggers,
        weapons.oneHandedMaces,
        weapons.staves,
        weapons.wands
    },
}