function initGui()
	-- Setup frame.
	FieldGuideFrame:SetWidth(354)
	FieldGuideFrame:SetHeight(440)
	FieldGuideFrame:SetPoint("CENTER", 0, 0)
	FieldGuideFrame:SetMovable(true)
	FieldGuideFrame:EnableMouse(true)
	FieldGuideFrame:RegisterForDrag("LeftButton")
	FieldGuideFrame:SetClampedToScreen(true)
	FieldGuideFrame:SetScript("OnDragStart", FieldGuideFrame.StartMoving)
	FieldGuideFrame:SetScript("OnDragStop", FieldGuideFrame.StopMovingOrSizing)
	
	-- Create textures --
	-- Top left texture.
	FieldGuideTopLeftTexture = FieldGuideFrame:CreateTexture("FieldGuideFrame", "ARTWORK")
	FieldGuideTopLeftTexture:SetTexture("Interface/SPELLBOOK/UI-SpellbookPanel-TopLeft")
	FieldGuideTopLeftTexture:SetPoint("TOPLEFT")
	-- Top right texture.
	FieldGuideTopRightTexture = FieldGuideFrame:CreateTexture("FieldGuideFrame", "ARTWORK")
	FieldGuideTopRightTexture:SetTexture("Interface/SPELLBOOK/UI-SpellbookPanel-TopRight")
	FieldGuideTopRightTexture:SetPoint("TOPRIGHT", 30, 0)
	-- Bottom right texture.
	FieldGuideBottomRightTexture = FieldGuideFrame:CreateTexture("FieldGuideFrame", "ARTWORK")
	FieldGuideBottomRightTexture:SetTexture("Interface/SPELLBOOK/UI-SpellbookPanel-BotRight")
	FieldGuideBottomRightTexture:SetPoint("BOTTOMRIGHT", 30, -72)
	-- Bottom left texture.
	FieldGuideBottomLeftTexture = FieldGuideFrame:CreateTexture("FieldGuideFrame", "ARTWORK")
	FieldGuideBottomLeftTexture:SetTexture("Interface/SPELLBOOK/UI-SpellbookPanel-BotLeft")
	FieldGuideBottomLeftTexture:SetPoint("BOTTOMLEFT", 0, -72)
	-- Spellbook top left image.
	FieldGuideSpellbookIconTexture = FieldGuideFrame:CreateTexture("FieldGuideFrame", "BACKGROUND")
	FieldGuideSpellbookIconTexture:SetTexture("Interface/SPELLBOOK/Spellbook-Icon")
	FieldGuideSpellbookIconTexture:SetSize(58, 58)
	FieldGuideSpellbookIconTexture:SetPoint("TOPLEFT", 10, -8)
	
	-- Create buttons --
	-- Next page button.
	FieldGuideSpellbookNextButton = CreateFrame("Button", "FieldGuideFrameSpellbookNextButton", FieldGuideFrame)
	FieldGuideSpellbookNextButton:SetNormalTexture("Interface/BUTTONS/UI-SpellbookIcon-NextPage-Up")
	FieldGuideSpellbookNextButton:SetPushedTexture("Interface/BUTTONS/UI-SpellbookIcon-NextPage-Down")
	FieldGuideSpellbookNextButton:SetDisabledTexture("Interface/BUTTONS/UI-SpellbookIcon-NextPage-Disabled")
	FieldGuideSpellbookNextButton:SetSize(32, 32)
	FieldGuideSpellbookNextButton:SetEnabled(false)
	FieldGuideSpellbookNextButton:SetPoint("CENTER", "FieldGuideFrame", "BOTTOMRIGHT", -40, 33)
	
	-- Previous page button.
	FieldGuideSpellbookPrevButton = CreateFrame("Button", "FieldGuideFrameSpellbookPrevButton", FieldGuideFrame)
	FieldGuideSpellbookPrevButton:SetNormalTexture("Interface/BUTTONS/UI-SpellbookIcon-PrevPage-Up")
	FieldGuideSpellbookPrevButton:SetPushedTexture("Interface/BUTTONS/UI-SpellbookIcon-PrevPage-Down")
	FieldGuideSpellbookPrevButton:SetDisabledTexture("Interface/BUTTONS/UI-SpellbookIcon-PrevPage-Disabled")
	FieldGuideSpellbookPrevButton:SetSize(32, 32)
	FieldGuideSpellbookPrevButton:SetEnabled(false)
	FieldGuideSpellbookPrevButton:SetPoint("CENTER", "FieldGuideFrame", "BOTTOMLEFT", 50, 33)
	
	-- Close button.
	FieldGuideSpellbookCloseButton = CreateFrame("Button", "FieldGuideFrameSpellbookCloseButton", FieldGuideFrame, "UIPanelCloseButton")
	FieldGuideSpellbookCloseButton:SetPoint("CENTER", "FieldGuideFrame", "TOPRIGHT", -14, -25)
	
	-- Create FontStrings --
	
	
	FieldGuideFrame:Show()
end

function initSlash()
	SLASH_FIELDGUIDE1 = "/FieldGuide"
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