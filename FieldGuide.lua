-- TODO:
-- Add close button at top right.
-- Add class icon in top right corner (or at least something to distinguish the different classes).
-- Add option (somewhere/somehow) to hide known spells (or maybe just hide any spells before current level) - IsSpellKnown(spellId, isPetSpell).
-- Add option (somewhere/somehow) to show other classes spells.
-- Add option (somewhere/somehow) to filter between certain levels?
-- Add option (somewhere/somehow) to search for a certain spell.
-- Add option to sort spells by cost or by spec.
-- Add to interface/addons options?
-- Add option to show talents or not.
-- Add icons for tomes/quests at level 60?
-- Fix: Some spells are only for horde etc., such as Teleport: Stormwind and Teleport: Orgrimmar.
-- Distinguish talents from normal spells.

-- BUGS:
-- Highlighting over scroll up and down buttons is too big.
-- Manually dragging the slider does not update buttons. Currently, calling FieldGuide_UpdateButtons() will be done 10000x per slider update – lags the game out.

local BUTTON_X_START = 37 -- How far to the right the buttons start.
local BUTTON_Y_START = -32 -- How far down the buttons start.
local BUTTON_X_SPACING = 45 -- The spacing between all buttons in x.
local LEVEL_STRING_X_START = 35 -- How far to the right the level strings are placed.
local LEVEL_STRING_Y_START = -55 -- How far down the level strings are placed.
local Y_SPACING = 0 -- The spacing between all elements in y.
local NBR_OF_SPELL_ROWS = 5

local levelStrings = {}
local spellButtons = {}
local spellTextures = {}
local spellPrices = {}

local currentMinLevel = 2

-- Initiates all frames, level strings, and textures for reuse.
local function initFrames()
	if #spellButtons == 0 or #levelStrings == 0 then
		local nbrOfFrames = math.floor((FieldGuideFrame:GetWidth() - (BUTTON_X_START * 2)) / BUTTON_X_SPACING) * NBR_OF_SPELL_ROWS
		Y_SPACING = math.ceil(FieldGuideFrame:GetHeight() / NBR_OF_SPELL_ROWS) / 1.125
		for i = 1, nbrOfFrames do
			-- Create frames.
			local n = nbrOfFrames / NBR_OF_SPELL_ROWS -- The number of buttons in x.
			local spellBtnX = BUTTON_X_START + BUTTON_X_SPACING * ((i - 1) % 13)
			local spellBtnY = -Y_SPACING * math.ceil(i / n) - BUTTON_Y_START
			spellButtons[i] = CreateFrame("BUTTON", nil, FieldGuideFrame, "FieldGuideSpellButtonTemplate")
			spellButtons[i]:SetPoint("TOPLEFT", spellBtnX, spellBtnY)
			-- Create textures.
			spellTextures[i] = spellButtons[i]:CreateTexture(nil, "BORDER")
		end
		-- Create level strings
		for i = 1, NBR_OF_SPELL_ROWS do
			levelStrings[i] = FieldGuideFrame:CreateFontString(nil, "ARTWORK", "FieldGuideLevelStringTemplate")
			levelStrings[i]:SetPoint("TOPLEFT", LEVEL_STRING_X_START, -LEVEL_STRING_Y_START - (Y_SPACING * i))
			levelStrings[i]:SetText("Level " .. currentMinLevel + ((i - 1) * 2))
		end
	end
	FieldGuideFrameSlider:SetMinMaxValues(0, 30 - NBR_OF_SPELL_ROWS) -- If we show 5 spell rows, the scroll max value should be 25 (it scrolls to 25th row, and shows the last 5 already).
	FieldGuide_UpdateButtons(self, 1)
	tinsert(UISpecialFrames, FieldGuideFrame:GetName())
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

-- Returns true if player is honored with any faction.
local function getRepModifier()
	local honored = false
	if UnitFactionGroup("player") == "Horde" then
		honored = select(3, GetFactionInfoByID(530)) > 5 or select(3, GetFactionInfoByID(76)) > 5 or select(3, GetFactionInfoByID(81)) > 5 or select(3, GetFactionInfoByID(68)) > 5
	else
		honored = select(3, GetFactionInfoByID(69)) > 5 or select(3, GetFactionInfoByID(54)) > 5 or select(3, GetFactionInfoByID(47)) > 5 or select(3, GetFactionInfoByID(72)) > 5
	end
	return honored and 0.9 or 1
end

-- Is called whenever user scrolls with mouse wheel or presses up/down buttons.
function FieldGuide_UpdateButtons(self, value)
	-- Fix slider.
	local currentValue = FieldGuideFrameSlider:GetValue()
	FieldGuideFrameSlider:SetValue(currentValue - value)
	-- Fix level strings and spell buttons.
	-- If previous level would be < 2 or next level would be > 52, set level to 2 and 52 respectively, otherwise reduce/increase all levels by 2 (value will be -1 or 1 depending on if player scrolled up or down).
	-- TODO: make this dynamic ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	currentMinLevel = currentMinLevel - (value * 2) < 2 and 2 or currentMinLevel - (value * 2) > 52 and 52 or currentMinLevel - (value * 2)
	-- Hide all buttons.
	for index, button in pairs(spellButtons) do
		button:Hide()
	end
	local counter = 1
	local lastSpellIndex = 0
	for i = 1, NBR_OF_SPELL_ROWS do
		local currentLevel = currentMinLevel + (i - 1) * 2
		levelStrings[i]:SetText("Level " .. currentLevel)
		for spellIndex, spellInfo in ipairs(FieldGuideMageSpells[currentLevel]) do
			spellTextures[counter]:SetTexture(spellInfo["texture"])
			spellTextures[counter]:SetAllPoints()
			spellButtons[counter]:SetID(spellInfo["id"]) -- Hacky way to show price in tooltip.
			spellPrices[spellInfo["id"]] = spellInfo["cost"]
			spellButtons[counter]:Show()
			counter = counter + 1
			lastSpellIndex = spellIndex
		end
		counter = counter + 13 - lastSpellIndex -- Skip the rest of the buttons on the row if there are no more spells for that level.
	end
end

-- Is called whenever the value of the slider changes.
function FieldGuide_OnValueChanged(self, value)
	value = math.floor(value)
	self:SetValue(value)
	if value < 1 then
		_G[self:GetName() .. "ScrollUpButton"]:Disable()
	elseif value >= select(2, FieldGuideFrameSlider:GetMinMaxValues()) then
		_G[self:GetName() .. "ScrollDownButton"]:Disable()
	else
		_G[self:GetName() .. "ScrollUpButton"]:Enable()
		_G[self:GetName() .. "ScrollDownButton"]:Enable()
	end
end

-- Called whenever player mouses over an icon.
function FieldGuideSpellButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetHyperlink("spell:" .. self:GetID())
	local canAfford = GetMoney() < spellPrices[self:GetID()] and "|cFFFF0000" or "|cFFFFFFFF" -- Modifies string to be red if player can't afford, white otherwise.
	local priceString = GetCoinTextureString(spellPrices[self:GetID()] * getRepModifier())
	GameTooltip:AddLine("\nPrice: " .. canAfford .. priceString, nil, nil, nil, 1)
	GameTooltip:Show()
end

-- Called whenever player moves mouse out of an icon.
function FieldGuideSpellButton_OnLeave(self)
	GameTooltip:Hide()
end

-- Called whenever player opens the window.
function FieldGuide_OnShow()
	PlaySound(SOUNDKIT.IG_SPELLBOOK_OPEN);
end

-- Called whenever player closes the window.
function FieldGuide_OnHide()
	PlaySound(SOUNDKIT.IG_SPELLBOOK_CLOSE);
end

-- Run when addon has loaded.
function FieldGuide_OnLoad(self)
	self:RegisterForDrag("LeftButton")
	initSlash()
	initFrames()
	print("FieldGuide loaded!")
end