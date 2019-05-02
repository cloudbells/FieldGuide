-- TODO:
-- 2. Add class icon in top right corner
-- 2.75. Reuse frames/textures for when user wants to change class etc. - make as many as the class with the most spells, then reuse these
-- 2.9. Add right click functionality so that when user right clicks, it marks the spell for not learning/learning? Or something similar coolish - and calculate total cost of non-marked ones
-- 4. Add price fontstrings (maybe fancy coin icon)
-- 5. Add option (somewhere/somehow) to hide known spells (or maybe just hide any spells before current level) - IsSpellKnown(spellId, isPetSpell)
-- 6. Add option (somewhere/somehow) to show other classes spells
-- 7. Add option (somewhere/somehow) to filter between certain levels?
-- 8. Add option (somewhere/somehow) to search for a certain spell
-- 11. At some point in the future, port to 1.12?
-- ?. Add to interface/addons options?
-- Some spells are only for horde etc, fix
-- option to show talents or not
-- mark talents
-- Maybe add icons for tomes/quests after lvl 60?
-- add close button top right
-- scale costs with friendly5%/honored10%/rank 3+10%? - check on pserver
-- sort spells by cost/spec
-- eventually, change so that we dont make 100000 fontstrings, instead make 1 and anchor it to bottom of currently hovered icon

-- BUGS:
-- Highlighting over scroll up and down buttons is too big

local BUTTON_X_START = 37 -- How far to the right the buttons start.
local BUTTON_Y_START = -32 -- How far down the buttons start.
local BUTTON_X_SPACING = 45 -- The spacing between all buttons in x.
local LEVEL_STRING_X_START = 35 -- How far to the right the level strings are placed.
local LEVEL_STRING_Y_START = -55 -- How far down the level strings are placed.
local Y_SPACING = 0 -- The spacing between all elements in y.
local SCROLL_AMOUNT = 0
local NBR_OF_SPELL_ROWS = 5

local levelStrings = {}
local spellButtons = {}
local priceString = nil

local lastValue = 0

local function initFrames()
	if #spellButtons == 0 or #levelStrings == 0 then
		local nbrOfFrames = math.floor((FieldGuideFrame:GetWidth() - (BUTTON_X_START * 2)) / BUTTON_X_SPACING) * NBR_OF_SPELL_ROWS
		Y_SPACING = math.ceil(FieldGuideFrame:GetHeight() / NBR_OF_SPELL_ROWS) / 1.125
		-- GC any potential old frames?
		spellButtons = {}
		levelStrings = {}
		-- Create frames.
		for i = 1, nbrOfFrames do
			local spellButton = CreateFrame("BUTTON", nil, FieldGuideFrame, "FieldGuideSpellButtonTemplate")
			local n = nbrOfFrames / NBR_OF_SPELL_ROWS -- The number of buttons in x.
			local spellBtnX = BUTTON_X_START + BUTTON_X_SPACING * (i < n and i or i - math.floor(i / n) * n)
			local spellBtnY = -Y_SPACING * math.ceil(i / n) - BUTTON_Y_START
			spellButton:SetPoint("TOPLEFT", spellBtnX, spellBtnY)
			--spellButton:Hide()
			spellButtons[i] = spellButton
			-- Create price string.
			priceString = spellButton:CreateFontString("FieldGuidePriceString" .. i, "ARTWORK", "FieldGuideCostStringTemplate")
			priceString:SetPoint("BOTTOMLEFT", -2, -20)
		end
		-- Create level strings
		for i = 1, NBR_OF_SPELL_ROWS do
			local levelString = FieldGuideFrame:CreateFontString(nil, "ARTWORK", "FieldGuideLevelStringTemplate")
			levelString:SetPoint("TOPLEFT", LEVEL_STRING_X_START, -LEVEL_STRING_Y_START - (Y_SPACING * i))
			levelString:SetText("Level 10")
			--levelString:Hide()
			levelStrings[i] = levelString
		end
	end
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

-- Is called whenever user scrolls with mouse wheel or presses up/down buttons.
function FieldGuide_UpdateButtons(self, value)
	local currentValue = FieldGuideFrameSlider:GetValue()
	FieldGuideFrameSlider:SetValue(currentValue - value)
	for k, v in pairs(spellButtons) do
		-- Update each spell button here.
	end
end

-- Is called whenever user drags the scroll thumb manually.
function FieldGuide_OnValueChanged(self, value)
	value = math.floor(value)
	if value >= lastValue + 1 then
		lastValue = value
	elseif value < lastValue then
		lastValue = value
	end
	self:SetValue(value)
	if value < 1 then
		_G[self:GetName() .. "ScrollUpButton"]:Disable()
	elseif value >= 30 then
		_G[self:GetName() .. "ScrollDownButton"]:Disable()
	else
		_G[self:GetName() .. "ScrollUpButton"]:Enable()
		_G[self:GetName() .. "ScrollDownButton"]:Enable()
	end
end

-- Called whenever player mouses over an icon.
function FieldGuideSpellButton_OnEnter(self)
	_G["FieldGuidePriceString" .. self:GetID()]:Show()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetHyperlink("spell:" .. self:GetID())
end

function FieldGuideSpellButton_OnLeave(self)
	GameTooltip:Hide()
	_G["FieldGuideCostString" .. self:GetID()]:Hide()
end

-- Run when addon has loaded.
function FieldGuide_OnLoad(self)
	self:RegisterForDrag("LeftButton")
	--initContent()
	initSlash()
	initFrames()
	FieldGuideFrame:Show()
	print("FieldGuide loaded!")
end