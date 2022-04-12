local _, FieldGuide = ...

local pairs, ipairs, select, floor = pairs, ipairs, select, math.floor
local GetFactionInfoByID, IsSpellKnown, GetMoney, GetCoinTextureString = GetFactionInfoByID, IsSpellKnown, GetMoney, GetCoinTextureString
local minimapIcon = LibStub("LibDBIcon-1.0")
local libDD = LibStub("LibUIDropDownMenu-4.0")

-- Variables.
local faction = UnitFactionGroup("player")
local race = UnitRace("player")
local playerClass = select(2, UnitClass("player"))
local playerLevel = select(1, UnitLevel("player"))
local topShownRow = 1 -- The current top row to show.
local bottomShownRow = 1 -- Used for figuring out which row is at the top when hiding entire rows.
local selectedCategory = "CLASS"
local selectedClass -- The currently selected class.
local groups = {}
local spells = {}
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
    RIDING = "MageFrost",
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
    ["RIDING"] = "|cFFDFDFDF",
    ["WEAPONS"] = "|cFFDFDFDF"
}

-- UI variables.
local levelStrings = {} -- All the level font strings.
local spellButtons = {} -- All the spell frames.
local lastVerticalValue = 0 -- For the vertical slider to not update a million times a second.
local BUTTON_X_START = 33 -- How far to the right the buttons start.
local BUTTON_Y_START = -25 -- How far down the first button is placed.
local BUTTON_X_SPACING = 45 -- The spacing between all buttons in x.
local LEVEL_STRING_X_START = 30 -- How far to the right the level strings are placed.
local LEVEL_STRING_Y_START = -53 -- How far down the first level string is placed.
local Y_SPACING = 0 -- The spacing between all elements in y.
local NBR_OF_SPELL_ROWS = 0
local NBR_OF_SPELL_COLUMNS = 0

-- Returns true if the player is Alliance, false otherwise.
local function isAlliance ()
    return faction == "Alliance"
end

-- Returns the cost modifier (0.9 if player is honored or rank 3, 0.8 if both, 1 otherwise).
local function getCostModifier ()
    local highestRep = 0
    local allianceFactions = {
        72, -- Stormwind
        47, -- Ironforge
        69, -- Darnassus
        53, -- Gnomeregan Exiles
        930 -- Exodar
    }
    local hordeFactions = {
        76, -- Orgrimmar
        81, -- Thunder Bluff
        68, -- Undercity
        530, -- Darkspear Trolls
        911 -- Silvermoon City
    }
    for k, v in pairs(isAlliance() and allianceFactions or hordeFactions) do
        local a, b, repLevel = GetFactionInfoByID(v)
        if repLevel > highestRep then
            highestRep = repLevel
        end
    end

    if (highestRep > 5) then
        return 1 - 0.05 * (highestRep - 4)
    else
        return 1
    end
end

-- Shows/hides the frame.
local function toggleFrame ()
    if FieldGuideFrame:IsVisible() then
        FieldGuideFrame:Hide()
    else
        FieldGuideFrame:Show()
    end
end

-- Toggles the minimap button on or off.
local function toggleMinimapButton ()
    FieldGuideOptions.minimapTable.hide = not FieldGuideOptions.minimapTable.hide
    if FieldGuideOptions.minimapTable.hide then
        minimapIcon:Hide("FieldGuide")
        print("|cFFFFFF00Field Guide:|r Minimap button hidden. Type /fg minimap to show it again.")
    else
        minimapIcon:Show("FieldGuide")
        print("|cFFFFFF00Field Guide:|r Minimap button shown. Type /fg minimap to hide it again.")
    end
end

-- Toggles the startup message on or off.
local function toggleStartupMessage ()
    FieldGuideOptions.showStartupMessage = not FieldGuideOptions.showStartupMessage
    if FieldGuideOptions.showStartupMessage then
        print("|cFFFFFF00Field Guide|r startup message enabled")
    else
        print("|cFFFFFF00Field Guide|r startup message disabled")
    end
end

-- Sets slash commands.
local function initSlash ()
    SLASH_FIELDGUIDE1 = "/fieldguide"
    SLASH_FIELDGUIDE2 = "/fg"
    SlashCmdList["FIELDGUIDE"] = function(msg)
        msg = msg:lower()
        if msg == "minimap" then
            toggleMinimapButton()
            return
        elseif msg == "startup" then
            toggleStartupMessage()
            return
        elseif msg == "help" or msg == "h" then
            print("|cFFFFFF00Field Guide:|r\n"
                    .. "/fg or /fieldguide both work to toggle the addon.\n"
                    .. "/fg minimap - toggles the minimap button.\n"
                    .. "/fg startup - toggles the 'Field Guide loaded!' message when your UI loads.\n"
                    .. "/fg version - toggles the 'Field Guide loaded!' message when your UI loads.\n"
                    .. "You can drag any spell onto an action bar from the addon.")
            return
        elseif msg == "version" or msg == "v" then
            local version = GetAddOnMetadata("FieldGuide", "Version");
            print("|cFFFFFF00Field Guide|r version " .. version)
            return
        else
            toggleFrame()
        end
    end
end

-- Initializes the minimap button.
local function initMinimapButton ()
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
local function initCheckboxes ()
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
    FieldGuideFrameEnemySpellsCheckBoxText:SetText((playerClass ~= "PRIEST" and (isAlliance() and "Horde" or "Alliance") or ("Non-" .. race)) .. " spells")
    FieldGuideFrameEnemySpellsCheckBox:SetPoint("RIGHT", FieldGuideFrameTalentsCheckBox, "LEFT", -FieldGuideFrameEnemySpellsCheckBoxText:GetWidth() - 5, 0)
    -- Set checked or not checked.
    FieldGuideFrameTalentsCheckBox:SetChecked(FieldGuideOptions.showTalents)
    FieldGuideFrameEnemySpellsCheckBox:SetChecked(FieldGuideOptions.showEnemySpells)
    FieldGuideFrameKnownSpellsCheckBox:SetChecked(FieldGuideOptions.showKnownSpells)
end

-- Updates the given frame with the given texture and info.
local function updateFrame (texture, frame, info, level)
    texture:SetTexture(info.texture)
    texture:SetAllPoints()
    texture:SetVertexColor(1, 1, 1)

    frame:Hide() -- So that tooltip updates when scrolling.
    frame.name = info.name
    frame.rank = info.rank
    frame.talent = info.talent
    if info.item_id ~= nil then
        frame.itemId = info.item_id
        frame.spellId = ''
    else
        frame.itemId = ''
        frame.spellId = info.id
    end
    if info.cost_modifier ~= nil then frame.cost_modifier = info.cost_modifier end
    frame.spellCost = info.cost
    frame.level = level
    frame:Show()
end

-- Hides all empty buttons between the given frameCounter and shownCounter.
local function hideExtraFrames (frameCounter, shownCounter)
    for i = frameCounter, frameCounter + NBR_OF_SPELL_COLUMNS - shownCounter - 1 do -- Hide all unnecessary buttons.
        spellButtons[i]:Hide()
        frameCounter = frameCounter + 1
    end
    return frameCounter
end

-- Updates all the buttons in the frame.
local function updateButtons ()
    local frameCounter = 1
    local currentRow = topShownRow

    for row=1,NBR_OF_SPELL_ROWS do
        local index = topShownRow + row - 1
        local item = spells[index]
        local group = groups[index]
        local shownCounter = 0

        -- Set text to blank to avoid leaving old text in there
        levelStrings[row]:SetText("")

        if groups[index] ~= nil then
            if type(groups[index]) == "number" then
                levelStrings[row]:SetText("Level " .. groups[index])
            else
                levelStrings[row]:SetText((groups[index]:gsub("^%l", string.upper)))
            end

            for c=1,getTableSize(item) do
                updateFrame(spellButtons[frameCounter].texture, spellButtons[frameCounter], item[c], index)
                shownCounter = shownCounter + 1
                frameCounter = frameCounter + 1
            end
        end
        frameCounter = hideExtraFrames(frameCounter, shownCounter)
    end
end

-- Sets the height of the scrollable window, so we can't scroll too far
local function setScrollableHeight ()
    total_rows = 0
    for level,levelInfo in pairsByKeys(spells) do
        total_rows = total_rows + 1
    end

    rows_off_screen = total_rows - NBR_OF_SPELL_ROWS

    if rows_off_screen <= 0 then
        FieldGuideFrameVerticalSlider:SetMinMaxValues(0, 0)
        FieldGuideFrameVerticalSliderScrollDownButton:Disable()
    else
        FieldGuideFrameVerticalSlider:SetMinMaxValues(0, rows_off_screen)
        FieldGuideFrameVerticalSliderScrollDownButton:Enable()
    end
end

-- Sets the background to the given class. Class must be a capitalized string.
local function setBackground (class)
    if CLASS_BACKGROUNDS[class] ~= nil then
        FieldGuideFrameBackgroundTextureClass:SetTexture("Interface/TALENTFRAME/" .. CLASS_BACKGROUNDS['WARRIOR'] .. "-TopLeft")
        FieldGuideFrameBackgroundTextureClass:SetAlpha(0.4)
    end
end

-- Resets the scroll bar to top left position.
local function resetScroll ()
    topShownRow = bottomShownRow
    FieldGuideFrameVerticalSlider:SetValue(0)
    FieldGuideFrameVerticalSliderScrollUpButton:Disable()
end

-- Changes the class to the given class.
local function setClass (class)
    selectedClass = class
    setBackground(selectedClass)

    if selectedClass ~= "WEAPONS" and selectedClass ~= "HUNTER_PETS" and selectedClass ~= "WARLOCK_PETS" and selectedCategory ~= "PROFESSIONS" then
        if selectedClass == "PRIEST" and actualClass == "PRIEST" then
            FieldGuideFrameEnemySpellsCheckBoxText:SetText("Non-" .. race .. " spells")
            FieldGuideFrameEnemySpellsCheckBox:Show()
            FieldGuideFrameEnemySpellsCheckBox:SetPoint("RIGHT", FieldGuideFrameTalentsCheckBox, "LEFT", -FieldGuideFrameEnemySpellsCheckBoxText:GetWidth() - 5, 0)
        elseif selectedClass == "MAGE" or selectedClass == "PRIEST" then
            FieldGuideFrameEnemySpellsCheckBoxText:SetText((isAlliance() and "Horde" or "Alliance") .. " spells")
            FieldGuideFrameEnemySpellsCheckBox:Show()
            FieldGuideFrameEnemySpellsCheckBox:SetPoint("RIGHT", FieldGuideFrameTalentsCheckBox, "LEFT", -FieldGuideFrameEnemySpellsCheckBoxText:GetWidth() - 5, 0)
        else
            FieldGuideFrameEnemySpellsCheckBox:Hide()
        end
        FieldGuideFrameTalentsCheckBox:Show()
    elseif selectedClass == "WEAPONS" then
        setBackground(actualClass)
        FieldGuideFrameTalentsCheckBox:Hide()
        FieldGuideFrameEnemySpellsCheckBox:Hide()
        FieldGuideFrameVerticalSlider:SetMinMaxValues(0, 9 - NBR_OF_SPELL_ROWS)
    elseif selectedClass == "WARLOCK_PETS" then
        FieldGuideFrameEnemySpellsCheckBox:Hide()
        FieldGuideFrameTalentsCheckBox:Hide()
    elseif selectedClass == "HUNTER_PETS" then
        FieldGuideFrameEnemySpellsCheckBox:Hide()
        FieldGuideFrameTalentsCheckBox:Hide()
    elseif selectedCategory == "PROFESSIONS" then
        FieldGuideFrameEnemySpellsCheckBox:Hide()
        FieldGuideFrameTalentsCheckBox:Hide()
    elseif selectedCategory == "GENERAL" then
        setBackground(actualClass)
        FieldGuideFrameTalentsCheckBox:Hide()
        FieldGuideFrameEnemySpellsCheckBox:Hide()
    end

    if CLASS_COLORS[selectedClass] ~= nil then
        libDD:UIDropDownMenu_SetText(FieldGuideDropdownFrame, CLASS_COLORS[selectedClass] .. selectedClass:sub(1, 1) .. selectedClass:sub(2):lower())
    else
        libDD:UIDropDownMenu_SetText(FieldGuideDropdownFrame, CLASS_COLORS['WEAPONS'] .. selectedClass:sub(1, 1) .. selectedClass:sub(2):lower())
    end
end

local function changeClass (class)
    local info = libDD:Create_UIDropDownMenu("FieldGuideDropdownFrame", FieldGuideFrame)
    info:Hide()

    if FieldGuide[class.arg1] ~= nil then
        spells = {}
        groups = {}

        selectedCategory = class.arg2
        setClass(class.arg1)
        parseSpells()

        setScrollableHeight()
        resetScroll()
        updateButtons()
    end
end

-- Returns true if the given class is currently selected in the dropdown list.
local function isSelected (class)
    if selectedClass == class then
        return true
    elseif selectedCategory == class then
        return true
    end

    return false
end

-- Initializes the dropdown menu.
local function initDropdown ()
    libDD:UIDropDownMenu_Initialize(FieldGuideDropdownFrame, function(self, level, menuList)
        local info = libDD:UIDropDownMenu_CreateInfo()

        if level == 1 then
            -- Druid.
            info.text = "Druid"
            info.colorCode = CLASS_COLORS.DRUID
            info.arg1 = "DRUID"
            info.arg2 = "CLASS"
            info.checked = isSelected("DRUID")
            info.hasArrow = false
            info.menuList = nil
            info.func = changeClass
            libDD:UIDropDownMenu_AddButton(info, level)
            -- Hunter.
            info.text = "Hunter"
            info.colorCode = CLASS_COLORS.HUNTER
            info.arg1 = "HUNTER"
            info.arg2 = "CLASS"
            info.checked = isSelected("HUNTER")
            info.hasArrow = true
            info.menuList = "HUNTER_PETS"
            info.func = changeClass
            libDD:UIDropDownMenu_AddButton(info, level)
            -- Mage.
            info.text = "Mage"
            info.colorCode = CLASS_COLORS.MAGE
            info.arg1 = "MAGE"
            info.arg2 = "CLASS"
            info.checked = isSelected("MAGE")
            info.hasArrow = false
            info.menuList = nil
            info.func = changeClass
            libDD:UIDropDownMenu_AddButton(info, level)
            -- Paladin.
            info.text = "Paladin"
            info.colorCode = CLASS_COLORS.PALADIN
            info.arg1 = "PALADIN"
            info.arg2 = "CLASS"
            info.checked = isSelected("PALADIN")
            info.hasArrow = false
            info.menuList = nil
            info.func = changeClass
            libDD:UIDropDownMenu_AddButton(info, level)
            -- Priest.
            info.text = "Priest"
            info.colorCode = CLASS_COLORS.PRIEST
            info.arg1 = "PRIEST"
            info.arg2 = "CLASS"
            info.checked = isSelected("PRIEST")
            info.hasArrow = false
            info.menuList = nil
            info.func = changeClass
            libDD:UIDropDownMenu_AddButton(info, level)
            -- Rogue.
            info.text = "Rogue"
            info.colorCode = CLASS_COLORS.ROGUE
            info.arg1 = "ROGUE"
            info.arg2 = "CLASS"
            info.checked = isSelected("ROGUE")
            info.hasArrow = false
            info.menuList = nil
            info.func = changeClass
            libDD:UIDropDownMenu_AddButton(info, level)
            -- Shaman.
            info.text = "Shaman"
            info.colorCode = CLASS_COLORS.SHAMAN
            info.arg1 = "SHAMAN"
            info.arg2 = "CLASS"
            info.checked = isSelected("SHAMAN")
            info.hasArrow = false
            info.menuList = nil
            info.func = changeClass
            libDD:UIDropDownMenu_AddButton(info, level)
            -- Warlock.
            info.text = "Warlock"
            info.colorCode = CLASS_COLORS.WARLOCK
            info.arg1 = "WARLOCK"
            info.arg2 = "CLASS"
            info.checked = isSelected("WARLOCK")
            info.hasArrow = true
            info.menuList = "WARLOCK_PETS"
            info.func = changeClass
            libDD:UIDropDownMenu_AddButton(info, level)
            -- Warrior.
            info.text = "Warrior"
            info.colorCode = CLASS_COLORS.WARRIOR
            info.arg1 = "WARRIOR"
            info.arg2 = "CLASS"
            info.checked = isSelected("WARRIOR")
            info.hasArrow = false
            info.menuList = nil
            info.func = changeClass
            libDD:UIDropDownMenu_AddButton(info, level)
            -- Riding skills.
            info.text = "Riding"
            info.colorCode = "|cFFDFDFDF"
            info.arg1 = "RIDING"
            info.arg2 = "GENERAL"
            info.checked = isSelected("RIDING")
            info.hasArrow = false
            info.menuList = nil
            info.func = changeClass
            libDD:UIDropDownMenu_AddButton(info, level)
            -- Weapon skills.
            info.text = "Weapons"
            info.colorCode = "|cFFDFDFDF"
            info.arg1 = "WEAPONS"
            info.arg2 = "GENERAL"
            info.checked = isSelected("WEAPONS")
            info.hasArrow = false
            info.menuList = nil
            info.func = changeClass
            libDD:UIDropDownMenu_AddButton(info, level)
            -- Professions.
            info.text = "Professions"
            info.colorCode = CLASS_COLORS.WEAPONS
            info.arg1 = "PROFESSIONS"
            info.checked = isSelected("PROFESSIONS")
            info.hasArrow = true
            info.menuList = "PROFESSIONS"
            libDD:UIDropDownMenu_AddButton(info, level)
        elseif menuList == "WARLOCK_PETS" then
            info.text = "Demon spells"
            info.colorCode = CLASS_COLORS.WARLOCK
            info.arg1 = "WARLOCK_PETS"
            info.arg2 = "WARLOCK"
            info.checked = isSelected("WARLOCK_PETS")
            info.func = changeClass
            libDD:UIDropDownMenu_AddButton(info, level)
        elseif menuList == "HUNTER_PETS" then
            info.text = "Pet skills"
            info.colorCode = CLASS_COLORS.HUNTER
            info.arg1 = "HUNTER_PETS"
            info.arg2 = "HUNTER"
            info.checked = isSelected("HUNTER_PETS")
            info.func = changeClass
            libDD:UIDropDownMenu_AddButton(info, level)
        elseif menuList == "PROFESSIONS" then
            info.text = "Alchemy"
            info.colorCode = CLASS_COLORS.WEAPONS
            info.arg1 = string.upper(info.text)
            info.arg2 = "PROFESSIONS"
            info.checked = isSelected(info.arg1)
            info.func = changeClass
            libDD:UIDropDownMenu_AddButton(info, level)

            info.text = "Blacksmithing"
            info.colorCode = CLASS_COLORS.WEAPONS
            info.arg1 = string.upper(info.text)
            info.arg2 = "PROFESSIONS"
            info.checked = isSelected(info.arg1)
            info.hasArrow = false
            info.menuList = nil
            info.func = changeClass
            libDD:UIDropDownMenu_AddButton(info, level)

            info.text = "Cooking"
            info.colorCode = CLASS_COLORS.WEAPONS
            info.arg1 = string.upper(info.text)
            info.arg2 = "PROFESSIONS"
            info.checked = isSelected(info.arg1)
            info.hasArrow = false
            info.menuList = nil
            info.func = changeClass
            libDD:UIDropDownMenu_AddButton(info, level)

            info.text = "Enchanting"
            info.colorCode = CLASS_COLORS.WEAPONS
            info.arg1 = string.upper(info.text)
            info.arg2 = "PROFESSIONS"
            info.checked = isSelected(info.arg1)
            info.hasArrow = false
            info.menuList = nil
            info.func = changeClass
            libDD:UIDropDownMenu_AddButton(info, level)

            info.text = "Engineering"
            info.colorCode = CLASS_COLORS.WEAPONS
            info.arg1 = string.upper(info.text)
            info.arg2 = "PROFESSIONS"
            info.checked = isSelected(info.arg1)
            info.hasArrow = false
            info.menuList = nil
            info.func = changeClass
            libDD:UIDropDownMenu_AddButton(info, level)

            info.text = "First Aid"
            info.colorCode = CLASS_COLORS.WEAPONS
            info.arg1 = "FIRSTAID"
            info.arg2 = "PROFESSIONS"
            info.checked = isSelected("FIRSTAID")
            info.func = changeClass
            libDD:UIDropDownMenu_AddButton(info, level)

            info.text = "Fishing"
            info.colorCode = CLASS_COLORS.WEAPONS
            info.arg1 = string.upper(info.text)
            info.arg2 = "PROFESSIONS"
            info.checked = isSelected(info.arg1)
            info.hasArrow = false
            info.menuList = nil
            info.func = changeClass
            libDD:UIDropDownMenu_AddButton(info, level)

            info.text = "Herbalism"
            info.colorCode = CLASS_COLORS.WEAPONS
            info.arg1 = string.upper(info.text)
            info.arg2 = "PROFESSIONS"
            info.checked = isSelected(info.arg1)
            info.hasArrow = false
            info.menuList = nil
            info.func = changeClass
            libDD:UIDropDownMenu_AddButton(info, level)

            info.text = "Jewelcrafting"
            info.colorCode = CLASS_COLORS.WEAPONS
            info.arg1 = string.upper(info.text)
            info.arg2 = "PROFESSIONS"
            info.checked = isSelected(info.arg1)
            info.hasArrow = false
            info.menuList = nil
            info.func = changeClass
            libDD:UIDropDownMenu_AddButton(info, level)

            info.text = "Leatherworking"
            info.colorCode = CLASS_COLORS.WEAPONS
            info.arg1 = string.upper(info.text)
            info.arg2 = "PROFESSIONS"
            info.checked = isSelected(info.arg1)
            info.hasArrow = false
            info.menuList = nil
            info.func = changeClass
            libDD:UIDropDownMenu_AddButton(info, level)

            info.text = "Mining"
            info.colorCode = CLASS_COLORS.WEAPONS
            info.arg1 = string.upper(info.text)
            info.arg2 = "PROFESSIONS"
            info.checked = isSelected(info.arg1)
            info.hasArrow = false
            info.menuList = nil
            info.func = changeClass
            libDD:UIDropDownMenu_AddButton(info, level)

            info.text = "Skinning"
            info.colorCode = CLASS_COLORS.WEAPONS
            info.arg1 = string.upper(info.text)
            info.arg2 = "PROFESSIONS"
            info.checked = isSelected(info.arg1)
            info.hasArrow = false
            info.menuList = nil
            info.func = changeClass
            libDD:UIDropDownMenu_AddButton(info, level)

            info.text = "Tailoring"
            info.colorCode = CLASS_COLORS.WEAPONS
            info.arg1 = string.upper(info.text)
            info.arg2 = "PROFESSIONS"
            info.checked = isSelected(info.arg1)
            info.hasArrow = false
            info.menuList = nil
            info.func = changeClass
            libDD:UIDropDownMenu_AddButton(info, level)
        end
    end)
    libDD:UIDropDownMenu_SetWidth(FieldGuideDropdownFrame, 100);
    libDD:UIDropDownMenu_SetButtonWidth(FieldGuideDropdownFrame, 124)
    libDD:UIDropDownMenu_JustifyText(FieldGuideDropdownFrame, "RIGHT")

    if CLASS_COLORS[selectedClass] ~= nil then
        libDD:UIDropDownMenu_SetText(FieldGuideDropdownFrame, CLASS_COLORS[playerClass] .. selectedClass:sub(1, 1) .. selectedClass:sub(2):lower())
    else
        libDD:UIDropDownMenu_SetText(FieldGuideDropdownFrame, CLASS_COLORS['WEAPONS'] .. selectedClass:sub(1, 1) .. selectedClass:sub(2):lower())
    end
end

-- Initializes all frames, level strings, and textures for reuse.
local function initFrames ()
    NBR_OF_SPELL_ROWS = floor(FieldGuideFrame:GetHeight() / 100)
    Y_SPACING = math.ceil(FieldGuideFrame:GetHeight() / NBR_OF_SPELL_ROWS) / 1.1
    NBR_OF_SPELL_BTNS = floor((FieldGuideFrame:GetWidth() - BUTTON_X_START * 2) / BUTTON_X_SPACING) * NBR_OF_SPELL_ROWS
    NBR_OF_SPELL_COLUMNS = NBR_OF_SPELL_BTNS / NBR_OF_SPELL_ROWS -- The number of buttons in x.

    -- Create spell buttons.
    for frameIndex = 1, NBR_OF_SPELL_BTNS do
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

function parseSpells ()
    groups = {}
    spells = {}

    for group,list in pairsByKeys(FieldGuide[selectedClass]) do
        local temp = {}

        for index, spell in ipairs(list) do
            local showSpell = true

            if (spell.faction ~= nil and FieldGuideOptions.showEnemySpells == false and ((isAlliance() and spell.faction ~= 'Alliance') or (not isAlliance() and spell.faction ~= 'Horde'))) then
                showSpell = false
            end
            if (spell.talent ~= nil and (FieldGuideOptions.showTalents == false or spell.talent == false)) then
                showSpell = false
            end
            if (not FieldGuideOptions.showKnownSpells) then
                if spell.id ~= nil then
                    if (IsPlayerSpell(spell.id)) then
                        showSpell = false
                    elseif (spell.id == 5487 and IsPlayerSpell(9634)) then --bear form check, to see if user has dire bear form
                        showSpell = false
                    else
                        for g,l in pairsByKeys(FieldGuide[selectedClass]) do
                            for i,v in ipairs(l) do
                                if v.name == spell.name and v.rank > spell.rank and IsPlayerSpell(v.id) then
                                    showSpell = false
                                end
                            end
                        end
                    end
                end
            end

            if showSpell then
                table.insert(temp, spell)
            end
        end

        if getTableSize(temp) > 0 then
            table.insert(groups, group)
            table.insert(spells, temp)
        end
    end
end

-- Initializes everything.
local function init ()
    tinsert(UISpecialFrames, FieldGuideFrame:GetName()) -- Allows us to close the window with escape.
    initFrames()
    setClass(playerClass)
    parseSpells()
    initDropdown()
    initCheckboxes()
    initMinimapButton()
    initSlash()
    FieldGuide_ToggleButtons()
end

-- Called whenever player mouses over an icon.
function FieldGuideSpellButton_OnEnter (self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

    if self.itemId ~= '' then
        local tooltip = Item:CreateFromItemID(self.itemId)
        tooltip:ContinueOnItemLoad(function()
            GameTooltip:SetHyperlink("item:" .. self.itemId)

            --GameTooltip:AddLine(" ")
            --GameTooltip:AddLine("Talent") -- Sell price per unit
            --GameTooltip:AddLine("Talent") -- Sell price per stack

            -- Cost
            if self.spellCost ~= nil and self.spellCost > 0 then
                local adjustedPrice = self.spellCost
                if self.cost_modifier == nil or self.cost_modifier ~= false then
                    adjustedPrice = adjustedPrice * getCostModifier()
                end
                local priceString = GetCoinTextureString(adjustedPrice)
                local costColor = GetMoney() < adjustedPrice and "|cFFFF0000" or "|cFFFFFFFF" -- Modifies string to be red if player can't afford, white otherwise.
                if self.spellId ~= nil then
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine(self.spellCost ~= 0 and "Price: " .. costColor .. priceString or "Learned via quest(s)")
                end
            end

            GameTooltip:Show()
        end)
    elseif self.spellId ~= '' then
        local spell = Spell:CreateFromSpellID(self.spellId)
        spell:ContinueOnSpellLoad(function()
            GameTooltip:SetHyperlink("spell:" .. self.spellId)

            -- Spell Rank
            local rank = self.rank == nil and 0 or self.rank
            if rank ~= 0 then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("Rank: " .. "|cFFFFFFFF" .. rank)
            end

            -- Is this ability a talent?
            if self.talent then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("Talent")
            end

            -- Cost
            if self.spellCost ~= nil and self.spellCost > 0 then
                local adjustedPrice = self.spellCost
                if self.cost_modifier == nil or self.cost_modifier ~= false then
                    adjustedPrice = adjustedPrice * getCostModifier()
                end
                local priceString = GetCoinTextureString(adjustedPrice)
                local costColor = GetMoney() < adjustedPrice and "|cFFFF0000" or "|cFFFFFFFF" -- Modifies string to be red if player can't afford, white otherwise.
                if self.spellId ~= nil then
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine(self.spellCost ~= 0 and "Price: " .. costColor .. priceString or "Learned via quest(s)")
                end
            end

            GameTooltip:Show()
        end)
    end
end

-- Called whenever player drags a spell button.1
function FieldGuideSpellButton_OnDragStart (self, button)
    PickupSpell(self.spellId)
end

-- Called when each spell button has loaded.
function FieldGuideSpellButton_OnLoad (self)
    self:RegisterForDrag("LeftButton")
end

-- Is called whenever the value of the vertical slider changes.
function FieldGuide_OnVerticalValueChanged (self, value)
    value = math.floor(value + 0.5)

    if value ~= 0 then
        topShownRow = topShownRow + (value - lastVerticalValue)
    else
        topShownRow = bottomShownRow
    end
    lastVerticalValue = value
    self:SetValue(value)
    updateButtons()

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

-- Called whenever the player scrolls.
function FieldGuide_Scroll (delta)
    FieldGuideFrameVerticalSlider:SetValue(FieldGuideFrameVerticalSlider:GetValue() - delta)
end

-- Shows or hides the talents (type == 1), enemy spells (type == 2), or known spells (type == 3).
function FieldGuide_ToggleButtons (t)
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    if t == 3 then -- Known spells.
        FieldGuideOptions.showKnownSpells = not FieldGuideOptions.showKnownSpells
        parseSpells()
    elseif t == 2 then -- Enemy spells.
        FieldGuideOptions.showEnemySpells = not FieldGuideOptions.showEnemySpells
        parseSpells()
    elseif t == 1 then -- Talents.
        FieldGuideOptions.showTalents = not FieldGuideOptions.showTalents
        parseSpells()
    end

    setScrollableHeight()
    if t == 3 then --Show known skills, which needs to reset a while lot
        topShownRow = bottomShownRow
        resetScroll()
    end

    updateButtons()
end

-- Called when the frame has loaded.
function FieldGuide_OnLoad (self)
    self:RegisterForDrag("LeftButton")
    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("LEARNED_SPELL_IN_TAB")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("SKILL_LINES_CHANGED")
    self:RegisterEvent("UNIT_PET")
    self:RegisterEvent("TRAINER_SHOW")
end

-- Called on each event the frame receives.
function FieldGuide_OnEvent (self, event, ...)
    if event == "ADDON_LOADED" then
        if ... == "FieldGuide" then
            FieldGuideOptions = FieldGuideOptions == nil and {} or FieldGuideOptions
            FieldGuideOptions.showTalents = FieldGuideOptions.showTalents == nil and true or FieldGuideOptions.showTalents
            FieldGuideOptions.showEnemySpells = FieldGuideOptions.showEnemySpells == nil and false or FieldGuideOptions.showEnemySpells
            FieldGuideOptions.showKnownSpells = FieldGuideOptions.showKnownSpells == nil and false or FieldGuideOptions.showKnownSpells
            FieldGuideOptions.unwantedSpells = FieldGuideOptions.unwantedSpells == nil and {} or FieldGuideOptions.unwantedSpells
            FieldGuideOptions.minimapTable = FieldGuideOptions.minimapTable == nil and {} or FieldGuideOptions.minimapTable
            FieldGuideOptions.showStartupMessage = FieldGuideOptions.showStartupMessage == nil and false or FieldGuideOptions.showStartupMessage

            -- remove this when done 
            FieldGuideOptions.test = FieldGuideOptions.test == nil and {} or FieldGuideOptions.test
            if FieldGuideOptions.showStartupMessage then
                print("|cFFFFFF00Field Guide|r loaded! Type '/fg help' for commands and controls.")
            end

            self:UnregisterEvent("ADDON_LOADED")
        end
    elseif event == "LEARNED_SPELL_IN_TAB" then
        updateButtons()
        resetScroll()
    elseif event == "PLAYER_ENTERING_WORLD" then
        init()
        FieldGuideFrame:Hide() -- Comment this out to auto-show the frame when your UI loads
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end
