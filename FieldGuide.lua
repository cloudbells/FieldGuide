-- TODO:
-- 1. Scrape https://classic.wowhead.com/mage-abilities and save in file
-- 2. Add class icon in top right corner
-- 2.5. Add crenelations to scroll bar (tiny ones)
-- page up/down
-- 2.75. Reuse frames/textures for when user wants to change class etc.
-- 2.9. Add right click functionality so that when user right clicks, it marks the spell for not learning/learning? Or something similar coolish
-- 3. Change Slider max value to dynamic value
-- 4. Add price fontstrings (maybe fancy coin icon)
-- 5. Add option (somewhere/somehow) to hide known spells (or maybe just hide any spells before current level)
-- 6. Add option (somewhere/somehow) to show other classes spells
-- 7. Add option (somewhere/somehow) to filter between certain levels?
-- 8. Add option (somewhere/somehow) to search for a certain spell
-- 11. At some point in the future, port to 1.12?
-- ?. Add to interface/addons options?

local Y_SPACING = 30 -- The spacing between all elements in y.
local BUTTON_X_SPACING = 45 -- The spacing between all buttons in x.
local BUTTON_X_START = -35 -- The x adjustment for setting start position closer to level strings.
local LEVEL_STRING_Y_START = 40 -- The start position from top left corner for level string list in y.
local LEVEL_STRING_X_START = 30 -- The start position from top left corner for level string list in x.

local function initContent()
	for level, spell in pairs(FieldGuideMageSpells) do -- For every level do:
		-- Level FontString.
		local levelString = FieldGuideContentFrame:CreateFontString(nil, "ARTWORK", "FieldGuideLevelStringTemplate")
		levelString:SetText("Level " .. level)
		levelString:SetPoint("TOPLEFT", LEVEL_STRING_X_START, LEVEL_STRING_Y_START - (level * Y_SPACING))
		for spellIndex, spellInfo in pairs(spell) do -- For every spell available at level X do:
			-- Spell icon button.
			local button = CreateFrame("Button", nil, FieldGuideContentFrame, "FieldGuideSpellButtonTemplate")
			local iconTexture = button:CreateTexture(nil, "BORDER")
			iconTexture:SetTexture(spellInfo["Texture"])
			iconTexture:SetAllPoints()
			button:SetID(spellInfo["ID"]) -- Hacky way of making tooltips work.
			button:SetPoint("LEFT", levelString, "RIGHT", BUTTON_X_START + (level < 10 and spellIndex * BUTTON_X_SPACING + 10 or spellIndex * BUTTON_X_SPACING), 0)
		end
	end
	FieldGuideFrameScrollFrameSlider:SetMinMaxValues(0, 1345)
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

function FieldGuide_OnMouseWheel(self, delta)
	local currentValue = FieldGuideFrameScrollFrameSlider:GetValue()
	local _, maxValue = FieldGuideFrameScrollFrameSlider:GetMinMaxValues()
	FieldGuideFrameScrollFrameSlider:SetValue(currentValue - delta * (maxValue/15))
end

function FieldGuide_OnLoad(self)
	self:RegisterForDrag("LeftButton")
	initContent()
	initSlash()
	FieldGuideFrame:Show()
	print("FieldGuide loaded!")
end