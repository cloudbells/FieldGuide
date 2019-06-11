--[[
    Features:
    ---------------------------------------
    0. Auto change width per class.
    1. Add icons for tomes/quests at level 60. AQ ones, but also Mage drink quest in DM/Arcane Brilliance and Warlock Shadow Ward rank 4 etc.
    2. Add weapon skills.
    3. (Add option (somewhere/somehow) to search for a certain spell.)
    4. (Add info for where to learn spells – e.g. if player is honored with only Ironforge, then tell her to go to Ironforge to train.)
    5. (Mark spells that the player does not wish to train and save between sessions. Perhaps make them grey?)
    6. (Add Warlock pet skills.)
    7. Fix PvP rank spell cost modification function for Classic release.
    ---------------------------------------

    Spells left to add:
    ---------------------------------------
    1. Priest: show all friendly faction race-specific spells, but add in tooltip which race each spell can be learned by.
    2. Shaman: add Mail at level 40.
    ---------------------------------------

    Spells left to organize:
    ---------------------------------------
    1. Priest: show all friendly faction race-specific spells, but add in tooltip which race each spell can be learned by.
    2. Shaman: add Mail at level 40.
    ---------------------------------------

    Bugs:
    ---------------------------------------
    1. Scroll bar texture sometimes does not load.
    2. Highlighting over scroll up and down buttons is too big.
    3. Ranks do not show in the tooltip (even in Classic) – add manually?
    4. Shadowburn rank 6 does not show price – need info from Classic.
    ---------------------------------------
--]]

local _, FieldGuide = ...

-- Variables.
local selectedClass = nil -- Which class is currently selected in the dropdown. Will be initialized to player's class on addon load.
local currentMinLevel = 2 -- We always start by showing level 2.
local levelStrings = {} -- The table of FontStrings so that we can reuse these.
local spellButtons = {} -- The table of spell buttons so that we can reuse these.
local spellTextures = {} -- The table of spell textures so that we can reuse these. 
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

-- Toggles the frame on and off.
local function toggleFrame()
    if FieldGuideFrame:IsVisible() then
        FieldGuideFrame:Hide()
    else
        FieldGuideFrame:Show()
    end
end

-- Returns true if the player is Alliance.
local function isAlliance()
    return UnitFactionGroup("player") == "Alliance"
end

-- Returns true if the current spell with the given spellInfo is supposed to be shown.
local function buttonConditions(spellInfo)
    return (FieldGuideOptions.showKnownSpells or not IsSpellKnown(spellInfo["id"])) and
            (FieldGuideOptions.showEnemySpells or (isAlliance() and spellInfo["faction"] == 1) or
            (not isAlliance() and spellInfo["faction"] == 2) or not spellInfo["faction"]) and
            ((FieldGuideOptions.showTalents and spellInfo["talent"]) or not spellInfo["talent"])
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
        for spellIndex, spellInfo in ipairs(FieldGuide[selectedClass][currentLevel]) do
            if buttonConditions(spellInfo) then
                spellTextures[counter]:SetTexture(spellInfo["texture"])
                spellTextures[counter]:SetAllPoints()
                spellButtons[counter]:Hide() -- So that tooltip updates when we scroll.
                spellButtons[counter].spellId = spellInfo["id"]
                spellButtons[counter].spellCost = spellInfo["cost"]
                spellButtons[counter]:Show()
                counter = counter + 1
                lastSpellIndex = lastSpellIndex + 1
            end
        end
        for i = counter, counter + NBR_OF_SPELL_COLUMNS - lastSpellIndex - 1 do -- Hide all unnecessary buttons.
            spellButtons[i]:Hide()
            counter = counter + 1
        end
    end
end

-- Sets the background to the given class.
local function setBackground(class)
    FieldGuideFrameBackgroundTextureClass:SetTexture("Interface/TALENTFRAME/" .. classBackgrounds[class] .. "-TopLeft")
    FieldGuideFrameBackgroundTextureClass:SetAlpha(0.4)
end

-- Changes the class to the given class.
local function setClass(dropdownButton, class)
    UIDropDownMenu_SetSelectedID(FieldGuideDropdownFrame, dropdownButton:GetID())
    setBackground(class)
    selectedClass = class
    updateButtons(true)
end

-- Returns true if the given class is currently selected in the dropdown list.
local function isSelected(class)
    return selectedClass == class
end

-- Toggles the minimap button on or off.
local function toggleMinimapButton()
    FieldGuideOptions.minimapTable.hide = not FieldGuideOptions.minimapTable.hide
    if FieldGuideOptions.minimapTable.hide then
        FieldGuide.minimapIcon:Hide("FieldGuide")
        print("Minimap button hidden. Type /fg minimap to show it again.")
    else
        FieldGuide.minimapIcon:Show("FieldGuide")
    end
end

-- Sets slash commands.
local function initSlash()
    SLASH_FIELDGUIDE1 = "/fieldguide"
    SLASH_FIELDGUIDE2 = "/fg"
    SlashCmdList["FIELDGUIDE"] = function(msg)
        msg = string.lower(msg)
        if msg == "minimap" then
            toggleMinimapButton()
            return
        end
        toggleFrame()
    end
end

-- Initializes the minimap button.
local function initMinimapButton()
    FieldGuide.minimapIcon = LibStub("LibDBIcon-1.0")
    local obj = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("FieldGuide", {
        type = "launcher",
        text = "Field Guide",
        icon = "Interface/ICONS/INV_Misc_Book_09",
        OnClick = function(self, button)
            if button == "LeftButton" then
                toggleFrame()
            elseif button == "RightButton" then
                toggleMinimapButton()
            end
        end,
        OnEnter = function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:AddLine("|cFFFFFFFFField Guide|r")
            GameTooltip:AddLine("Left click to open Field Guide.")
            GameTooltip:AddLine("Right click to hide this minimap button.")
            GameTooltip:Show()
        end,
        OnLeave = function(self)
            GameTooltip:Hide()
        end
    })
    FieldGuide.minimapIcon:Register("FieldGuide", obj, FieldGuideOptions.minimapTable)
end

-- Initializes all checkboxes.
local function initCheckboxes()
    -- Show talents checkbox.
    FieldGuideFrameTalentsCheckBoxText:SetFont("Fonts/FRIZQT__.TTF", 12, "OUTLINE")
    FieldGuideFrameTalentsCheckBoxText:SetTextColor(1, 1, 1, 1)
    FieldGuideFrameTalentsCheckBoxText:SetText("Talents")
    FieldGuideFrameTalentsCheckBox:SetPoint("RIGHT", FieldGuideDropdownFrame, "LEFT", 10 - FieldGuideFrameTalentsCheckBoxText:GetWidth(), 2)
    -- Show enemy faction spells checkbox.
    FieldGuideFrameEnemySpellsCheckBoxText:SetFont("Fonts/FRIZQT__.TTF", 12, "OUTLINE")
    FieldGuideFrameEnemySpellsCheckBoxText:SetTextColor(1, 1, 1, 1)
    FieldGuideFrameEnemySpellsCheckBoxText:SetText((isAlliance() and "Horde" or "Alliance") .. " spells")
    FieldGuideFrameEnemySpellsCheckBox:SetPoint("RIGHT", FieldGuideFrameTalentsCheckBox, "LEFT", -FieldGuideFrameEnemySpellsCheckBoxText:GetWidth(), 0)
    -- Show known spells checkbox.
    FieldGuideFrameKnownSpellsCheckBoxText:SetFont("Fonts/FRIZQT__.TTF", 12, "OUTLINE")
    FieldGuideFrameKnownSpellsCheckBoxText:SetTextColor(1, 1, 1, 1)
    FieldGuideFrameKnownSpellsCheckBoxText:SetText("Known spells")
    FieldGuideFrameKnownSpellsCheckBox:SetPoint("RIGHT", FieldGuideFrameEnemySpellsCheckBox, "LEFT", -FieldGuideFrameKnownSpellsCheckBoxText:GetWidth(), 0)
    -- Set checked or not checked.
    FieldGuideFrameTalentsCheckBox:SetChecked(FieldGuideOptions.showTalents)
    FieldGuideFrameEnemySpellsCheckBox:SetChecked(FieldGuideOptions.showEnemySpells)
    FieldGuideFrameKnownSpellsCheckBox:SetChecked(FieldGuideOptions.showKnownSpells)
end

-- Initializes the dropdown menu.
local function initDropdown()
    selectedClass = select(2, UnitClass("player"))
    local dropdown = FieldGuideDropdownFrame
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

-- Initializes all frames, level strings, and textures for reuse.
local function initFrames()
    NBR_OF_SPELL_ROWS = math.floor(FieldGuideFrame:GetHeight() / 100) -- Good enough.
    Y_SPACING = math.ceil(FieldGuideFrame:GetHeight() / NBR_OF_SPELL_ROWS) / 1.125
    FieldGuideFrameSlider:SetMinMaxValues(0, 30 - NBR_OF_SPELL_ROWS) -- If we show 5 spell rows, the scroll max value should be 25 (it scrolls to 25th row, and shows the last 5 already).
    local NBR_OF_SPELL_BUTTONS = math.floor((FieldGuideFrame:GetWidth() - BUTTON_X_START * 2) / BUTTON_X_SPACING) * NBR_OF_SPELL_ROWS
    -- Create spell buttons.
    for i = 1, NBR_OF_SPELL_BUTTONS do
        NBR_OF_SPELL_COLUMNS = NBR_OF_SPELL_BUTTONS / NBR_OF_SPELL_ROWS -- The number of buttons in x.
        local spellBtnX = BUTTON_X_START + BUTTON_X_SPACING * ((i - 1) % NBR_OF_SPELL_COLUMNS)
        local spellBtnY = -Y_SPACING * math.ceil(i / NBR_OF_SPELL_COLUMNS) - BUTTON_Y_START
        spellButtons[i] = CreateFrame("BUTTON", nil, FieldGuideFrame, "FieldGuideSpellButtonTemplate")
        spellButtons[i]:SetPoint("TOPLEFT", spellBtnX, spellBtnY)
        spellTextures[i] = spellButtons[i]:CreateTexture(nil, "BORDER")
    end
    -- Create level strings.
    for i = 1, NBR_OF_SPELL_ROWS do
        levelStrings[i] = FieldGuideFrame:CreateFontString(nil, "ARTWORK", "FieldGuideLevelStringTemplate")
        levelStrings[i]:SetPoint("TOPLEFT", LEVEL_STRING_X_START, -LEVEL_STRING_Y_START - Y_SPACING * i)
    end
end

-- Initializes everything.
local function init()
    tinsert(UISpecialFrames, FieldGuideFrame:GetName()) -- Allows us to close the window with escape.
    initFrames()
    initDropdown()
    initCheckboxes()
    initMinimapButton()
    initSlash()
    setBackground(selectedClass)
    updateButtons(true) -- Sets initial textures etc. Without this, everything is empty until we scroll.
end

-- Returns the cost modifier (0.9 if player is honored or rank 3, 0.8 if both, 1 otherwise).
local function getCostModifier()
    local honored = false
    -- local rankThree = UnitPVPRank("player") -- Classic exclusive code.
    if not isAlliance() then
        honored = select(3, GetFactionInfoByID(530)) > 5 or select(3, GetFactionInfoByID(76)) > 5 or select(3, GetFactionInfoByID(81)) > 5 or select(3, GetFactionInfoByID(68)) > 5
    else
        honored = select(3, GetFactionInfoByID(69)) > 5 or select(3, GetFactionInfoByID(54)) > 5 or select(3, GetFactionInfoByID(47)) > 5 or select(3, GetFactionInfoByID(72)) > 5
    end
    return rankThree and honored and 0.8 or honored and 0.9 or rankThree and 0.9 or 1
end

-- Called whenever player mouses over an icon.
function FieldGuideSpellButton_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    local spell = Spell:CreateFromSpellID(self.spellId)
    local modifier = getCostModifier()
    spell:ContinueOnSpellLoad(function()
        local canAfford = GetMoney() < self.spellCost and "|cFFFF0000" or "|cFFFFFFFF" -- Modifies string to be red if player can't afford, white otherwise.
        local priceString = GetCoinTextureString(self.spellCost * modifier)
        GameTooltip:SetHyperlink("spell:" .. self.spellId)
        GameTooltip:AddLine("\nPrice: " .. canAfford .. priceString, nil, nil, nil, nil)
        GameTooltip:Show()
    end)
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

-- Called when the player either scrolls or clicks the up/down buttons manually.
function FieldGuide_Scroll(delta)
    FieldGuideFrameSlider:SetValue(FieldGuideFrameSlider:GetValue() - delta)
end

-- Toggles showing talents on or off Called when the player checks/unchecks the talents checkbox.
function FieldGuide_ToggleTalents()
    FieldGuideOptions.showTalents = not FieldGuideOptions.showTalents
    updateButtons()
end

-- Toggles showing enemy spells on or off. Called when the player checks/unchecks the enemy faction spells checkbox.
function FieldGuide_ToggleEnemySpells()
    FieldGuideOptions.showEnemySpells = not FieldGuideOptions.showEnemySpells
    updateButtons()
end

-- Toggles showing known spells on or off. Called when the player checks/unchecks the known spells checkbox.
function FieldGuide_ToggleKnownSpells()
    FieldGuideOptions.showKnownSpells = not FieldGuideOptions.showKnownSpells
    updateButtons()
end

-- Called when the frame has loaded.
function FieldGuide_OnLoad(self)
    self:RegisterForDrag("LeftButton")
    self:RegisterEvent("ADDON_LOADED")
end

-- Called on each event the frame receives.
function FieldGuide_OnEvent(self, event, ...)
    if event == "ADDON_LOADED" then
        if ... == "FieldGuide" then
            if FieldGuideOptions == nil then -- Defaults.
                FieldGuideOptions = {
                    showTalents = true,
                    showEnemySpells = false,
                    showKnownSpells = true,
                    minimapTable = {} -- Used by LibDBIcon-1.0.
                }
            end
            init()
            self:UnregisterEvent("ADDON_LOADED")
        end
    end
end