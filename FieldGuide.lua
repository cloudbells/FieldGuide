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
function initButtons()
	for level, spell in pairs(FieldGuideMageSpells) do
		for spellIndex, spellInfo in pairs(spell) do
			local button = CreateFrame("Button", "FieldGuideSpellButton" .. level .. spellIndex, FieldGuideFrame, "FieldGuideSpellButtonTemplate")
			local spellTexture = _G["FieldGuideSpellButton" .. level .. spellIndex .. "IconTexture"]
			button:SetID(spellInfo["ID"])
			spellTexture:SetTexture(spellInfo["Texture"])
			spellTexture:Show()
			button:SetPoint("TOPLEFT", "FieldGuideBackgroundTexture", "TOPLEFT", (spellIndex * 45) - 10, 30 - (level * 30))
		end
	end
end

-- Initializes all textures.
function initGui()
	-- Frame --
	FieldGuideFrame:SetWidth(768)
	FieldGuideFrame:SetHeight(500)
	FieldGuideFrame:SetPoint("CENTER", 0, 0)
	FieldGuideFrame:SetMovable(true)
	FieldGuideFrame:EnableMouse(true)
	FieldGuideFrame:RegisterForDrag("LeftButton")
	FieldGuideFrame:SetClampedToScreen(true)
	FieldGuideFrame:SetScript("OnDragStart", FieldGuideFrame.StartMoving)
	FieldGuideFrame:SetScript("OnDragStop", FieldGuideFrame.StopMovingOrSizing)
	FieldGuideFrame:SetBackdrop({
		edgeFile = "Interface/AchievementFrame/UI-Achievement-WoodBorder",
		edgeSize = 64
	})
	
	-- Textures (in draw order) --
	-- Background texture
	FieldGuideBackgroundTexture = FieldGuideFrame:CreateTexture("FieldGuideFrame", "BORDER")
	FieldGuideBackgroundTexture:SetTexture("Interface/ACHIEVEMENTFRAME/UI-GuildAchievement-AchievementBackground")
	FieldGuideBackgroundTexture:SetPoint("TOPLEFT", 16, -16)
	FieldGuideBackgroundTexture:SetPoint("BOTTOMRIGHT", -16, 16)
	
	-- Left border
	FieldGuideLeftBorderTexture = FieldGuideFrame:CreateTexture("FieldGuideFrame", "ARTWORK")
	FieldGuideLeftBorderTexture:SetTexture("Interface/ACHIEVEMENTFRAME/UI-Achievement-MetalBorder-Left")
	FieldGuideLeftBorderTexture:SetSize(16, 450)
	FieldGuideLeftBorderTexture:SetTexCoord(0, 1, 0, .87)
	FieldGuideLeftBorderTexture:SetPoint("LEFT", "FieldGuideFrame", "LEFT", 14, 0)
	
	-- Top border
	FieldGuideTopBorderTexture = FieldGuideFrame:CreateTexture("FieldGuideFrame", "ARTWORK")
	FieldGuideTopBorderTexture:SetTexture("Interface/ACHIEVEMENTFRAME/UI-Achievement-MetalBorder-Top")
	FieldGuideTopBorderTexture:SetSize(720, 16)
	FieldGuideTopBorderTexture:SetTexCoord(.87, 0, 0, 1)
	FieldGuideTopBorderTexture:SetPoint("TOPLEFT", 28, -12)
	FieldGuideTopBorderTexture:SetPoint("TOPRIGHT", -28, -12)
	
	-- Right border
	FieldGuideRightBorderTexture = FieldGuideFrame:CreateTexture("FieldGuideFrame", "ARTWORK")
	FieldGuideRightBorderTexture:SetTexture("Interface/ACHIEVEMENTFRAME/UI-Achievement-MetalBorder-Left")
	FieldGuideRightBorderTexture:SetSize(16, 450)
	FieldGuideRightBorderTexture:SetTexCoord(1, 0, .87, 0)
	FieldGuideRightBorderTexture:SetPoint("RIGHT", "FieldGuideFrame", "RIGHT", -13, 0)
	
	-- Bottom border
	FieldGuideBottomBorderTexture = FieldGuideFrame:CreateTexture("FieldGuideFrame", "ARTWORK")
	FieldGuideBottomBorderTexture:SetTexture("Interface/ACHIEVEMENTFRAME/UI-Achievement-MetalBorder-Top")
	FieldGuideBottomBorderTexture:SetSize(720, 16)
	FieldGuideBottomBorderTexture:SetTexCoord(0, .87, 1.0, 0)
	FieldGuideBottomBorderTexture:SetPoint("BOTTOMLEFT", 28, 13)
	FieldGuideBottomBorderTexture:SetPoint("BOTTOMRIGHT", -28, 13)
	
	-- Crenelation top left
	FieldGuideTopLeftCrenTexture = FieldGuideFrame:CreateTexture("FieldGuideFrame", "OVERLAY", nil, 1)
	FieldGuideTopLeftCrenTexture:SetTexture("Interface/ACHIEVEMENTFRAME/UI-Achievement-WoodBorder-Corner")
	FieldGuideTopLeftCrenTexture:SetSize(64, 64)
	FieldGuideTopLeftCrenTexture:SetTexCoord(0, 1, 0, 1)
	FieldGuideTopLeftCrenTexture:SetPoint("TOPLEFT", 4, -2)
	
	-- Crenelation top right
	FieldGuideTopRightCrenTexture = FieldGuideFrame:CreateTexture("FieldGuideFrame", "OVERLAY", nil, 1)
	FieldGuideTopRightCrenTexture:SetTexture("Interface/ACHIEVEMENTFRAME/UI-Achievement-WoodBorder-Corner")
	FieldGuideTopRightCrenTexture:SetSize(64, 64)
	FieldGuideTopRightCrenTexture:SetTexCoord(1, 0, 0, 1)
	FieldGuideTopRightCrenTexture:SetPoint("TOPRIGHT", -4, -2)
	
	-- Crenelation bottom right
	FieldGuideBottomRightCrenTexture = FieldGuideFrame:CreateTexture("FieldGuideFrame", "OVERLAY", nil, 1)
	FieldGuideBottomRightCrenTexture:SetTexture("Interface/ACHIEVEMENTFRAME/UI-Achievement-WoodBorder-Corner")
	FieldGuideBottomRightCrenTexture:SetSize(64, 64)
	FieldGuideBottomRightCrenTexture:SetTexCoord(1, 0, 1, 0)
	FieldGuideBottomRightCrenTexture:SetPoint("BOTTOMRIGHT", -4, 3)
	
	-- Crenelation bottom left
	FieldGuideBottomLeftCrenTexture = FieldGuideFrame:CreateTexture("FieldGuideFrame", "OVERLAY", nil, 1)
	FieldGuideBottomLeftCrenTexture:SetTexture("Interface/ACHIEVEMENTFRAME/UI-Achievement-WoodBorder-Corner")
	FieldGuideBottomLeftCrenTexture:SetSize(64, 64)
	FieldGuideBottomLeftCrenTexture:SetTexCoord(0, 1, 1, 0)
	FieldGuideBottomLeftCrenTexture:SetPoint("BOTTOMLEFT", 4, 3)
	
	-- Top left corner border
	FieldGuideTopLeftCornerBorderTexture = FieldGuideFrame:CreateTexture("FieldGuideFrame", "OVERLAY", nil, 2)
	FieldGuideTopLeftCornerBorderTexture:SetTexture("Interface/ACHIEVEMENTFRAME/UI-Achievement-MetalBorder-Joint")
	FieldGuideTopLeftCornerBorderTexture:SetSize(32, 32)
	FieldGuideTopLeftCornerBorderTexture:SetTexCoord(1, 0, 1, 0)
	FieldGuideTopLeftCornerBorderTexture:SetPoint("TOPLEFT", 9, -7)
	
	-- Top right corner border
	FieldGuideTopRightCornerBorderTexture = FieldGuideFrame:CreateTexture("FieldGuideFrame", "OVERLAY", nil, 2)
	FieldGuideTopRightCornerBorderTexture:SetTexture("Interface/ACHIEVEMENTFRAME/UI-Achievement-MetalBorder-Joint")
	FieldGuideTopRightCornerBorderTexture:SetSize(32, 32)
	FieldGuideTopRightCornerBorderTexture:SetTexCoord(0, 1, 1, 0)
	FieldGuideTopRightCornerBorderTexture:SetPoint("TOPRIGHT", -8, -7)
	
	-- Bottom right corner border
	FieldGuideBottomRightCornerBorderTexture = FieldGuideFrame:CreateTexture("FieldGuideFrame", "OVERLAY", nil, 2)
	FieldGuideBottomRightCornerBorderTexture:SetTexture("Interface/ACHIEVEMENTFRAME/UI-Achievement-MetalBorder-Joint")
	FieldGuideBottomRightCornerBorderTexture:SetSize(32, 32)
	FieldGuideBottomRightCornerBorderTexture:SetTexCoord(0, 1, 0, 1)
	FieldGuideBottomRightCornerBorderTexture:SetPoint("BOTTOMRIGHT", -8, 8)
	
	-- Bottom left corner border
	FieldGuideBottomLeftCornerBorderTexture = FieldGuideFrame:CreateTexture("FieldGuideFrame", "OVERLAY", nil, 2)
	FieldGuideBottomLeftCornerBorderTexture:SetTexture("Interface/ACHIEVEMENTFRAME/UI-Achievement-MetalBorder-Joint")
	FieldGuideBottomLeftCornerBorderTexture:SetSize(32, 32)
	FieldGuideBottomLeftCornerBorderTexture:SetTexCoord(1, 0, 0, 1)
	FieldGuideBottomLeftCornerBorderTexture:SetPoint("BOTTOMLEFT", 9, 8)
	
	-- Create scroll frame for containing buttons
	FieldGuideScrollFrame = CreateFrame("ScrollFrame", "FieldGuideScrollFrame", FieldGuideFrame)
	-- I AM HERE -----------------------------------------------------------------------------------------------------------------------------------------------------!!!!!--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	initButtons()
	FieldGuideFrame:Show()
end

-- Sets slash commands.
function initSlash()
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

FieldGuideFrame = CreateFrame("Frame", "FieldGuideFrame", UIParent)
FieldGuideFrame:RegisterEvent("ADDON_LOADED")
FieldGuideFrame:SetScript("OnEvent", 
	function(self, event, ...)
		if (event == "ADDON_LOADED") then
			if (select(1, ...) == "FieldGuide") then
				initGui()
				initSlash()
				print("FieldGuide loaded!")
			end
		end
	end
)