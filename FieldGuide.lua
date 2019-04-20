-- TODO:
-- 1. Scrape https://classic.wowhead.com/mage-abilities and save in file
-- 2. Add class icon in top right corner
-- 3. Change Slider max value to dynamic value
-- 4. Add price fontstrings (maybe fancy coin icon)
-- 5. Add option (somewhere/somehow) to hide known spells (or maybe just hide any spells before current level)
-- 6. Add option (somewhere/somehow) to show other classes spells
-- 7. Add option (somewhere/somehow) to filter between certain levels?
-- 8. Add option (somewhere/somehow) to search for a certain spell
-- 11. At some point in the future, port to 1.12?
-- ?. Add to interface/addons options?

local function initContent()
	for level, spell in pairs(FieldGuideMageSpells) do -- For every level do:
		-- Level FontString.
		local levelString = FieldGuideContentFrame:CreateFontString(nil, "ARTWORK", "FieldGuideLevelStringTemplate")
		levelString:SetText("Level " .. level)
		levelString:SetPoint("TOPLEFT", 30, 40 - (level * 30))
		for spellIndex, spellInfo in pairs(spell) do -- For every spell available at level X do:
			-- Spell icon button.
			local button = CreateFrame("Button", nil, FieldGuideContentFrame, "FieldGuideSpellButtonTemplate")
			local iconTexture = button:CreateTexture(nil, "BORDER")
			iconTexture:SetTexture(spellInfo["Texture"])
			iconTexture:SetAllPoints()
			button:SetID(spellInfo["ID"]) -- Hacky way of making tooltips work.
			-- If level < 10 the buttons should be spaced more to the right, otherwise only spellIndex * 45.
			button:SetPoint("RIGHT", levelString, "RIGHT", level < 10 and spellIndex * 45 + 10 or spellIndex * 45, 0)
		end
	end
end

-- Sets slash commands.
local function initSlash()
	SLASH_FIELDGUIDE1 = "/FieldGuide"
	SLASH_FIELDGUIDE2 = "/fg"
	SlashCmdList["FIELDGUIDE"] =
		function()
			if FieldGuideFrame:IsVisible() then
				FieldGuideFrame:Hide()
			else
				FieldGuideFrame:Show()
			end
		end
end

function FieldGuide_OnMouseWheel(self, delta)
	local currentValue = FieldGuideScrollFrameSlider:GetValue()
	local _, maxValue = FieldGuideScrollFrameSlider:GetMinMaxValues()
	FieldGuideScrollFrameSlider:SetValue(currentValue - delta * (maxValue/15)) -- FIX TO DYNAMICALLY CHANGE--------------------------------------------------------------------------------------------------------------------------------------------------------
end

function FieldGuide_OnLoad(self)
	self:RegisterForDrag("LeftButton")
	initContent()
	initSlash()
	FieldGuideFrame:Show()
	print("FieldGuide loaded!")
end