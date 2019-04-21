-- TODO:
-- 1. Scrape https://classic.wowhead.com/mage-abilities and save in file
-- 2. Add class icon in top right corner
-- 2.5. Add crenelations to scroll bar (tiny ones)
-- page up/down
-- 2.75. Reuse frames/textures for when user wants to change class etc.
-- 2.9. Add right click functionality so that when user right clicks, it marks the spell for not learning/learning? Or something similar coolish
-- 3. Change Slider max value to dynamic value
-- 4. Add price fontstrings (maybe fancy coin icon)
-- 5. Add option (somewhere/somehow) to hide known spells (or maybe just hide any spells before current level) - IsSpellKnown(spellId, isPetSpell)
-- 6. Add option (somewhere/somehow) to show other classes spells
-- 7. Add option (somewhere/somehow) to filter between certain levels?
-- 8. Add option (somewhere/somehow) to search for a certain spell
-- 11. At some point in the future, port to 1.12?
-- ?. Add to interface/addons options?

-- BUGS:
-- Highlighting over scroll up and down buttons is too big

local BUTTON_X_START = 7 -- How far to the right the buttons start.
local BUTTON_Y_START = -45 -- How far down the buttons start.
local BUTTON_X_SPACING = 45 -- The spacing between all buttons in x.
local LEVEL_STRING_X_START = 35 -- How far to the right the level strings are placed.
local LEVEL_STRING_Y_START = -70 -- How far down the level strings are placed.
local Y_SPACING = 40 -- The spacing between all elements in y.
local MAX_SCROLL = 0
local SCROLL_AMOUNT = 0

local function initContent()
	local levelCounter = 0
	for level, spell in pairs(FieldGuideMageSpells) do -- For every level do:
		levelCounter = levelCounter + 1
		-- Level FontString.
		local levelString = FieldGuideContentFrame:CreateFontString(nil, "ARTWORK", "FieldGuideLevelStringTemplate")
		levelString:SetText("Level " .. level)
		levelString:SetPoint("TOPLEFT", LEVEL_STRING_X_START, -LEVEL_STRING_Y_START - (level * Y_SPACING))
		for spellIndex, spellInfo in pairs(spell) do -- For every spell available at level X do:
			-- Spell icon button.
			local button = CreateFrame("Button", nil, FieldGuideContentFrame, "FieldGuideSpellButtonTemplate")
			local iconTexture = button:CreateTexture(nil, "BORDER")
			iconTexture:SetTexture(spellInfo["Texture"])
			iconTexture:SetAllPoints()
			button:SetID(spellInfo["ID"]) -- Hacky way of making tooltips work.
			button:SetPoint("TOPLEFT", (BUTTON_X_SPACING * spellIndex) - BUTTON_X_START, -BUTTON_Y_START - (Y_SPACING * level))
		end
	end
	--(AMOUNT_OF_ROWS + (AMOUNT_OF_ROWS / 2 + (5)) * SPACE_BETWEEN_EACH_ELEMENT
	MAX_SCROLL = (levelCounter * 2 - (FieldGuideFrameScrollFrame:GetHeight() / 40.6)) * Y_SPACING -- 40.6 is the magic number (each level row is roughly 40.6 pixels – I think).
	SCROLL_AMOUNT = MAX_SCROLL / (MAX_SCROLL / (Y_SPACING * 2)) -- Why does this work?
	FieldGuideFrameScrollFrameSlider:SetMinMaxValues(0, MAX_SCROLL)
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

function FieldGuideScrollUp_OnClick(self, up)
	local currentValue = FieldGuideFrameScrollFrameSlider:GetValue()
	FieldGuideFrameScrollFrameSlider:SetValue(up and currentValue + SCROLL_AMOUNT or currentValue - SCROLL_AMOUNT)
end

function FieldGuide_OnValueChanged(self)
	local currentValue = self:GetValue()
	self:GetParent():SetVerticalScroll(currentValue)
	if currentValue <= 0 then
		_G[self:GetName() .. "ScrollUpButton"]:Disable()
	elseif currentValue >= MAX_SCROLL then
		_G[self:GetName() .. "ScrollDownButton"]:Disable()
	else
		_G[self:GetName() .. "ScrollUpButton"]:Enable()
		_G[self:GetName() .. "ScrollDownButton"]:Enable()
	end
end

function FieldGuide_OnMouseWheel(self, delta)
	local currentValue = FieldGuideFrameScrollFrameSlider:GetValue()
	FieldGuideFrameScrollFrameSlider:SetValue(currentValue - delta * SCROLL_AMOUNT) -- Why does this work?
end

function FieldGuide_OnLoad(self)
	self:RegisterForDrag("LeftButton")
	initContent()
	initSlash()
	FieldGuideFrame:Show()
	print("FieldGuide loaded!")
end