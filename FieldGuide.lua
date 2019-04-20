-- TODO:
-- 1. Scrape https://classic.wowhead.com/mage-abilities and save in file
-- 2. Add scroll (read the book)
-- 3. Add level fontstrings
-- 4. Add price fontstrings (maybe fancy coin icon)
-- 5. Add option (somewhere/somehow) to hide known spells (or maybe just hide any spells before current level)
-- 6. Add option (somewhere/somehow) to show other classes spells
-- 7. Add option (somewhere/somehow) to filter between certain levels?
-- 8. Add option (somewhere/somehow) to search for a certain spell
-- 9. Make it so that it can't be moved, and it loads in the same place as achievement tab and also make it "push out" other frames or close them, to mimic real Blizzard UI
-- 10. At some point, make UI in XML
-- 11. At some point in the future, port to 1.12?
-- ?. Add to interface/addons options?

-- Initializes all spell buttons.
local function initButtons()
	for level, spell in pairs(FieldGuideMageSpells) do
		for spellIndex, spellInfo in pairs(spell) do
			local button = CreateFrame("Button", "FieldGuideSpellButton" .. level .. spellIndex, FieldGuideContentFrame, "FieldGuideSpellButtonTemplate")
			local spellTexture = _G["FieldGuideSpellButton" .. level .. spellIndex .. "IconTexture"]
			button:SetID(spellInfo["ID"])
			spellTexture:SetTexture(spellInfo["Texture"])
			spellTexture:Show()
			button:SetPoint("TOPLEFT", (spellIndex * 45) + 10, 50 - (level * 30))
		end
	end
end

-- Sets slash commands.
local function initSlash()
	SLASH_FIELDGUIDE1 = "/FieldGuide"
	SLASH_FIELDGUIDE2 = "/fg"
	SlashCmdList["FIELDGUIDE"] =
		function()
			if FieldGuideScrollFrame:IsVisible() then
			else
				FieldGuideScrollFrame:Hide()
				FieldGuideScrollFrame:Show()
			end
		end
end

function FieldGuide_OnMouseWheel(self, delta)
	local currentValue = FieldGuideScrollFrameSlider:GetValue()
	print(currentValue)
	FieldGuideScrollFrameSlider:SetValue(currentValue - delta * 50)
end

function FieldGuide_OnLoad(self)
	self:RegisterForDrag("LeftButton")
	initButtons()
	FieldGuideScrollFrame:Show()
	initSlash()
	print("FieldGuide loaded!")
end