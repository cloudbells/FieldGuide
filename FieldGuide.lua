-- TODO:
-- Add option (somewhere/somehow) to hide known spells (or maybe just hide any spells before current level) - IsSpellKnown(spellId, isPetSpell). Checkbox?
-- Add option (somewhere/somehow) to search for a certain spell.
-- Add icons for tomes/quests at level 60?
-- Distinguish talents from normal spells.
-- Calculate amount of spell rows dynamically.
-- Add UI checkbox to show talents or not.
-- Add UI checkbox to show enemy faction spells or not.
-- Hide priests race-specific spells not available to current race.
-- Sort spells alphabetically.

-- BUGS:
-- Highlighting over scroll up and down buttons is too big.
-- Scroll bar texture sometimes does not load.

local _, FieldGuide = ...

-- Variables.
local selectedClass = nil -- Which class is currently selected in the dropdown. Will be initialized to player's class on addon load.
local currentClassSpells = nil -- The table of spells. Will be initialized to player's class on addon load.
local currentMinLevel = 2 -- We always start by showing level 2.
local levelStrings = {} -- The table of FontStrings so that we can reuse these.
local spellButtons = {} -- The table of spell buttons so that we can reuse these.
local spellTextures = {} -- The table of spell buttons so that we can reuse these. 
local classBackgrounds = { -- The name of the backgrounds in the game files.
    ["WARRIOR"] = "WarriorArms",
    ["PALADIN"] = "PaladinHoly",
    ["HUNTER"] = "HunterBeastMastery",
    ["ROGUE"] = "RogueAssassination",
    ["PRIEST"] = "PriestHoly",
    ["SHAMAN"] = "ShamanElementalCombat",
    ["MAGE"] = "MageFrost",
    ["WARLOCK"] = "WarlockCurses",
    ["DRUID"] = "DruidFeralCombat"
}

-- UI variables.
local lastValue = 0 -- For the slider to not update a million times a second.
local BUTTON_X_START = 38 -- How far to the right the buttons start.
local BUTTON_Y_START = -25 -- How far down the first button is placed.
local BUTTON_X_SPACING = 45 -- The spacing between all buttons in x.
local LEVEL_STRING_X_START = 35 -- How far to the right the level strings are placed.
local LEVEL_STRING_Y_START = -53 -- How far down the first level string is placed.
local Y_SPACING = 0 -- The spacing between all elements in y.
local NBR_OF_SPELL_ROWS = 5 -- We want to display this many rows of spells.
local NBR_OF_SPELL_COLUMNS = 0 -- Will be calculated later when initializing the frames.
local NBR_OF_SPELL_BUTTONS = 0 -- Will be calculated later when initializing the frames.

-- Options variables.
local showEnemySpells = true
local showTalents = true

-- Returns true if the given class is currently selected in the dropdown list.
local function isSelected(class)
    return selectedClass == class
end

-- Returns true if the player is Alliance.
function isAlliance()
    return UnitFactionGroup("player") == "Alliance"
end

-- Returns the reputation modifier (0.9 if player is honored with any faction, 1 otherwise).
local function getRepModifier()
    local honored = false
    if not isAlliance() then
        honored = select(3, GetFactionInfoByID(530)) > 5 or select(3, GetFactionInfoByID(76)) > 5 or select(3, GetFactionInfoByID(81)) > 5 or select(3, GetFactionInfoByID(68)) > 5
    else
        honored = select(3, GetFactionInfoByID(69)) > 5 or select(3, GetFactionInfoByID(54)) > 5 or select(3, GetFactionInfoByID(47)) > 5 or select(3, GetFactionInfoByID(72)) > 5
    end
    return honored and 0.9 or 1
end

-- Sets the background to the given class.
local function setBackground(class)
    FieldGuideFrameBackgroundTextureClass:SetTexture("Interface\\TALENTFRAME\\" .. classBackgrounds[class] .. "-TopLeft")
    FieldGuideFrameBackgroundTextureClass:SetAlpha(0.4)
end

-- Is called whenever user scrolls with mouse wheel or presses up/down buttons.
local function updateButtons(reset)
    if reset then
        FieldGuideFrameSlider:SetValue(0)
    end
    local counter = 1
    -- Fix level strings and spell buttons.
    for i = 1, NBR_OF_SPELL_ROWS do
        local lastSpellIndex = 0
        local currentLevel = currentMinLevel + (i - 1) * 2
        levelStrings[i]:SetText(currentLevel == 2 and "Level 1" or "Level " .. currentLevel)
        for spellIndex, spellInfo in ipairs(currentClassSpells[currentLevel]) do
            if showEnemySpells or (isAlliance() and spellInfo["faction"] == 1) or -- Whether or not to show enemy faction spells.
                    (not isAlliance() and spellInfo["faction"] == 2) or not spellInfo["faction"] then
                if (showTalents and spellInfo["talent"]) or not spellInfo["talent"] then -- Whether or not to show talents.
                    spellTextures[counter]:SetTexture(spellInfo["texture"])
                    spellTextures[counter]:SetAllPoints()
                    spellButtons[counter].spellId = spellInfo["id"]
                    spellButtons[counter].spellCost = spellInfo["cost"]
                    spellButtons[counter]:Show()
                    counter = counter + 1
                    lastSpellIndex = lastSpellIndex + 1
                end
            end
        end
        for i = counter, counter + NBR_OF_SPELL_COLUMNS - lastSpellIndex - 1 do -- Hide all unnecessary buttons.
            spellButtons[i]:Hide()
            counter = counter + 1
        end
    end
end

-- Changes the class to the given class.
local function setClass(dropdownButton, class)
    UIDropDownMenu_SetSelectedID(FieldGuideDropdownFrame, dropdownButton:GetID())
    setBackground(class)
    currentClassSpells = FieldGuide[class]
    selectedClass = class
    updateButtons(true)
end


-- Sets slash commands.
local function initSlash()
    SLASH_FIELDGUIDE1 = "/FieldGuide"
    SLASH_FIELDGUIDE2 = "/fg"
    SlashCmdList["FIELDGUIDE"] = function()
        if FieldGuideFrame:IsVisible() then
            FieldGuideFrame:Hide()
        else
            FieldGuideFrame:Show()
        end
    end
end

-- Initiates all frames, level strings, and textures for reuse.
local function initFrames()
    local temp = (FieldGuideFrame:GetWidth() - BUTTON_X_START * 2) / BUTTON_X_SPACING -- Faster than math.floor.
    local NBR_OF_SPELL_BUTTONS = (temp + 0.5 - (temp + 0.5) % 1) * NBR_OF_SPELL_ROWS
    Y_SPACING = math.ceil(FieldGuideFrame:GetHeight() / NBR_OF_SPELL_ROWS) / 1.125
    for i = 1, NBR_OF_SPELL_BUTTONS do
        NBR_OF_SPELL_COLUMNS = NBR_OF_SPELL_BUTTONS / NBR_OF_SPELL_ROWS -- The number of buttons in x.
        local spellBtnX = BUTTON_X_START + BUTTON_X_SPACING * ((i - 1) % NBR_OF_SPELL_COLUMNS)
        local spellBtnY = -Y_SPACING * math.ceil(i / NBR_OF_SPELL_COLUMNS) - BUTTON_Y_START
        spellButtons[i] = CreateFrame("BUTTON", nil, FieldGuideFrame, "FieldGuideSpellButtonTemplate")
        spellButtons[i]:SetPoint("TOPLEFT", spellBtnX, spellBtnY)
        spellTextures[i] = spellButtons[i]:CreateTexture(nil, "BORDER")
    end
    -- Create level strings
    for i = 1, NBR_OF_SPELL_ROWS do
        levelStrings[i] = FieldGuideFrame:CreateFontString(nil, "ARTWORK", "FieldGuideLevelStringTemplate")
        levelStrings[i]:SetPoint("TOPLEFT", LEVEL_STRING_X_START, -LEVEL_STRING_Y_START - Y_SPACING * i)
    end
    FieldGuideFrameSlider:SetMinMaxValues(0, 30 - NBR_OF_SPELL_ROWS) -- If we show 5 spell rows, the scroll max value should be 25 (it scrolls to 25th row, and shows the last 5 already).
    tinsert(UISpecialFrames, FieldGuideFrame:GetName()) -- Allows us to close the window with escape.
end

-- Initializes the dropdown menu.
local function initDropDown()
    local dropdown = _G["FieldGuideDropdownFrame"]
    UIDropDownMenu_Initialize(dropdown, function(self)
        local info = UIDropDownMenu_CreateInfo()
        -- Warrior.
        info.text = "Warrior"
        info.colorCode = "|cFFC79C6E"
        info.arg1 = "WARRIOR"
        info.checked = isSelected("WARRIOR")
        info.func = setClass
        UIDropDownMenu_AddButton(info)
        -- Paladin.
        info.text = "Paladin"
        info.colorCode = "|cFFF58CBA"
        info.arg1 = "PALADIN"
        info.checked = isSelected("PALADIN")
        UIDropDownMenu_AddButton(info)
        -- Hunter.
        info.text = "Hunter"
        info.colorCode = "|cFFABD473"
        info.arg1 = "HUNTER"
        info.checked = isSelected("HUNTER")
        UIDropDownMenu_AddButton(info)
        -- Rogue.
        info.text = "Rogue"
        info.colorCode = "|cFFFFF569"
        info.arg1 = "ROGUE"
        info.checked = isSelected("ROGUE")
        UIDropDownMenu_AddButton(info)
        -- Priest.
        info.text = "Priest"
        info.colorCode = "|cFFFFFFFF"
        info.arg1 = "PRIEST"
        info.checked = isSelected("PRIEST")
        UIDropDownMenu_AddButton(info)
        -- Shaman.
        info.text = "Shaman"
        info.colorCode = "|cFF0070DE"
        info.arg1 = "SHAMAN"
        info.checked = isSelected("SHAMAN")
        UIDropDownMenu_AddButton(info)
        -- Mage.
        info.text = "Mage"
        info.colorCode = "|cFF40C7EB"
        info.checked = isSelected("MAGE")
        info.arg1 = "MAGE"
        UIDropDownMenu_AddButton(info)
        -- Warlock.
        info.text = "Warlock"
        info.colorCode = "|cFF8787ED"
        info.arg1 = "WARLOCK"
        info.checked = isSelected("WARLOCK")
        UIDropDownMenu_AddButton(info)
        -- Druid.
        info.text = "Druid"
        info.colorCode = "|cFFFF7D0A"
        info.arg1 = "DRUID"
        info.checked = isSelected("DRUID")
        UIDropDownMenu_AddButton(info)
    end)
    UIDropDownMenu_SetWidth(dropdown, 100);
    UIDropDownMenu_SetButtonWidth(dropdown, 124)
    UIDropDownMenu_JustifyText(dropdown, "RIGHT")
    UIDropDownMenu_SetText(dropdown, "|c" .. RAID_CLASS_COLORS[selectedClass].colorStr .. selectedClass:sub(1, 1) .. string.lower(selectedClass:sub(2)))
end

-- Called whenever player mouses over an icon.
function FieldGuideSpellButton_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    local spell = Spell:CreateFromSpellID(self.spellId)
    spell:ContinueOnSpellLoad(function()
        local canAfford = GetMoney() < self.spellCost and "|cFFFF0000" or "|cFFFFFFFF" -- Modifies string to be red if player can't afford, white otherwise.
        local priceString = GetCoinTextureString(self.spellCost * getRepModifier())
        GameTooltip:SetHyperlink("spell:" .. self.spellId)
        GameTooltip:AddLine("\nPrice: " .. canAfford .. priceString, nil, nil, nil, nil)
        GameTooltip:Show()
    end)
end

-- Called whenever player moves mouse out of an icon.
function FieldGuideSpellButton_OnLeave(self)
    GameTooltip:Hide()
end

-- Is called whenever the value of the slider changes.
function FieldGuide_OnValueChanged(self, value)
    value = value + 0.5 - (value + 0.5) % 1 -- Apparently faster than math.floor().
    if not (value > lastValue or value < lastValue) then -- Throttle.
        return
    end
    if value * 2 < 2 then
        currentMinLevel = 2
    else
        currentMinLevel = value * 2 + 2
    end
    lastValue = value
    updateButtons()
    self:SetValue(value)
    if value < 1 then
        _G[self:GetName() .. "ScrollUpButton"]:Disable()
    elseif value >= select(2, self:GetMinMaxValues()) then
        _G[self:GetName() .. "ScrollDownButton"]:Disable()
    else
        _G[self:GetName() .. "ScrollUpButton"]:Enable()
        _G[self:GetName() .. "ScrollDownButton"]:Enable()
    end
end

-- Called whenever player opens the window.
function FieldGuide_OnShow()
    PlaySound(SOUNDKIT.IG_SPELLBOOK_OPEN);
end

-- Called whenever player closes the window.
function FieldGuide_OnHide()
    PlaySound(SOUNDKIT.IG_SPELLBOOK_CLOSE);
end

-- Called when the player either scrolls or clicks the up/down buttons manually.
function FieldGuide_Scroll(delta)
    FieldGuideFrameSlider:SetValue(FieldGuideFrameSlider:GetValue() - delta)
end

-- Called when the addon has loaded.
function FieldGuide_OnLoad(self)
    self:RegisterForDrag("LeftButton")
    initSlash()
    initFrames()
    selectedClass = select(2, UnitClass("player"))
    currentClassSpells = FieldGuide[selectedClass]
    setBackground(selectedClass)
    updateButtons(true) -- Sets initial textures etc. Without this, everything is empty until we scroll.
    initDropDown()
end