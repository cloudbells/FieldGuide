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
    ["fist_weapons"] = {
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
    ["one_handed_axes"] = {
        ["name"] = "One-Handed Axes",
        ["rank"] = 1,
        ["cost"] = 1000,
        ["texture"] = "Interface/ICONS/inv_axe_01",
        ["id"] = 196
    },
    ["one_handed_maces"] = {
        ["name"] = "One-Handed Maces",
        ["rank"] = 1,
        ["cost"] = 1000,
        ["texture"] = "Interface/ICONS/inv_mace_01",
        ["id"] = 198
    },
    ["one_handed_swords"] = {
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
    ["two_handed_axes"] = {
        ["name"] = "Two-Handed Axes",
        ["rank"] = 1,
        ["cost"] = 1000,
        ["texture"] = "Interface/ICONS/inv_axe_04",
        ["id"] = 197
    },
    ["two_handed_maces"] = {
        ["name"] = "Two-Handed Maces",
        ["rank"] = 1,
        ["cost"] = 1000,
        ["texture"] = "Interface/ICONS/inv_mace_04",
        ["id"] = 199
    },
    ["two_handed_swords"] = {
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
    }
}

FieldGuide.WEAPONS = {
    [1] = { -- Warrior.
        FieldGuide.copy(weapons.bows),
        FieldGuide.copy(weapons.crossbows),
        FieldGuide.copy(weapons.daggers),
        FieldGuide.copy(weapons.fist_weapons),
        FieldGuide.copy(weapons.guns),
        FieldGuide.copy(weapons.one_handed_axes),
        FieldGuide.copy(weapons.one_handed_maces),
        FieldGuide.copy(weapons.one_handed_swords),
        FieldGuide.copy(weapons.polearms),
        FieldGuide.copy(weapons.staves),
        FieldGuide.copy(weapons.thrown),
        FieldGuide.copy(weapons.two_handed_axes),
        FieldGuide.copy(weapons.two_handed_maces),
        FieldGuide.copy(weapons.two_handed_swords)
    },
    [2] = { -- Paladin.
        FieldGuide.copy(weapons.one_handed_axes),
        FieldGuide.copy(weapons.one_handed_maces),
        FieldGuide.copy(weapons.one_handed_swords),
        FieldGuide.copy(weapons.polearms),
        FieldGuide.copy(weapons.two_handed_axes),
        FieldGuide.copy(weapons.two_handed_maces),
        FieldGuide.copy(weapons.two_handed_swords)
    },
    [3] = { -- Hunter.
        FieldGuide.copy(weapons.bows),
        FieldGuide.copy(weapons.crossbows),
        FieldGuide.copy(weapons.daggers),
        FieldGuide.copy(weapons.fist_weapons),
        FieldGuide.copy(weapons.guns),
        FieldGuide.copy(weapons.one_handed_axes),
        FieldGuide.copy(weapons.one_handed_swords),
        FieldGuide.copy(weapons.polearms),
        FieldGuide.copy(weapons.staves),
        FieldGuide.copy(weapons.thrown),
        FieldGuide.copy(weapons.two_handed_axes),
        FieldGuide.copy(weapons.two_handed_swords)
    },
    [4] = { -- Rogue.
        FieldGuide.copy(weapons.bows),
        FieldGuide.copy(weapons.crossbows),
        FieldGuide.copy(weapons.daggers),
        FieldGuide.copy(weapons.fist_weapons),
        FieldGuide.copy(weapons.guns),
        FieldGuide.copy(weapons.one_handed_maces),
        FieldGuide.copy(weapons.one_handed_swords),
        FieldGuide.copy(weapons.thrown)
    },
    [5] = { -- Priest.
        FieldGuide.copy(weapons.daggers),
        FieldGuide.copy(weapons.one_handed_maces),
        FieldGuide.copy(weapons.staves),
        FieldGuide.copy(weapons.wands)
    },
    [6] = { -- Shaman.
        FieldGuide.copy(weapons.one_handed_axes),
        FieldGuide.copy(weapons.one_handed_maces),
        FieldGuide.copy(weapons.staves),
        FieldGuide.copy(weapons.two_handed_axes),
        FieldGuide.copy(weapons.two_handed_maces)
    },
    [7] = { -- Mage.
        FieldGuide.copy(weapons.daggers),
        FieldGuide.copy(weapons.one_handed_swords),
        FieldGuide.copy(weapons.staves),
        FieldGuide.copy(weapons.wands)
    },
    [8] = { -- Warlock.
        FieldGuide.copy(weapons.daggers),
        FieldGuide.copy(weapons.one_handed_swords),
        FieldGuide.copy(weapons.staves),
        FieldGuide.copy(weapons.wands)
    },
    [9] = { -- Druid.
        FieldGuide.copy(weapons.daggers),
        FieldGuide.copy(weapons.one_handed_maces),
        FieldGuide.copy(weapons.staves),
        FieldGuide.copy(weapons.wands)
    },
}