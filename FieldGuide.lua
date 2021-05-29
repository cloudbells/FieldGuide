local _, FieldGuide = ...

local pairs, ipairs, select, floor = pairs, ipairs, select, math.floor
local GetFactionInfoByID, IsSpellKnown, GetMoney, GetCoinTextureString = GetFactionInfoByID, IsSpellKnown, GetMoney, GetCoinTextureString
local hbd = LibStub("HereBeDragons-2.0")
local hbdp = LibStub("HereBeDragons-Pins-2.0")
local minimapIcon = LibStub("LibDBIcon-1.0")
local libDD = LibStub("LibUIDropDownMenu-4.0")

-- Variables.
local tomtom = nil
local faction = UnitFactionGroup("player")
local race = UnitRace("player")
local actualClass = select(2, UnitClass("player"))
local lowestLevel = 52 -- Used for figuring out which row is at the top when hiding entire rows.
local currentMinLevel = 2 -- The current top row to show.
local selectedClass -- The currently selected class.
local emptyLevels = {} -- Holds info on if a row is empty or not.
local CLASS_BACKGROUNDS = {
    WARRIOR = "WarriorArms",
    PALADIN = "PaladinCombat",
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
    ["WARRIOR"] = "|cFFC79C6E",
    ["PALADIN"] = "|cFFF58CBA",
    ["HUNTER"] = "|cFFABD473",
    ["ROGUE"] = "|cFFFFF569",
    ["PRIEST"] = "|cFFFFFFFF",
    ["SHAMAN"] = "|cFF0070DE",
    ["MAGE"] = "|cFF40C7EB",
    ["WARLOCK"] = "|cFF8787ED",
    ["DRUID"] = "|cFFFF7D0A",
    ["WEAPONS"] = "|cFFDFDFDF"
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
local lastVerticalValue = 0 -- For the vertical slider to not update a million times a second.
local lastHorizontalValue = 0 -- For the horizontal slider to not update a million times a second.
local verticalOffset = 0 -- Used exclusively for weapon skills.
local horizontalOffset = 0 -- Used for scrolling horizontally.
local BUTTON_X_START = 33 -- How far to the right the buttons start.
local BUTTON_Y_START = -25 -- How far down the first button is placed.
local BUTTON_X_SPACING = 45 -- The spacing between all buttons in x.
local LEVEL_STRING_X_START = 30 -- How far to the right the level strings are placed.
local LEVEL_STRING_Y_START = -53 -- How far down the first level string is placed.
local Y_SPACING = 0 -- The spacing between all elements in y.
local NBR_OF_SPELL_ROWS = 0
local NBR_OF_SPELL_COLUMNS = 0

-- Returns the distance to the given location from the player's location.
local function getDistance(x, y, map)
    local playerX, playerY, instance = hbd:GetPlayerWorldPosition()
    local destX, destY = hbd:GetWorldCoordinatesFromZone(x, y, map)
    return hbd:GetWorldDistance(instance, playerX, playerY, destX, destY)
end

-- Returns the portal trainer for the given portal (spell).
local function findPortalTrainer(spell)
    local trainer = FieldGuide.PORTAL_TRAINERS[spell.spellId]
    trainer.x = trainer.x / 100
    trainer.y = trainer.y / 100
    return trainer
end

-- Returns the closest trainer for the given skill.
local function findClosestTrainer(skill)
    local tempFaction = faction == "Horde" and selectedClass == "PALADIN" and "ALLIANCE" or faction == "Alliance" and selectedClass == "SHAMAN" and "HORDE" or faction:upper()
    local backupTrainer = nil -- For if there is no trainer on the same continent as the player.
    local sameContinentTrainer = nil
    local shortestDistance = 100000 -- For if there is no trainer on the same continent as the player.
    local sameContinentDistance = 100000
    local instance = select(3, hbd:GetPlayerWorldPosition())
    local conditional = nil
    local trainerTable = nil
    for _, trainer in ipairs((selectedClass == "WEAPONS" and FieldGuide.WEAPON_TRAINERS[tempFaction])
            or (selectedClass == "HUNTER_PETS" and FieldGuide.HUNTER_PET_TRAINERS[tempFaction])
            or (selectedClass == "WARLOCK_PETS" and FieldGuide.WARLOCK_PET_TRAINERS[tempFaction])
            or FieldGuide.SPELL_TRAINERS[selectedClass][tempFaction]) do
        if selectedClass == "WARLOCK_PETS" and trainer[skill.name]
                or selectedClass == "WEAPONS" and trainer[skill.spellId]
                or selectedClass ~= "WARLOCK_PETS" and skill.level ~= nil and not (skill.level > 6 and trainer.noob) then
            local distance = getDistance(trainer.x / 100, trainer.y / 100, trainer.map)
            if distance == nil then -- Most likely means player is inside an instance.
                return nil
            end
            if FieldGuide.getContinent(trainer.map) == instance and distance < sameContinentDistance then
                sameContinentDistance = distance
                sameContinentTrainer = FieldGuide.copy(trainer)
            elseif distance < shortestDistance then
                shortestDistance = distance
                backupTrainer = FieldGuide.copy(trainer)
            end
        end
    end
    backupTrainer = sameContinentTrainer ~= nil and sameContinentTrainer or backupTrainer
    backupTrainer.x = backupTrainer.x / 100
    backupTrainer.y = backupTrainer.y / 100
    return backupTrainer
end

-- Checks if the pin exists as a frame and as a saved variable.
-- Returns true if it does exist, then the frames, and then the variables.
local function doesPinExist(name)
    local variable = nil
    local world = nil
    local minimap = nil
    for _, pin in pairs(FieldGuide.pinPool) do
        if pin.name == name then
            world = pin.world and pin or world
            minimap = pin.minimap and pin or minimap
        end
    end
    for k, pin in pairs(FieldGuideOptions.pins) do
        if pin.name == name then
            variable = k
        end
    end
    return variable ~= nil, world, minimap, variable
end

-- Adds a pin to the world map with the given mapId, x, y, and name.
local function addMapPin(map, x, y, name)
    local mapName = hbd:GetLocalizedMap(map)
    local coordString = string.format("%.2f, %.2f", x * 100, y * 100)
    if tomtom then
        tomtom:AddWaypoint(map, x, y, {title = name, from = "Field Guide"})
    else
        local world = FieldGuide:getPin()
        local minimap = FieldGuide:getPin()
        world.map = map
        world.x = x
        world.y = y
        world.name = name
        world.mapName = mapName
        world.coordString = coordString
        world.world = true
        world.instance = FieldGuide.getContinent(map)
        minimap.map = map
        minimap.x = x
        minimap.y = y
        minimap.name = name
        minimap.mapName = mapName
        minimap.coordString = coordString
        minimap.minimap = true
        minimap.instance = FieldGuide.getContinent(map)
        hbdp:AddMinimapIconMap("FieldGuideFrame", minimap, map, x, y, true)
        hbdp:AddWorldMapIconMap("FieldGuideFrame", world, map, x, y, 3)
    end
end

-- Removes the given pin from the world map.
local function removeMapPin(pin)
    local _, world, minimap, variable = doesPinExist(pin.name)
    hbdp:RemoveMinimapIcon("FieldGuideFrame", minimap)
    hbdp:RemoveWorldMapIcon("FieldGuideFrame", world)
    FieldGuideOptions.pins[variable] = nil
end

-- Returns true if the player is Alliance, false otherwise.
local function isAlliance()
    return faction == "Alliance"
end

-- Returns the cost modifier (0.9 if player is honored or rank 3, 0.8 if both, 1 otherwise).
local function getCostModifier()
    local honored = false
    local rankThree = UnitPVPRank("player") > 6
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
        minimapIcon:Hide("FieldGuide")
        print("|cFFFFFF00Field Guide:|r Minimap button hidden. Type /fg minimap to show it again.")
    else
        minimapIcon:Show("FieldGuide")
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
        elseif msg == "help" then
            print("|cFFFFFF00Field Guide:|r\n"
                    .. "/fg or /fieldguide both work to toggle the addon.\n"
                    .. "/fg minimap toggles the minimap button.\n"
                    .. "Scroll horizontally by holding Shift and scrolling.\n"
                    .. "Left click a spell to mark the trainer for that spell on your map.\n"
                    .. "Right click a spell to mark it as unwanted.\n"
                    .. "Shift-right click a spell to mark all ranks of that spell as unwanted.\n"
                    .. "You can drag any spell onto an action bar from the addon.")
            return
        end
        toggleFrame()
    end
end

-- Initializes the minimap button.
local function initMinimapButton()
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
    minimapIcon:Register("FieldGuide", obj, FieldGuideOptions.minimapTable)
end

-- Initializes all checkboxes.
local function initCheckboxes()
    -- Show talents checkbox.
    FieldGuideFrameKnownSpellsCheckBoxText:SetFont("Fonts/FRIZQT__.TTF", 12, "OUTLINE")
    FieldGuideFrameKnownSpellsCheckBoxText:SetTextColor(1, 1, 1, 1)
    FieldGuideFrameKnownSpellsCheckBoxText:SetText("Known spells")
    FieldGuideFrameKnownSpellsCheckBox:SetPoint("RIGHT", FieldGuideDropdownFrame, "LEFT", 10 - FieldGuideFrameKnownSpellsCheckBoxText:GetWidth() - 5, 2)
    -- Show enemy faction spells checkbox.
    FieldGuideFrameTalentsCheckBoxText:SetFont("Fonts/FRIZQT__.TTF", 12, "OUTLINE")
    FieldGuideFrameTalentsCheckBoxText:SetTextColor(1, 1, 1, 1)
    FieldGuideFrameTalentsCheckBoxText:SetText("Talents")
    FieldGuideFrameTalentsCheckBox:SetPoint("RIGHT", FieldGuideFrameKnownSpellsCheckBox, "LEFT", -FieldGuideFrameTalentsCheckBoxText:GetWidth() - 5, 0)
    -- Show known spells checkbox.
    FieldGuideFrameEnemySpellsCheckBoxText:SetFont("Fonts/FRIZQT__.TTF", 12, "OUTLINE")
    FieldGuideFrameEnemySpellsCheckBoxText:SetTextColor(1, 1, 1, 1)
    FieldGuideFrameEnemySpellsCheckBoxText:SetText((actualClass ~= "PRIEST" and (isAlliance() and "Horde" or "Alliance") or ("Non-" .. race)) .. " spells")
    FieldGuideFrameEnemySpellsCheckBox:SetPoint("RIGHT", FieldGuideFrameTalentsCheckBox, "LEFT", -FieldGuideFrameEnemySpellsCheckBoxText:GetWidth() - 5, 0)
    -- Set checked or not checked.
    FieldGuideFrameTalentsCheckBox:SetChecked(FieldGuideOptions.showTalents)
    FieldGuideFrameEnemySpellsCheckBox:SetChecked(FieldGuideOptions.showEnemySpells)
    FieldGuideFrameKnownSpellsCheckBox:SetChecked(FieldGuideOptions.showKnownSpells)
end

-- Updates the given frame with the given texture and info.
local function updateFrame(texture, frame, info, level)
    texture:SetTexture(info.texture)
    texture:SetAllPoints()
    if FieldGuideOptions.unwantedSpells[info.id] then
        texture:SetVertexColor(1, 0, 0, 1)
    else
        texture:SetVertexColor(1, 1, 1)
    end
    frame:Hide() -- So that tooltip updates when scrolling.
    frame.name = info.name
    frame.rank = info.rank
    frame.talent = info.talent
    frame.spellId = info.id
    frame.spellCost = info.cost
    frame.level = level
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
    for row = 1, NBR_OF_SPELL_ROWS do -- For all rows currently in view.
        local hiddenCounter = 0
        local shownCounter = 0
        levelStrings[row]:SetText(CLASS_COLORS[CLASSES[row + verticalOffset]:upper()] .. CLASSES[row + verticalOffset])
        for col = 1, #FieldGuide.WEAPONS[row + verticalOffset] do -- For all columns currently in view.
            if not FieldGuide.WEAPONS[row + verticalOffset][col].hidden then -- If the column (skill) is supposed to be not hidden.
                if col - hiddenCounter >= horizontalOffset + 1 and col - hiddenCounter <= NBR_OF_SPELL_COLUMNS + horizontalOffset then
                    updateFrame(spellButtons[frameCounter].texture, spellButtons[frameCounter], FieldGuide.WEAPONS[row + verticalOffset][col])
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
    for weaponIndex, weaponInfo in ipairs(FieldGuide.WEAPONS[CLASS_INDECES[actualClass]]) do
        if not FieldGuideOptions.showKnownSpells and FieldGuide.isWeaponKnown(weaponInfo.name) then
            weaponInfo.hidden = true
        else
            weaponInfo.hidden = false
        end
    end
    for i = 1, 9, 1 do -- Iterate through each class and count the maximum number of spells being shown.
        local currentMax = 0
        for weaponIndex, weaponInfo in ipairs(FieldGuide.WEAPONS[i]) do
            if not weaponInfo.hidden then
                currentMax = currentMax + 1
            end
        end
        if currentMax > maxValue then
            maxValue = currentMax
        end
    end
    setHorizontalSliderMaxValue(maxValue)
end

-- Updates all the buttons in the frame.
local function updateButtons()
    local frameCounter = 1
    local currentLevel = currentMinLevel
    for row = 1, NBR_OF_SPELL_ROWS do
        if currentLevel >= 62 then
            -- Hide all hidden rows.
            for i = NBR_OF_SPELL_COLUMNS * row - NBR_OF_SPELL_COLUMNS + 1, #spellButtons do
                spellButtons[i]:Hide()
            end
            for i = row, NBR_OF_SPELL_ROWS do
                levelStrings[i]:SetText("")
            end
            break
        end
        local hiddenCounter = 0
        local shownCounter = 0
        while currentLevel < 60 and emptyLevels[currentLevel] do
            currentLevel = currentLevel + 2
        end
        levelStrings[row]:SetText(currentLevel ~= 2 and "Level " .. currentLevel or "Level 1")
        for spellIndex, spellInfo in ipairs(FieldGuide[selectedClass][currentLevel]) do
            if not spellInfo.hidden then
                if spellIndex - hiddenCounter >= horizontalOffset + 1 and spellIndex - hiddenCounter <= NBR_OF_SPELL_COLUMNS + horizontalOffset then
                    updateFrame(spellButtons[frameCounter].texture, spellButtons[frameCounter], spellInfo, currentLevel)
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
    local knownSpells = {}
    local maxSpellIndex = 0
    local currentSpellIndex = 0
    local nbrOfHiddenRows = 0
    lowestLevel = 52
    for level = 60, 2, -2 do
        local hiddenCounter = 0
        for spellIndex, spellInfo in ipairs(FieldGuide[selectedClass][level]) do
            -- Fix for spells that overwrite older ranks (Heroic Strike, Sinister Strike etc.)
            if selectedClass == actualClass and IsPlayerSpell(spellInfo.id) then
                knownSpells[spellInfo.name] = true
            end
            if spellInfo.empty then
                spellInfo.hidden = true
            -- Known spells.
            elseif not FieldGuideOptions.showKnownSpells and ((selectedClass == "HUNTER_PETS" or selectedClass == "WARLOCK_PETS") and IsSpellKnown(spellInfo.id, true) or knownSpells[spellInfo.name]) then
                spellInfo.hidden = true
            -- Enemy spells.
            elseif not FieldGuideOptions.showEnemySpells and (isAlliance() and spellInfo.faction == 2 or (not isAlliance() and spellInfo.faction == 1)) then
                spellInfo.hidden = true
            -- Other Priest races' spells.
            elseif actualClass == "PRIEST" and selectedClass == "PRIEST" and spellInfo.race and not FieldGuideOptions.showEnemySpells and not spellInfo.race:find(race) then
                spellInfo.hidden = true
            -- Talents.
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
    if 30 - NBR_OF_SPELL_ROWS - nbrOfHiddenRows <= 0 then
        FieldGuideFrameVerticalSlider:SetMinMaxValues(0, 0)
        FieldGuideFrameVerticalSliderScrollDownButton:Disable()
    else
        FieldGuideFrameVerticalSlider:SetMinMaxValues(0, 30 - NBR_OF_SPELL_ROWS - nbrOfHiddenRows)
        FieldGuideFrameVerticalSliderScrollDownButton:Enable()
    end
end

-- Sets the background to the given class. Class must be a capitalized string.
local function setBackground(class)
    class = class == "WARLOCK_PETS" and "WARLOCK" or class == "HUNTER_PETS" and "HUNTER" or class
    FieldGuideFrameBackgroundTextureClass:SetTexture("Interface/TALENTFRAME/" .. CLASS_BACKGROUNDS[class] .. "-TopLeft")
    FieldGuideFrameBackgroundTextureClass:SetAlpha(0.4)
end

-- Resets the scroll bar to top left position.
local function resetScroll()
    currentMinLevel = lowestLevel
    FieldGuideFrameVerticalSlider:SetValue(0)
    FieldGuideFrameVerticalSliderScrollUpButton:Disable()
    FieldGuideFrameHorizontalSlider:SetValue(0)
    FieldGuideFrameHorizontalSliderScrollLeftButton:Disable()
end

-- Changes the class to the given class.
local function setClass(_, class)
    if class == "HUNTER_PETS" then
        setBackground("HUNTER")
        L_ToggleDropDownMenu(nil, nil, FieldGuideDropdownFrame)
        libDD:UIDropDownMenu_SetText(FieldGuideDropdownFrame, CLASS_COLORS.HUNTER .. "Pet skills")
    elseif class == "WARLOCK_PETS" then
        setBackground("WARLOCK")
        libDD:ToggleDropDownMenu(nil, nil, FieldGuideDropdownFrame)
        libDD:UIDropDownMenu_SetText(FieldGuideDropdownFrame, CLASS_COLORS.WARLOCK .. "Demon spells")
    else
        libDD:UIDropDownMenu_SetText(FieldGuideDropdownFrame, CLASS_COLORS[class] .. class:sub(1, 1) .. class:sub(2):lower())
    end
    selectedClass = class
    if class ~= "WEAPONS" and class ~= "HUNTER_PETS" and class ~= "WARLOCK_PETS" then
        setBackground(selectedClass)
        if class == "PRIEST" and actualClass == "PRIEST" then
            FieldGuideFrameEnemySpellsCheckBoxText:SetText("Non-" .. race .. " spells")
            FieldGuideFrameEnemySpellsCheckBox:Show()
            FieldGuideFrameEnemySpellsCheckBox:SetPoint("RIGHT", FieldGuideFrameTalentsCheckBox, "LEFT", -FieldGuideFrameEnemySpellsCheckBoxText:GetWidth() - 5, 0)
        elseif class == "MAGE" or class == "PRIEST" then
            FieldGuideFrameEnemySpellsCheckBoxText:SetText((isAlliance() and "Horde" or "Alliance") .. " spells")
            FieldGuideFrameEnemySpellsCheckBox:Show()
            FieldGuideFrameEnemySpellsCheckBox:SetPoint("RIGHT", FieldGuideFrameTalentsCheckBox, "LEFT", -FieldGuideFrameEnemySpellsCheckBoxText:GetWidth() - 5, 0)
        else
            FieldGuideFrameEnemySpellsCheckBox:Hide()
        end
        FieldGuideFrameTalentsCheckBox:Show()
        hideUnwantedSpells()
        resetScroll()
        updateButtons()
    elseif class == "WEAPONS" then
        setBackground(actualClass)
        FieldGuideFrameTalentsCheckBox:Hide()
        FieldGuideFrameEnemySpellsCheckBox:Hide()
        FieldGuideFrameVerticalSlider:SetMinMaxValues(0, 9 - NBR_OF_SPELL_ROWS)
        hideUnwantedWeapons()
        updateWeapons()
    elseif class == "WARLOCK_PETS" then
        FieldGuideFrameEnemySpellsCheckBox:Hide()
        FieldGuideFrameTalentsCheckBox:Hide()
        hideUnwantedSpells()
        resetScroll()
        updateButtons()
    elseif class == "HUNTER_PETS" then
        FieldGuideFrameEnemySpellsCheckBox:Hide()
        FieldGuideFrameTalentsCheckBox:Hide()
        hideUnwantedSpells()
        resetScroll()
        updateButtons()
    end
end

-- Returns true if the given class is currently selected in the dropdown list.
local function isSelected(class)
    return selectedClass == class
end

-- Initializes the dropdown menu.
local function initDropdown()
    libDD:UIDropDownMenu_Initialize(FieldGuideDropdownFrame, function(self, level, menuList)
        local info = libDD:UIDropDownMenu_CreateInfo()
        info.isNotRadio = true
        info.func = setClass
        if level == 1 then
            -- Warrior.
            info.text = "Warrior"
            info.colorCode = CLASS_COLORS.WARRIOR
            info.arg1 = "WARRIOR"
            info.checked = isSelected("WARRIOR")
            libDD:UIDropDownMenu_AddButton(info, level)
            -- Paladin.
            info.text = "Paladin"
            info.colorCode = CLASS_COLORS.PALADIN
            info.arg1 = "PALADIN"
            info.checked = isSelected("PALADIN")
            libDD:UIDropDownMenu_AddButton(info, level)
            -- Hunter.
            info.text = "Hunter"
            info.colorCode = CLASS_COLORS.HUNTER
            info.arg1 = "HUNTER"
            info.checked = isSelected("HUNTER")
            info.hasArrow = true
            info.menuList = "HUNTER_PETS"
            libDD:UIDropDownMenu_AddButton(info, level)
            -- Rogue.
            info.text = "Rogue"
            info.colorCode = CLASS_COLORS.ROGUE
            info.arg1 = "ROGUE"
            info.checked = isSelected("ROGUE")
            info.hasArrow = false
            info.menuList = nil
            libDD:UIDropDownMenu_AddButton(info, level)
            -- Priest.
            info.text = "Priest"
            info.colorCode = CLASS_COLORS.PRIEST
            info.arg1 = "PRIEST"
            info.checked = isSelected("PRIEST")
            libDD:UIDropDownMenu_AddButton(info, level)
            -- Shaman.
            info.text = "Shaman"
            info.colorCode = CLASS_COLORS.SHAMAN
            info.arg1 = "SHAMAN"
            info.checked = isSelected("SHAMAN")
            libDD:UIDropDownMenu_AddButton(info, level)
            -- Mage.
            info.text = "Mage"
            info.colorCode = CLASS_COLORS.MAGE
            info.checked = isSelected("MAGE")
            info.arg1 = "MAGE"
            libDD:UIDropDownMenu_AddButton(info, level)
            -- Warlock.
            info.text = "Warlock"
            info.colorCode = CLASS_COLORS.WARLOCK
            info.arg1 = "WARLOCK"
            info.checked = isSelected("WARLOCK")
            info.hasArrow = true
            info.menuList = "WARLOCK_PETS"
            libDD:UIDropDownMenu_AddButton(info, level)
            -- Druid.
            info.text = "Druid"
            info.colorCode = CLASS_COLORS.DRUID
            info.arg1 = "DRUID"
            info.checked = isSelected("DRUID")
            info.hasArrow = false
            info.menuList = nil
            libDD:UIDropDownMenu_AddButton(info, level)
            -- Weapon skills.
            info.text = "Weapons"
            info.colorCode = "|cFFDFDFDF"
            info.arg1 = "WEAPONS"
            info.checked = isSelected("WEAPONS")
            libDD:UIDropDownMenu_AddButton(info, level)
        elseif menuList == "WARLOCK_PETS" then
            info.text = "Demon spells"
            info.colorCode = CLASS_COLORS.WARLOCK
            info.arg1 = "WARLOCK_PETS"
            info.checked = isSelected("WARLOCK_PETS")
            info.func = setClass
            libDD:UIDropDownMenu_AddButton(info, level)
        elseif menuList == "HUNTER_PETS" then
            info.text = "Pet skills"
            info.colorCode = CLASS_COLORS.HUNTER
            info.arg1 = "HUNTER_PETS"
            info.checked = isSelected("HUNTER_PETS")
            info.func = setClass
            libDD:UIDropDownMenu_AddButton(info, level)
        end
    end)
    libDD:UIDropDownMenu_SetWidth(FieldGuideDropdownFrame, 100);
    libDD:UIDropDownMenu_SetButtonWidth(FieldGuideDropdownFrame, 124)
    libDD:UIDropDownMenu_JustifyText(FieldGuideDropdownFrame, "RIGHT")
    libDD:UIDropDownMenu_SetText(FieldGuideDropdownFrame, CLASS_COLORS[actualClass].. actualClass:sub(1, 1) .. actualClass:sub(2):lower())
end

-- Initializes all frames, level strings, and textures for reuse.
local function initFrames()
    NBR_OF_SPELL_ROWS = floor(FieldGuideFrame:GetHeight() / 100)
    Y_SPACING = math.ceil(FieldGuideFrame:GetHeight() / NBR_OF_SPELL_ROWS) / 1.1625
    local nbrOfSpellBtns = floor((FieldGuideFrame:GetWidth() - BUTTON_X_START * 2) / BUTTON_X_SPACING) * NBR_OF_SPELL_ROWS
    NBR_OF_SPELL_COLUMNS = nbrOfSpellBtns / NBR_OF_SPELL_ROWS -- The number of buttons in x.
    -- Create spell buttons.
    for frameIndex = 1, nbrOfSpellBtns do
        local spellBtnX = BUTTON_X_START + BUTTON_X_SPACING * ((frameIndex - 1) % NBR_OF_SPELL_COLUMNS)
        local spellBtnY = -Y_SPACING * math.ceil(frameIndex / NBR_OF_SPELL_COLUMNS) - BUTTON_Y_START
        spellButtons[frameIndex] = CreateFrame("BUTTON", nil, FieldGuideFrame, "FieldGuideSpellButtonTemplate")
        spellButtons[frameIndex]:SetPoint("TOPLEFT", spellBtnX, spellBtnY)
        spellButtons[frameIndex].index = frameIndex
        spellButtons[frameIndex].texture = spellButtons[frameIndex]:CreateTexture(nil, "BORDER")
    end
    -- Create level strings.
    for stringIndex = 1, NBR_OF_SPELL_ROWS do
        levelStrings[stringIndex] = FieldGuideFrame:CreateFontString(nil, "ARTWORK", "FieldGuideLevelStringTemplate")
        levelStrings[stringIndex]:SetPoint("TOPLEFT", LEVEL_STRING_X_START, -LEVEL_STRING_Y_START - Y_SPACING * stringIndex)
    end
    -- The fact that this is even needed...
    libDD:Create_UIDropDownMenu("FieldGuideDropdownFrame", FieldGuideFrame)
    FieldGuideDropdownFrame:SetPoint("TOPRIGHT", -36, -28)
end

-- Initializes everything.
local function init()
    tinsert(UISpecialFrames, FieldGuideFrame:GetName()) -- Allows us to close the window with escape.
    initFrames()
    setClass(nil, actualClass)
    initDropdown()
    initCheckboxes()
    initMinimapButton()
    initSlash()
    FieldGuide_ToggleButtons() -- Need to call this, or spells won't be hidden regardless of saved variables.
    FieldGuideFrameVerticalSlider:SetValue(1)
    FieldGuideFrameVerticalSlider:SetValue(0)
    if not tomtom then
        for _, pin in pairs(FieldGuideOptions.pins) do
            addMapPin(pin.map, pin.x, pin.y, pin.name)
        end
    end
end

-- Called whenever player clicks a pin.
function FieldGuidePin_OnClick(self, button)
    removeMapPin(self)
end

-- Called whenever player mouses over a pin.
function FieldGuidePin_OnEnter(self)
    local distance = getDistance(self.x, self.y, self.map)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
    GameTooltip:AddLine(self.name)
    local _, _, instance = hbd:GetPlayerWorldPosition()
    if self.instance ~= instance then
        GameTooltip:AddLine("Unknown distance", 1, 1, 1)
    else
        GameTooltip:AddLine(string.format("%s yards away", math.floor(distance)), 1, 1, 1)
    end
    GameTooltip:AddLine(self.mapName .. " (" .. self.coordString .. ")", 0.7, 0.7, 0.7)
    GameTooltip:Show()
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
        if selectedClass ~= "WEAPONS" then
            GameTooltip:AddLine(" ")
            if self.talent then
                GameTooltip:AddLine("Talent")
            end
            GameTooltip:AddLine("Rank: " .. "|cFFFFFFFF" .. self.rank)
        elseif self.spellId ~= 5009 then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Trained by:")
            for _, trainer in ipairs(FieldGuide.WEAPON_TRAINERS[faction:upper()]) do
                if trainer[self.spellId] then
                    GameTooltip:AddLine(trainer.name .. ", " .. hbd:GetLocalizedMap(trainer.map), 1, 1, 1)
                end
            end
        end
        if self.spellId ~= 5009 then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(self.spellCost ~= 0 and "Price: " .. canAfford .. priceString or "Learned via quest(s)")
        end
        GameTooltip:Show()
    end)
end

-- Called whenever player clicks on a spell button.
function FieldGuideSpellButton_OnClick(self, button)
    if button == "RightButton" and selectedClass ~= "WEAPONS" then
        local spellName = GetSpellInfo(self.spellId)
        FieldGuideOptions.unwantedSpells[self.spellId] = not FieldGuideOptions.unwantedSpells[self.spellId]
        if IsShiftKeyDown() then
            for _, spellIndex in pairs(FieldGuide[selectedClass]) do
                for spellIndex, spellInfo in ipairs(spellIndex) do
                    if spellInfo.name == spellName then
                        FieldGuideOptions.unwantedSpells[spellInfo.id] = FieldGuideOptions.unwantedSpells[self.spellId]
                    end
                end
            end
        end
        updateButtons()
    elseif button == "LeftButton" then
        if self.spellId ~= 5009 then
            local trainer = nil
            if self.name:find("Teleport") or self.name:find("Portal") then
                trainer = findPortalTrainer(self)
            else
                trainer = findClosestTrainer(self)
            end
            if trainer == nil then
                return
            end
            if not doesPinExist(trainer.name) and self.spellCost ~= 0 then
                addMapPin(trainer.map, trainer.x, trainer.y, trainer.name)
                if not tomtom then
                    FieldGuideOptions.pins[#FieldGuideOptions.pins + 1] = {
                        ["map"] = trainer.map,
                        ["x"] = trainer.x,
                        ["y"] = trainer.y,
                        ["name"] = trainer.name
                    }
                    print("|cFFFFFF00Field Guide:|r Added a marker to |cFFFF0000" .. trainer.name .. "|r in " .. hbd:GetLocalizedMap(trainer.map) ..
                            " at |cFF00FF00(" .. trainer.x * 100 .. ", " .. trainer.y * 100 .. ")|r.")
                end
            end
        end
    end
end

-- Called whenever player drags a spell button.1
function FieldGuideSpellButton_OnDragStart(self, button)
    PickupSpell(self.spellId)
end

-- Called when each spell button has loaded.
function FieldGuideSpellButton_OnLoad(self)
    self:RegisterForDrag("LeftButton")
end

-- Is called whenever the value of the vertical slider changes.
function FieldGuide_OnVerticalValueChanged(self, value)
    value = math.floor(value + 0.5)
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
function FieldGuide_ToggleButtons(t)
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    if t == 3 then -- Known spells.
        FieldGuideOptions.showKnownSpells = not FieldGuideOptions.showKnownSpells
    elseif t == 2 then -- Enemy spells.
        FieldGuideOptions.showEnemySpells = not FieldGuideOptions.showEnemySpells
    elseif t == 1 then -- Talents.
        FieldGuideOptions.showTalents = not FieldGuideOptions.showTalents
    end
    if selectedClass ~= "WEAPONS" then
        hideUnwantedSpells()
        currentMinLevel = lowestLevel
        resetScroll()
        updateButtons()
    else
        hideUnwantedWeapons()
        updateWeapons()
    end
end

-- Called when the frame has loaded.
function FieldGuide_OnLoad(self)
    self:RegisterForDrag("LeftButton")
    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("LEARNED_SPELL_IN_TAB")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("SKILL_LINES_CHANGED")
    self:RegisterEvent("UNIT_PET")
end

-- Called on each event the frame receives.
function FieldGuide_OnEvent(self, event, ...)
    if event == "ADDON_LOADED" then
        if ... == "FieldGuide" then
            tomtom = IsAddOnLoaded("TomTom") and _G["TomTom"]
            FieldGuideOptions = FieldGuideOptions == nil and {} or FieldGuideOptions
            if tomtom then
                FieldGuideOptions.pins = {}
            end
            FieldGuideOptions.pins = FieldGuideOptions.pins == nil and {} or FieldGuideOptions.pins
            FieldGuideOptions.showTalents = FieldGuideOptions.showTalents == nil and true or FieldGuideOptions.showTalents
            FieldGuideOptions.showEnemySpells = FieldGuideOptions.showEnemySpells == nil and false or FieldGuideOptions.showEnemySpells
            FieldGuideOptions.showKnownSpells = FieldGuideOptions.showKnownSpells == nil and false or FieldGuideOptions.showKnownSpells
            FieldGuideOptions.unwantedSpells = FieldGuideOptions.unwantedSpells == nil and {} or FieldGuideOptions.unwantedSpells
            FieldGuideOptions.minimapTable = FieldGuideOptions.minimapTable == nil and {} or FieldGuideOptions.minimapTable
            print(not tomtom and "|cFFFFFF00Field Guide|r loaded! Type /fg help for commands and controls. By the way, it is highly recommended to use TomTom with Field Guide." or "|cFFFFFF00Field Guide|r loaded! Type /fg help for commands and controls.")
            self:UnregisterEvent("ADDON_LOADED")
        end
    elseif event == "LEARNED_SPELL_IN_TAB" then
        if selectedClass ~= "WEAPONS" then
            hideUnwantedSpells()
            updateButtons()
            resetScroll()
        end
    elseif event == "SKILL_LINES_CHANGED" then
        if selectedClass == "WEAPONS" then
            hideUnwantedWeapons()
            updateWeapons()
        end
    elseif event == "UNIT_PET" then
        if selectedClass == "HUNTER_PETS" or selectedClass == "WARLOCK_PETS" then
            hideUnwantedSpells()
            updateButtons()
            resetScroll()
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        init()
        FieldGuideFrame:Hide()
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end
