--[[
    Features (in no particular order):
    ---------------------------------------
    1. When clicking on weapon skill, show where the trainer is using TomTom.
    2. When clicking on any spell, show where the nearest trainer is using TomTom (maybe give player option to show nearest cheapest trainer or just nearest).
    3. Add icons for tomes/quests at level 60. AQ ones, but also Mage drink quest in DM/Arcane Brilliance and Warlock Shadow Ward rank 4 etc.
    4. (Mark spells that the player does not wish to train and save between sessions. Perhaps make them grey?) - Allow player to import/export these?
    5. (Add Warlock pet skills.)
    6. Fix PvP rank spell cost modification function for Classic release.
    7. (Possibly allow player to drag spells onto bars from the addon.)
    8. (Add racials?)
    9. Add option to change width and height – Ace.
    ---------------------------------------

    Bugs:
    ---------------------------------------
    1. Manually scrolling seems to not keep up.
    2. Scroll bar texture sometimes does not load – maybe FieldGuideFrameVerticalSlider does not load sometimes, or the black background loads after.
    3. Highlighting over scroll up and down buttons is too big.
    4. Ranks do not show in the tooltip (even in Classic) – add manually?
    5. (Cure Disease/Cure Poison for Shamans might be wrong)
    ---------------------------------------
]]

local _, FieldGuide = ...
local pairs, ipairs, select, floor = pairs, ipairs, select, math.floor
local GetFactionInfoByID, IsSpellKnown, GetMoney, GetCoinTextureString = GetFactionInfoByID, IsSpellKnown, GetMoney, GetCoinTextureString

-- Variables.
local faction = UnitFactionGroup("player")
local race = UnitRace("player")
local actualClass = select(2, UnitClass("player"))
local lowestLevel = 52 -- Used for figuring out which row is at the top when hiding entire rows.
local currentMinLevel = 2 -- The current top row to show.
local selectedClass -- The currently selected class.
local emptyLevels = {} -- Holds info on if a row is empty or not.
local CLASS_BACKGROUNDS = {
    WARRIOR = "WarriorArms",
    PALADIN = "PaladinHoly",
    HUNTER = "HunterBeastMastery",
    ROGUE = "RogueAssassination",
    PRIEST = "PriestHoly",
    SHAMAN = "ShamanElementalCombat",
    MAGE = "MageFrost",
    WARLOCK = "WarlockCurses",
    DRUID = "DruidFeralCombat",
    WEAPONS = "MageFrost"
}
local CLASS_COLORS = {
    WARRIOR = "|cFFC79C6E",
    PALADIN = "|cFFF58CBA",
    HUNTER = "|cFFABD473",
    ROGUE = "|cFFFFF569",
    PRIEST = "|cFFFFFFFF",
    SHAMAN = "|cFF0070DE",
    MAGE = "|cFF40C7EB",
    WARLOCK = "|cFF8787ED",
    DRUID = "|cFFFF7D0A",
}
local CLASS_INDECES = {
    ["WARRIOR"] = 1,
    ["PALADIN"] = 2,
    ["HUNTER"] = 3,
    ["ROGUE"] = 4,
    ["PRIEST"] = 5,
    ["SHAMAN"] = 6,
    ["MAGE"] = 7,
    ["WARLOCK"] = 8,
    ["DRUID"] = 9
}
local CLASSES = {
    "Warrior",
    "Paladin",
    "Hunter",
    "Rogue",
    "Priest",
    "Shaman",
    "Mage",
    "Warlock",
    "Druid"
}

-- UI variables.
local levelStrings = {} -- All the level font strings.
local spellButtons = {} -- All the spell frames.
local spellTextures = {} -- All the frames' textures.
local lastVerticalValue = 0 -- For the vertical slider to not update a million times a second.
local lastHorizontalValue = 0 -- For the horizontal slider to not update a million times a second.
local verticalOffset = 0 -- Used exclusively for weapon skills.
local horizontalOffset = 0 -- Used for scrolling horizontally.
local BUTTON_X_START = 38 -- How far to the right the buttons start.
local BUTTON_Y_START = -25 -- How far down the first button is placed.
local BUTTON_X_SPACING = 45 -- The spacing between all buttons in x.
local LEVEL_STRING_X_START = 35 -- How far to the right the level strings are placed.
local LEVEL_STRING_Y_START = -53 -- How far down the first level string is placed.
local Y_SPACING = 0 -- The spacing between all elements in y.
local NBR_OF_SPELL_ROWS = 0
local NBR_OF_SPELL_COLUMNS = 0

-- Returns true if the player is Alliance, false otherwise.
local function isAlliance()
    return faction == "Alliance"
end

-- Returns the cost modifier (0.9 if player is honored or rank 3, 0.8 if both, 1 otherwise).
local function getCostModifier()
    local honored = false
    local rankThree = UnitPVPRank("player") > 7
    if isAlliance() then
        honored = select(3, GetFactionInfoByID(72)) > 5 or select(3, GetFactionInfoByID(69)) > 5 or select(3, GetFactionInfoByID(47)) > 5 or select(3, GetFactionInfoByID(54)) > 5
    else
        honored = select(3, GetFactionInfoByID(68)) > 5 or select(3, GetFactionInfoByID(76)) > 5 or select(3, GetFactionInfoByID(81)) > 5 or select(3, GetFactionInfoByID(530)) > 5
    end
    return rankThree and honored and 0.8 or (honored or rankThree) and 0.9 or 1
end

-- Shows/hides the frame.
local function toggleFrame()
    if FieldGuideFrame:IsVisible() then
        FieldGuideFrame:Hide()
    else
        FieldGuideFrame:Show()
    end
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
        msg = msg:lower()
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
    FieldGuideFrameKnownSpellsCheckBoxText:SetFont("Fonts/FRIZQT__.TTF", 12, "OUTLINE")
    FieldGuideFrameKnownSpellsCheckBoxText:SetTextColor(1, 1, 1, 1)
    FieldGuideFrameKnownSpellsCheckBoxText:SetText("Known spells")
    FieldGuideFrameKnownSpellsCheckBox:SetPoint("RIGHT", FieldGuideDropdownFrame, "LEFT", 10 - FieldGuideFrameKnownSpellsCheckBoxText:GetWidth(), 2)
    -- Show enemy faction spells checkbox.
    FieldGuideFrameTalentsCheckBoxText:SetFont("Fonts/FRIZQT__.TTF", 12, "OUTLINE")
    FieldGuideFrameTalentsCheckBoxText:SetTextColor(1, 1, 1, 1)
    FieldGuideFrameTalentsCheckBoxText:SetText("Talents")
    FieldGuideFrameTalentsCheckBox:SetPoint("RIGHT", FieldGuideFrameKnownSpellsCheckBox, "LEFT", -FieldGuideFrameTalentsCheckBoxText:GetWidth(), 0)
    -- Show known spells checkbox.
    FieldGuideFrameEnemySpellsCheckBoxText:SetFont("Fonts/FRIZQT__.TTF", 12, "OUTLINE")
    FieldGuideFrameEnemySpellsCheckBoxText:SetTextColor(1, 1, 1, 1)
    FieldGuideFrameEnemySpellsCheckBoxText:SetText((actualClass ~= "PRIEST" and (isAlliance() and "Horde" or "Alliance") or ("Non-" .. race)) .. " spells")
    FieldGuideFrameEnemySpellsCheckBox:SetPoint("RIGHT", FieldGuideFrameTalentsCheckBox, "LEFT", -FieldGuideFrameEnemySpellsCheckBoxText:GetWidth(), 0)
    -- Set checked or not checked.
    FieldGuideFrameTalentsCheckBox:SetChecked(FieldGuideOptions.showTalents)
    FieldGuideFrameEnemySpellsCheckBox:SetChecked(FieldGuideOptions.showEnemySpells)
    FieldGuideFrameKnownSpellsCheckBox:SetChecked(FieldGuideOptions.showKnownSpells)
end

-- Updates the given frame with the given texture and info.
local function updateFrame(texture, frame, info)
    texture:SetTexture(info.texture)
    texture:SetAllPoints()
    frame:Hide() -- So that tooltip updates when scrolling.
    frame.talent = info.talent
    frame.spellId = info.id
    frame.spellCost = info.cost
    frame:Show()
end

-- Hides all empty buttons between the given frameCounter and shownCounter.
local function hideExtraFrames(frameCounter, shownCounter)
    for i = frameCounter, frameCounter + NBR_OF_SPELL_COLUMNS - shownCounter - 1 do -- Hide all unnecessary buttons.
        spellButtons[i]:Hide()
        frameCounter = frameCounter + 1
    end
    return frameCounter
end

-- Updates all the buttons in the frame if weapons are selected.
local function updateWeapons()
    local frameCounter = 1
    for row = 1, NBR_OF_SPELL_ROWS do
        local hiddenCounter = 0
        local shownCounter = 0
        levelStrings[row]:SetText(CLASS_COLORS[CLASSES[row + verticalOffset]:upper()] .. CLASSES[row + verticalOffset])
        for col = 1, #FieldGuide.WEAPONS[row + verticalOffset] do
            if not FieldGuide.WEAPONS[row + verticalOffset][col].hidden then
                if col - hiddenCounter >= horizontalOffset + 1 and col - hiddenCounter <= NBR_OF_SPELL_COLUMNS + horizontalOffset then
                    updateFrame(spellTextures[frameCounter], spellButtons[frameCounter], FieldGuide.WEAPONS[row + verticalOffset][col])
                    frameCounter = frameCounter + 1
                    shownCounter = shownCounter + 1
                end
            else
                hiddenCounter = hiddenCounter + 1
            end
        end
        frameCounter = hideExtraFrames(frameCounter, shownCounter)
    end
end

-- Sets the horizontal slider's max value to the given value.
local function setHorizontalSliderMaxValue(value)
    if value - NBR_OF_SPELL_COLUMNS <= 0 then
        FieldGuideFrameHorizontalSlider:SetMinMaxValues(0, 0)
        FieldGuideFrameHorizontalSliderScrollRightButton:Disable()
    else
        FieldGuideFrameHorizontalSlider:SetMinMaxValues(0, value - NBR_OF_SPELL_COLUMNS)
        FieldGuideFrameHorizontalSliderScrollRightButton:Enable()
    end
end

-- Iterates all weapon skills for the current class and shows/hides any known ones.
local function hideUnwantedWeapons()
    local maxValue = 0
    for index, class in ipairs(CLASSES) do
        local nbrOfSpells = 0
        for weaponIndex, weaponInfo in ipairs(FieldGuide.WEAPONS[CLASS_INDECES[class:upper()]]) do
            if class == actualClass then
                if not FieldGuideOptions.showKnownSpells and IsSpellKnown(weaponInfo.id) then
                    weaponInfo.hidden = true
                else
                    weaponInfo.hidden = false
                end
            end
            nbrOfSpells = not weaponInfo.hidden and nbrOfSpells + 1 or nbrOfSpells
        end
        maxValue = nbrOfSpells > maxValue and nbrOfSpells or maxValue
    end
    setHorizontalSliderMaxValue(maxValue)
end

-- Updates all the buttons in the frame.
local function updateButtons()
    local frameCounter = 1
    local currentLevel = currentMinLevel
    for row = 1, NBR_OF_SPELL_ROWS do
        local hiddenCounter = 0
        local shownCounter = 0
        while emptyLevels[currentLevel] do
        currentLevel = currentLevel + 2
    end
        levelStrings[row]:SetText(currentLevel ~= 2 and "Level " .. currentLevel or "Level 1")
        for spellIndex, spellInfo in ipairs(FieldGuide[selectedClass][currentLevel]) do
            if not spellInfo.hidden then
                if spellIndex - hiddenCounter >= horizontalOffset + 1 and spellIndex - hiddenCounter <= NBR_OF_SPELL_COLUMNS + horizontalOffset then
                    updateFrame(spellTextures[frameCounter], spellButtons[frameCounter], spellInfo)
                    shownCounter = shownCounter + 1
                    frameCounter = frameCounter + 1
                end
            else
                hiddenCounter = hiddenCounter + 1
            end
        end
        frameCounter = hideExtraFrames(frameCounter, shownCounter)
        currentLevel = currentLevel + 2
    end
end

-- Hides all unwanted spells (known spells/talents/opposite faction spells). Also adjusts the horizontal slider appropriately.
local function hideUnwantedSpells()
    local maxSpellIndex = 0
    local currentSpellIndex = 0
    local nbrOfHiddenRows = 0
    lowestLevel = 52
    for level = 2, 60, 2 do
        local hiddenCounter = 0
        for spellIndex, spellInfo in ipairs(FieldGuide[selectedClass][level]) do
            if not FieldGuideOptions.showKnownSpells and IsSpellKnown(spellInfo.id) then
                spellInfo.hidden = true
            elseif not FieldGuideOptions.showEnemySpells and (isAlliance() and spellInfo.faction == 2 or (not isAlliance() and spellInfo.faction == 1)) then
                spellInfo.hidden = true
            elseif actualClass == "PRIEST" and selectedClass == "PRIEST" and spellInfo.race and not FieldGuideOptions.showEnemySpells and not string.find(spellInfo.race, race) then
                spellInfo.hidden = true
            elseif not FieldGuideOptions.showTalents and spellInfo.talent then
                spellInfo.hidden = true
            else
                spellInfo.hidden = false
            end
            if spellInfo.hidden then
                hiddenCounter = hiddenCounter + 1
            elseif spellIndex - hiddenCounter > maxSpellIndex then
                maxSpellIndex = spellIndex - hiddenCounter
            end
            currentSpellIndex = spellIndex
        end
        if currentSpellIndex - hiddenCounter == 0 then -- This means all buttons on the row are hidden, so we should hide the entire row.
            emptyLevels[level] = true -- Hide current level if all buttons are empty.
            nbrOfHiddenRows = nbrOfHiddenRows + 1
        else
            if level < lowestLevel then
                lowestLevel = level
            end
            emptyLevels[level] = false
        end
    end
    setHorizontalSliderMaxValue(maxSpellIndex)
    FieldGuideFrameVerticalSlider:SetMinMaxValues(0, 30 - NBR_OF_SPELL_ROWS - nbrOfHiddenRows)
end

-- Sets the background to the given class. Class must be a capitalized string.
local function setBackground(class)
    FieldGuideFrameBackgroundTextureClass:SetTexture("Interface/TALENTFRAME/" .. CLASS_BACKGROUNDS[class] .. "-TopLeft")
    FieldGuideFrameBackgroundTextureClass:SetAlpha(0.4)
end

-- Resets the scroll bar to top left position.
local function resetScroll()
    FieldGuideFrameVerticalSlider:SetValue(0)
    FieldGuideFrameVerticalSliderScrollUpButton:Disable()
    FieldGuideFrameHorizontalSlider:SetValue(0)
    FieldGuideFrameHorizontalSliderScrollLeftButton:Disable()
end

-- Changes the class to the given class.
local function setClass(dropdownButton, class)
    UIDropDownMenu_SetSelectedID(FieldGuideDropdownFrame, dropdownButton:GetID())
    selectedClass = class
    if class ~= "WEAPONS" then
        setBackground(selectedClass)
        if class == "PRIEST" and actualClass == "PRIEST" then
            FieldGuideFrameEnemySpellsCheckBoxText:SetText("Non-" .. race .. " spells")
            FieldGuideFrameEnemySpellsCheckBox:Show()
            FieldGuideFrameEnemySpellsCheckBox:SetPoint("RIGHT", FieldGuideFrameTalentsCheckBox, "LEFT", -FieldGuideFrameEnemySpellsCheckBoxText:GetWidth(), 0)
        elseif class == "MAGE" or class == "PRIEST" then
            FieldGuideFrameEnemySpellsCheckBoxText:SetText((isAlliance() and "Horde" or "Alliance") .. " spells")
            FieldGuideFrameEnemySpellsCheckBox:Show()
            FieldGuideFrameEnemySpellsCheckBox:SetPoint("RIGHT", FieldGuideFrameTalentsCheckBox, "LEFT", -FieldGuideFrameEnemySpellsCheckBoxText:GetWidth(), 0)
        else
            FieldGuideFrameEnemySpellsCheckBox:Hide()
        end
        FieldGuideFrameTalentsCheckBox:Show()
        hideUnwantedSpells()
        currentMinLevel = lowestLevel
        updateButtons()
    else
        setBackground(actualClass)
        FieldGuideFrameTalentsCheckBox:Hide()
        FieldGuideFrameEnemySpellsCheckBox:Hide()
        FieldGuideFrameVerticalSlider:SetMinMaxValues(0, 9 - NBR_OF_SPELL_ROWS)
        hideUnwantedWeapons()
        updateWeapons()
    end
    resetScroll()
end

-- Returns true if the given class is currently selected in the dropdown list.
local function isSelected(class)
    return selectedClass == class
end

-- Initializes the dropdown menu.
local function initDropdown()
    local dropdown = FieldGuideDropdownFrame
    UIDropDownMenu_Initialize(dropdown, function(self)
        local info = UIDropDownMenu_CreateInfo()
        -- Warrior.
        info.text = "Warrior"
        info.colorCode = CLASS_COLORS.WARRIOR
        info.arg1 = "WARRIOR"
        info.checked = isSelected("WARRIOR")
        info.func = setClass
        UIDropDownMenu_AddButton(info)
        -- Paladin.
        info.text = "Paladin"
        info.colorCode = CLASS_COLORS.PALADIN
        info.arg1 = "PALADIN"
        info.checked = isSelected("PALADIN")
        UIDropDownMenu_AddButton(info)
        -- Hunter.
        info.text = "Hunter"
        info.colorCode = CLASS_COLORS.HUNTER
        info.arg1 = "HUNTER"
        info.checked = isSelected("HUNTER")
        UIDropDownMenu_AddButton(info)
        -- Rogue.
        info.text = "Rogue"
        info.colorCode = CLASS_COLORS.ROGUE
        info.arg1 = "ROGUE"
        info.checked = isSelected("ROGUE")
        UIDropDownMenu_AddButton(info)
        -- Priest.
        info.text = "Priest"
        info.colorCode = CLASS_COLORS.PRIEST
        info.arg1 = "PRIEST"
        info.checked = isSelected("PRIEST")
        UIDropDownMenu_AddButton(info)
        -- Shaman.
        info.text = "Shaman"
        info.colorCode = CLASS_COLORS.SHAMAN
        info.arg1 = "SHAMAN"
        info.checked = isSelected("SHAMAN")
        UIDropDownMenu_AddButton(info)
        -- Mage.
        info.text = "Mage"
        info.colorCode = CLASS_COLORS.MAGE
        info.checked = isSelected("MAGE")
        info.arg1 = "MAGE"
        UIDropDownMenu_AddButton(info)
        -- Warlock.
        info.text = "Warlock"
        info.colorCode = CLASS_COLORS.WARLOCK
        info.arg1 = "WARLOCK"
        info.checked = isSelected("WARLOCK")
        UIDropDownMenu_AddButton(info)
        -- Druid.
        info.text = "Druid"
        info.colorCode = CLASS_COLORS.DRUID
        info.arg1 = "DRUID"
        info.checked = isSelected("DRUID")
        UIDropDownMenu_AddButton(info)
        -- Weapon skills.
        info.text = "Weapons"
        info.colorCode = "|cFFDFDFDF"
        info.arg1 = "WEAPONS"
        info.checked = isSelected("WEAPONS")
        UIDropDownMenu_AddButton(info)
    end)
    UIDropDownMenu_SetWidth(dropdown, 100);
    UIDropDownMenu_SetButtonWidth(dropdown, 124)
    UIDropDownMenu_JustifyText(dropdown, "RIGHT")
    UIDropDownMenu_SetText(dropdown, "|c" .. RAID_CLASS_COLORS[selectedClass].colorStr .. selectedClass:sub(1, 1) .. selectedClass:sub(2):lower())
end

-- Initializes all frames, level strings, and textures for reuse.
local function initFrames()
    NBR_OF_SPELL_ROWS = floor(FieldGuideFrame:GetHeight() / 100)
    Y_SPACING = math.ceil(FieldGuideFrame:GetHeight() / NBR_OF_SPELL_ROWS) / 1.185
    local nbrOfSpellBtns = floor((FieldGuideFrame:GetWidth() - BUTTON_X_START * 2) / BUTTON_X_SPACING) * NBR_OF_SPELL_ROWS
    NBR_OF_SPELL_COLUMNS = nbrOfSpellBtns / NBR_OF_SPELL_ROWS -- The number of buttons in x.
    -- Create spell buttons.
    for frameIndex = 1, nbrOfSpellBtns do
        local spellBtnX = BUTTON_X_START + BUTTON_X_SPACING * ((frameIndex - 1) % NBR_OF_SPELL_COLUMNS)
        local spellBtnY = -Y_SPACING * math.ceil(frameIndex / NBR_OF_SPELL_COLUMNS) - BUTTON_Y_START
        spellButtons[frameIndex] = CreateFrame("BUTTON", nil, FieldGuideFrame, "FieldGuideSpellButtonTemplate")
        spellButtons[frameIndex]:SetPoint("TOPLEFT", spellBtnX, spellBtnY)
        spellTextures[frameIndex] = spellButtons[frameIndex]:CreateTexture(nil, "BORDER")
    end
    -- Create level strings.
    for stringIndex = 1, NBR_OF_SPELL_ROWS do
        levelStrings[stringIndex] = FieldGuideFrame:CreateFontString(nil, "ARTWORK", "FieldGuideLevelStringTemplate")
        levelStrings[stringIndex]:SetPoint("TOPLEFT", LEVEL_STRING_X_START, -LEVEL_STRING_Y_START - Y_SPACING * stringIndex)
    end
end

-- Initializes everything.
local function init()
    tinsert(UISpecialFrames, FieldGuideFrame:GetName()) -- Allows us to close the window with escape.
    initFrames()
    selectedClass = actualClass
    setBackground(selectedClass)
    FieldGuide_ToggleButtons() -- Need to call this, or spells won't be hidden regardless of saved variables.
    resetScroll()
    initDropdown()
    initCheckboxes()
    initMinimapButton()
    initSlash()
    FieldGuideFrameVerticalSlider:SetMinMaxValues(0, 30 - NBR_OF_SPELL_ROWS) -- If we show 5 spell rows, the scroll max value should be 25 (it scrolls to 25th row, and shows the last 5 already).
    FieldGuideFrameVerticalSlider:SetValue(1)
    FieldGuideFrameVerticalSlider:SetValue(0)
    FieldGuideFrameVerticalSlider:SetEnabled(false)
    FieldGuideFrameHorizontalSlider:SetEnabled(false)
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
        GameTooltip:AddLine(" ")
        if self.talent then
            GameTooltip:AddLine("Talent")
        end
        GameTooltip:AddLine("Price: " .. canAfford .. priceString)
        GameTooltip:Show()
    end)
end

-- Is called whenever the value of the vertical slider changes.
function FieldGuide_OnVerticalValueChanged(self, value)
    verticalOffset = value
    if value ~= 0 then
        currentMinLevel = currentMinLevel + (value - lastVerticalValue) * 2
        while emptyLevels[currentMinLevel] do
            currentMinLevel = value - lastVerticalValue > 0 and currentMinLevel + 2 or currentMinLevel - 2
        end
        currentMinLevel = currentMinLevel < lowestLevel and lowestLevel or currentMinLevel > 52 and 52 or currentMinLevel
    else
        currentMinLevel = lowestLevel
    end
    lastVerticalValue = value
    self:SetValue(value)
    if selectedClass ~= "WEAPONS" then
        updateButtons()
    else
        updateWeapons()
    end
    if value < 1 then
        _G[self:GetName() .. "ScrollUpButton"]:Disable()
        _G[self:GetName() .. "ScrollDownButton"]:Enable()
    elseif value >= select(2, self:GetMinMaxValues()) then
        _G[self:GetName() .. "ScrollDownButton"]:Disable()
        _G[self:GetName() .. "ScrollUpButton"]:Enable()
    else
        _G[self:GetName() .. "ScrollUpButton"]:Enable()
        _G[self:GetName() .. "ScrollDownButton"]:Enable()
    end
end

-- Is called whenever the value of the horizontal slider changes.
function FieldGuide_OnHorizontalValueChanged(self, value)
    lastHorizontalValue = value
    self:SetValue(value)
    horizontalOffset = value
    if selectedClass ~= "WEAPONS" then
        updateButtons()
    else
        updateWeapons()
    end
    if value < 1 then
        _G[self:GetName() .. "ScrollLeftButton"]:Disable()
        _G[self:GetName() .. "ScrollRightButton"]:Enable()
    elseif value >= select(2, self:GetMinMaxValues()) then
        _G[self:GetName() .. "ScrollRightButton"]:Disable()
        _G[self:GetName() .. "ScrollLeftButton"]:Enable()
    else
        _G[self:GetName() .. "ScrollLeftButton"]:Enable()
        _G[self:GetName() .. "ScrollRightButton"]:Enable()
    end
end

-- Called whenever the player scrolls.
function FieldGuide_Scroll(delta, horizontal)
    if not IsShiftKeyDown() and not horizontal then
        FieldGuideFrameVerticalSlider:SetValue(FieldGuideFrameVerticalSlider:GetValue() - delta)
    else
        FieldGuideFrameHorizontalSlider:SetValue(FieldGuideFrameHorizontalSlider:GetValue() - delta)
    end
end

-- Shows or hides the talents (type == 1), enemy spells (type == 2), or known spells (type == 3).
function FieldGuide_ToggleButtons(type)
    if type == 3 then -- Known spells.
        FieldGuideOptions.showKnownSpells = not FieldGuideOptions.showKnownSpells
    elseif type == 2 then -- Enemy spells.
        FieldGuideOptions.showEnemySpells = not FieldGuideOptions.showEnemySpells
    elseif type == 1 then -- Talents.
        FieldGuideOptions.showTalents = not FieldGuideOptions.showTalents
    end
    if selectedClass ~= "WEAPONS" then
        hideUnwantedSpells()
        currentMinLevel = lowestLevel
        resetScroll()
        updateButtons()
    else
        hideUnwantedWeapons()
        resetScroll()
        updateWeapons()
    end
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
                    minimapTable = {}
                }
            end
            init()
            self:UnregisterEvent("ADDON_LOADED")
        end
    end
end