--[[--------------------------------------------------------------------
	!ClassColors - Enhanced for Dual Classes
	Change class colors without breaking the Blizzard UI.
	Enhanced version with support for dual class combinations.
----------------------------------------------------------------------]]

local _, ns = ...
if CUSTOM_CLASS_COLORS then
	ns.alreadyLoaded = true
	return
end

------------------------------------------------------------------------

local L = {
	TITLE = GetAddOnMetadata("!ClassColors", "Title"),
	NOTES = GetAddOnMetadata("!ClassColors", "Notes"),
	NOTES_DESC = "Note that not all addons support this, and you may need to reload the UI before your changes are recognized by all compatible addons.",
	RESET = RESET,
	RESET_DESC = "Reset all class colors to their Blizzard defaults.",
}

do
	local GAME_LOCALE = GetLocale()
	if GAME_LOCALE == "deDE" then
		L.NOTES_DESC = "Beachten Sie, dass nicht alle Addons dieses System unterstützen, und möglicherweise müssen Sie die UI neuladen, um die Änderungen zu alle kompatiblen Addons übernehmen."
		L.RESET_DESC = "Alle Klassenfarben auf die Standardfarben zurücksetzen."
	end
end

-- Fill localized class list for 3.3.5a compatibility
local function FillLocalizedClassList(tab, isFemale)
	local classList = isFemale and LOCALIZED_CLASS_NAMES_FEMALE or LOCALIZED_CLASS_NAMES_MALE
	for classToken, className in pairs(classList) do
		tab[className] = className
	end
end

FillLocalizedClassList(L, false)

------------------------------------------------------------------------

CUSTOM_CLASS_COLORS = {}

-- Dual class combinations - FULL TABLE FOR TESTING
-- This includes all 45 possible combinations of the 10 WoW classes
-- You can remove the ones your server doesn't have and rename them to match your server
local DUAL_CLASS_COMBINATIONS = {
	-- ===== WARRIOR COMBINATIONS (9) =====
	["CHAMPION"] = { class1 = "WARRIOR", class2 = "PALADIN", name = "Champion (Warrior + Paladin)" },
	["SOLDIER"] = { class1 = "WARRIOR", class2 = "HUNTER", name = "Soldier (Warrior + Hunter)" },
	["BLADEMASTER"] = { class1 = "WARRIOR", class2 = "ROGUE", name = "Blademaster (Warrior + Rogue)" },
	["CRUSADER"] = { class1 = "WARRIOR", class2 = "PRIEST", name = "Crusader (Warrior + Priest)" },
	["BUTCHER"] = { class1 = "WARRIOR", class2 = "DEATHKNIGHT", name = "Butcher (Warrior + Death Knight)" },
	["RAVAGER"] = { class1 = "WARRIOR", class2 = "SHAMAN", name = "Ravager (Warrior + Shaman)" },
	["BATTLEMAGE"] = { class1 = "WARRIOR", class2 = "MAGE", name = "Battlemage (Warrior + Mage)" },
	["VANQUISHER"] = { class1 = "WARRIOR", class2 = "WARLOCK", name = "Vanquisher (Warrior + Warlock)" },
	["BARBARIAN"] = { class1 = "WARRIOR", class2 = "DRUID", name = "Barbarian (Warrior + Druid)" },
	
	-- ===== PALADIN COMBINATIONS (8) =====
	["AVENGER"] = { class1 = "PALADIN", class2 = "HUNTER", name = "Avenger (Paladin + Hunter)" },
	["AGENT"] = { class1 = "PALADIN", class2 = "ROGUE", name = "Agent (Paladin + Rogue)" },
	["MARTYR"] = { class1 = "PALADIN", class2 = "PRIEST", name = "Martyr (Paladin + Priest)" },
	["ENFORCER"] = { class1 = "PALADIN", class2 = "DEATHKNIGHT", name = "Enforcer (Paladin + Death Knight)" },
	["SENTINEL"] = { class1 = "PALADIN", class2 = "SHAMAN", name = "Sentinel (Paladin + Shaman)" },
	["INQUISITOR"] = { class1 = "PALADIN", class2 = "MAGE", name = "Inquisitor (Paladin + Mage)" },
	["WARDEN"] = { class1 = "PALADIN", class2 = "WARLOCK", name = "Warden (Paladin + Warlock)" },
	["GUARDIAN"] = { class1 = "PALADIN", class2 = "DRUID", name = "Guardian (Paladin + Druid)" },
	
	-- ===== HUNTER COMBINATIONS (7) =====
	["SCOUT"] = { class1 = "HUNTER", class2 = "ROGUE", name = "Scout (Hunter + Rogue)" },
	["SEER"] = { class1 = "HUNTER", class2 = "PRIEST", name = "Seer (Hunter + Priest)" },
	["SLAYER"] = { class1 = "HUNTER", class2 = "DEATHKNIGHT", name = "Slayer (Hunter + Death Knight)" },
	["TEMPEST"] = { class1 = "HUNTER", class2 = "SHAMAN", name = "Tempest (Hunter + Shaman)" },
	["ARCANIST"] = { class1 = "HUNTER", class2 = "MAGE", name = "Arcanist (Hunter + Mage)" },
	["TRICKSTER"] = { class1 = "HUNTER", class2 = "WARLOCK", name = "Trickster (Hunter + Warlock)" },
	["RANGER"] = { class1 = "HUNTER", class2 = "DRUID", name = "Ranger (Hunter + Druid)" },
	
	-- ===== ROGUE COMBINATIONS (6) =====
	["HERALD"] = { class1 = "ROGUE", class2 = "PRIEST", name = "Herald (Rogue + Priest)" },
	["ASSASSIN"] = { class1 = "ROGUE", class2 = "DEATHKNIGHT", name = "Assassin (Rogue + Death Knight)" },
	["NINJA"] = { class1 = "ROGUE", class2 = "SHAMAN", name = "Ninja (Rogue + Shaman)" },
	["SPELLBLADE"] = { class1 = "ROGUE", class2 = "MAGE", name = "Spellblade (Rogue + Mage)" },
	["VOIDSTALKER"] = { class1 = "ROGUE", class2 = "WARLOCK", name = "Voidstalker (Rogue + Warlock)" },
	["SPY"] = { class1 = "ROGUE", class2 = "DRUID", name = "Spy (Rogue + Druid)" },
	
	-- ===== PRIEST COMBINATIONS (5) =====
	["WRAITH"] = { class1 = "PRIEST", class2 = "DEATHKNIGHT", name = "Wraith (Priest + Death Knight)" },
	["ORACLE"] = { class1 = "PRIEST", class2 = "SHAMAN", name = "Oracle (Priest + Shaman)" },
	["MYSTIC"] = { class1 = "PRIEST", class2 = "MAGE", name = "Mystic (Priest + Mage)" },
	["SIREN"] = { class1 = "PRIEST", class2 = "WARLOCK", name = "Siren (Priest + Warlock)" },
	["EMPATH"] = { class1 = "PRIEST", class2 = "DRUID", name = "Empath (Priest + Druid)" },
	
	-- ===== DEATH KNIGHT COMBINATIONS (4) =====
	["SUMMONER"] = { class1 = "DEATHKNIGHT", class2 = "SHAMAN", name = "Summoner (Death Knight + Shaman)" },
	["LICH"] = { class1 = "DEATHKNIGHT", class2 = "MAGE", name = "Lich (Death Knight + Mage)" },
	["NECROMANCER"] = { class1 = "DEATHKNIGHT", class2 = "WARLOCK", name = "Necromancer (Death Knight + Warlock)" },
	["DREADWEAVER"] = { class1 = "DEATHKNIGHT", class2 = "DRUID", name = "Dreadweaver (Death Knight + Druid)" },
	
	-- ===== SHAMAN COMBINATIONS (3) =====
	["ELEMENTALIST"] = { class1 = "SHAMAN", class2 = "MAGE", name = "Elementalist (Shaman + Mage)" },
	["HARBINGER"] = { class1 = "SHAMAN", class2 = "WARLOCK", name = "Harbinger (Shaman + Warlock)" },
	["SAGE"] = { class1 = "SHAMAN", class2 = "DRUID", name = "Sage (Shaman + Druid)" },
	
	-- ===== MAGE COMBINATIONS (2) =====
	["SORCERER"] = { class1 = "MAGE", class2 = "WARLOCK", name = "Sorcerer (Mage + Warlock)" },
	["CONJURER"] = { class1 = "MAGE", class2 = "DRUID", name = "Conjurer (Mage + Druid)" },
	
	-- ===== WARLOCK COMBINATIONS (1) =====
	["WITCH"] = { class1 = "WARLOCK", class2 = "DRUID", name = "Witch (Warlock + Druid)" },
}

-- Function to blend two colors
local function BlendColors(color1, color2, ratio)
	ratio = ratio or 0.5
	return {
		r = color1.r * (1 - ratio) + color2.r * ratio,
		g = color1.g * (1 - ratio) + color2.g * ratio,
		b = color1.b * (1 - ratio) + color2.b * ratio,
	}
end

-- Generate default colors for dual classes by blending
local function GenerateDualClassColor(class1, class2)
	local color1 = RAID_CLASS_COLORS[class1]
	local color2 = RAID_CLASS_COLORS[class2]
	if color1 and color2 then
		local blended = BlendColors(color1, color2, 0.5)
		blended.colorStr = format("ff%02x%02x%02x", blended.r * 255, blended.g * 255, blended.b * 255)
		return blended
	end
	return { r = 1, g = 1, b = 1, colorStr = "ffffffff" }
end

------------------------------------------------------------------------

local callbacks = {}
local numCallbacks = 0

local function RegisterCallback(self, method, handler)
	assert(type(method) == "string" or type(method) == "function", "Bad argument #1 to :RegisterCallback (string or function expected)")
	if type(method) == "string" then
		assert(type(handler) == "table", "Bad argument #2 to :RegisterCallback (table expected)")
		assert(type(handler[method]) == "function", "Bad argument #1 to :RegisterCallback (method \"" .. method .. "\" not found)")
		method = handler[method]
	end
	callbacks[method] = handler or true
	numCallbacks = numCallbacks + 1
end

local function UnregisterCallback(self, method, handler)
	assert(type(method) == "string" or type(method) == "function", "Bad argument #1 to :UnregisterCallback (string or function expected)")
	if type(method) == "string" then
		assert(type(handler) == "table", "Bad argument #2 to :UnregisterCallback (table expected)")
		assert(type(handler[method]) == "function", "Bad argument #1 to :UnregisterCallback (method \"" .. method .. "\" not found)")
		method = handler[method]
	end
	callbacks[method] = nil
	numCallbacks = numCallbacks - 1
end

local function DispatchCallbacks()
	if numCallbacks < 1 then return end
	for method, handler in pairs(callbacks) do
		local ok, err = pcall(method, handler ~= true and handler or nil)
		if not ok then
			print("ERROR:", err)
		end
	end
end

------------------------------------------------------------------------

-- Regular classes
local classes = {}
for class in pairs(RAID_CLASS_COLORS) do
	tinsert(classes, class)
end
sort(classes)

-- Dual classes
local dualClasses = {}
for dualClass in pairs(DUAL_CLASS_COMBINATIONS) do
	tinsert(dualClasses, dualClass)
end
sort(dualClasses)

local classTokens = {}
for token, class in pairs(LOCALIZED_CLASS_NAMES_MALE) do
	classTokens[class] = token
end
for token, class in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
	classTokens[class] = token
end

local function GetClassToken(self, className)
	return className and classTokens[className]
end

------------------------------------------------------------------------

local function NotifyChanges(self)
	local changed
	local db = ClassColorsDB

	-- Check regular classes
	for i = 1, #classes do
		local class = classes[i]
		local color = CUSTOM_CLASS_COLORS[class]
		local cache = db[class]

		if cache and color and (cache.r ~= color.r or cache.g ~= color.g or cache.b ~= color.b) then
			cache.r = color.r
			cache.g = color.g
			cache.b = color.b
			cache.colorStr = format("ff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
			changed = true
		end
	end

	-- Check dual classes
	for i = 1, #dualClasses do
		local class = dualClasses[i]
		local color = CUSTOM_CLASS_COLORS[class]
		local cache = db[class]

		if cache and color and (cache.r ~= color.r or cache.g ~= color.g or cache.b ~= color.b) then
			cache.r = color.r
			cache.g = color.g
			cache.b = color.b
			cache.colorStr = format("ff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
			changed = true
		end
	end

	if changed then
		DispatchCallbacks()
	end
end

------------------------------------------------------------------------

setmetatable(CUSTOM_CLASS_COLORS, { __index = function(t, k)
	if k == "GetClassToken" then return GetClassToken end
	if k == "NotifyChanges" then return NotifyChanges end
	if k == "RegisterCallback" then return RegisterCallback end
	if k == "UnregisterCallback" then return UnregisterCallback end
end })

------------------------------------------------------------------------

local f = CreateFrame("Frame", "ClassColorsOptions")
f.name = L.TITLE
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, addon)
	if addon ~= "!ClassColors" then return end

	--------------------------------------------------------------------

	local db
	if not ClassColorsDB then ClassColorsDB = {} end
	db = ClassColorsDB

	-- Initialize regular classes
	for i = 1, #classes do
		local class = classes[i]
		local color = RAID_CLASS_COLORS[class]
		local r, g, b = color.r, color.g, color.b
		local hex = format("ff%02x%02x%02x", r * 255, g * 255, b * 255)

		if not db[class] or not db[class].r or not db[class].g or not db[class].b then
			db[class] = { r = r, g = g, b = b, colorStr = hex }
		elseif not db[class].colorStr then
			db[class].colorStr = format("ff%02x%02x%02x", db[class].r * 255, db[class].g * 255, db[class].b * 255)
		end

		CUSTOM_CLASS_COLORS[class] = {
			r = db[class].r,
			g = db[class].g,
			b = db[class].b,
			colorStr = db[class].colorStr,
		}
	end

	-- Initialize dual classes
	for i = 1, #dualClasses do
		local dualClass = dualClasses[i]
		local combo = DUAL_CLASS_COMBINATIONS[dualClass]
		
		if not db[dualClass] then
			local defaultColor = GenerateDualClassColor(combo.class1, combo.class2)
			db[dualClass] = {
				r = defaultColor.r,
				g = defaultColor.g,
				b = defaultColor.b,
				colorStr = defaultColor.colorStr,
			}
		elseif not db[dualClass].colorStr then
			db[dualClass].colorStr = format("ff%02x%02x%02x", db[dualClass].r * 255, db[dualClass].g * 255, db[dualClass].b * 255)
		end

		CUSTOM_CLASS_COLORS[dualClass] = {
			r = db[dualClass].r,
			g = db[dualClass].g,
			b = db[dualClass].b,
			colorStr = db[dualClass].colorStr,
		}
	end

	--------------------------------------------------------------------

	local shown
	local cache = {}
	local pickers = {}
	local dualPickers = {}

	-- Main title
	local title = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetJustifyH("LEFT")
	title:SetText(L.TITLE)

	local notes = self:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	notes:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	notes:SetWidth(400)
	notes:SetHeight(28)
	notes:SetJustifyH("LEFT")
	notes:SetJustifyV("TOP")
	notes:SetNonSpaceWrap(true)
	notes:SetText(L.NOTES)

	-- Create scroll frame
	local scrollFrame = CreateFrame("ScrollFrame", "ClassColorsScrollFrame", self, "UIPanelScrollFrameTemplate")
	scrollFrame:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -16)
	scrollFrame:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -32, 80)

	local content = CreateFrame("Frame", "ClassColorsContent", scrollFrame)
	content:SetWidth(scrollFrame:GetWidth() - 20)
	scrollFrame:SetScrollChild(content)

	-- Base Classes header
	local classHeader = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	classHeader:SetPoint("TOPLEFT", 0, 0)
	classHeader:SetText("Base Classes")

	local currentY = -25

	-- Regular class pickers (2 columns)
	for i = 1, #classes do
		local class = classes[i]
		local color = db[class]
		local className = LOCALIZED_CLASS_NAMES_MALE[class] or class

		cache[class] = {}
		pickers[i] = self:CreateColorPicker(className, content)
		pickers[i].class = class

		pickers[i].GetValue = function()
			return color.r, color.g, color.b
		end

		pickers[i].SetValue = function(picker, r, g, b)
			picker.label:SetTextColor(r, g, b)
			color.r, color.g, color.b = r, g, b
			color.colorStr = format("ff%02x%02x%02x", r * 255, g * 255, b * 255)
			CUSTOM_CLASS_COLORS[class].r = r
			CUSTOM_CLASS_COLORS[class].g = g
			CUSTOM_CLASS_COLORS[class].b = b
			CUSTOM_CLASS_COLORS[class].colorStr = color.colorStr
			DispatchCallbacks()
		end

		pickers[i]:SetColor(color.r, color.g, color.b)
		pickers[i].label:SetTextColor(color.r, color.g, color.b)

		-- Position in 2 columns
		if i % 2 == 1 then
			-- Left column
			pickers[i]:SetPoint("TOPLEFT", content, "TOPLEFT", 0, currentY)
		else
			-- Right column
			pickers[i]:SetPoint("TOPLEFT", content, "TOPLEFT", 210, currentY)
			currentY = currentY - 25
		end
	end

	-- Adjust for odd number of classes
	if #classes % 2 == 1 then
		currentY = currentY - 25
	end

	-- Dual Classes header (below base classes)
	if #dualClasses > 0 then
		local dualHeader = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		dualHeader:SetPoint("TOPLEFT", 0, currentY - 15)
		dualHeader:SetText("Dual Classes")
		currentY = currentY - 40

		-- Dual class pickers (2 columns, below base classes)
		for i = 1, #dualClasses do
			local dualClass = dualClasses[i]
			local color = db[dualClass]
			local combo = DUAL_CLASS_COMBINATIONS[dualClass]
			local displayName = combo and combo.name or dualClass

			cache[dualClass] = {}
			dualPickers[i] = self:CreateColorPicker(displayName, content)
			dualPickers[i].class = dualClass

			dualPickers[i].GetValue = function()
				return color.r, color.g, color.b
			end

			dualPickers[i].SetValue = function(picker, r, g, b)
				picker.label:SetTextColor(r, g, b)
				color.r, color.g, color.b = r, g, b
				color.colorStr = format("ff%02x%02x%02x", r * 255, g * 255, b * 255)
				CUSTOM_CLASS_COLORS[dualClass].r = r
				CUSTOM_CLASS_COLORS[dualClass].g = g
				CUSTOM_CLASS_COLORS[dualClass].b = b
				CUSTOM_CLASS_COLORS[dualClass].colorStr = color.colorStr
				DispatchCallbacks()
			end

			dualPickers[i]:SetColor(color.r, color.g, color.b)
			dualPickers[i].label:SetTextColor(color.r, color.g, color.b)

			-- Position all in left column only
			dualPickers[i]:SetPoint("TOPLEFT", content, "TOPLEFT", 0, currentY)
			currentY = currentY - 25
		end

		-- Adjust for odd number of dual classes
		if #dualClasses % 2 == 1 then
			currentY = currentY - 25
		end
	end

	-- Set content height properly for scrolling
	content:SetHeight(math.abs(currentY) + 0)

	--------------------------------------------------------------------

	self:SetScript("OnShow", function(frame)
		if shown then
			frame.refresh()
		end

		-- Cache current values
		for i = 1, #pickers do
			local picker = pickers[i]
			local r, g, b = picker:GetValue()
			cache[picker.class] = { r = r, g = g, b = b }
		end

		for i = 1, #dualPickers do
			local picker = dualPickers[i]
			local r, g, b = picker:GetValue()
			cache[picker.class] = { r = r, g = g, b = b }
		end

		shown = true
	end)

	self.refresh = function()
		for i = 1, #pickers do
			local picker = pickers[i]
			local r, g, b = picker:GetValue()
			picker.swatch:SetVertexColor(r, g, b)
			picker.label:SetTextColor(r, g, b)
		end

		for i = 1, #dualPickers do
			local picker = dualPickers[i]
			local r, g, b = picker:GetValue()
			picker.swatch:SetVertexColor(r, g, b)
			picker.label:SetTextColor(r, g, b)
		end
	end

	self.okay = function()
		if not shown then return end
		wipe(cache)
		shown = false
	end

	self.cancel = function()
		if not shown then return end
		-- Restore from cache
		shown = false
	end

	self.defaults = function()
		-- Reset to defaults
		for i = 1, #pickers do
			local picker = pickers[i]
			local class = picker.class
			local color = RAID_CLASS_COLORS[class]
			picker:SetColor(color.r, color.g, color.b)
		end

		for i = 1, #dualPickers do
			local picker = dualPickers[i]
			local dualClass = picker.class
			local combo = DUAL_CLASS_COMBINATIONS[dualClass]
			if combo then
				local defaultColor = GenerateDualClassColor(combo.class1, combo.class2)
				picker:SetColor(defaultColor.r, defaultColor.g, defaultColor.b)
			end
		end
	end

	--------------------------------------------------------------------

	local reset = CreateFrame("Button", "$parentReset", self, "UIPanelButtonTemplate")
	reset:SetPoint("BOTTOMLEFT", self, 16, 16)
	reset:SetSize(96, 22)
	reset:SetText(L.RESET)
	reset:SetScript("OnClick", self.defaults)

	local help = self:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	help:SetPoint("BOTTOMLEFT", reset, "TOPLEFT", 0, 8)
	help:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -16, 54)
	help:SetHeight(20)
	help:SetJustifyH("LEFT")
	help:SetJustifyV("BOTTOM")
	help:SetNonSpaceWrap(true)
	help:SetText("Some addons may require a UI reload to recognize color changes.")

	--------------------------------------------------------------------

	InterfaceOptions_AddCategory(self)

	--------------------------------------------------------------------

	SLASH_CLASSCOLORS1 = "/classcolors"
	SlashCmdList.CLASSCOLORS = function()
		InterfaceOptionsFrame_OpenToCategory(self)
	end

	--------------------------------------------------------------------

	self:UnregisterEvent("ADDON_LOADED")
	self:SetScript("OnEvent", nil)
end)

------------------------------------------------------------------------

do
	local NORMAL_FONT_COLOR = NORMAL_FONT_COLOR
	local HIGHLIGHT_FONT_COLOR = HIGHLIGHT_FONT_COLOR
	local ColorPickerFrame = ColorPickerFrame
	local GameTooltip = GameTooltip

	local function OnEnter(self)
		local color = NORMAL_FONT_COLOR
		self.bg:SetVertexColor(color.r, color.g, color.b)
	end

	local function OnLeave(self)
		local color = HIGHLIGHT_FONT_COLOR
		self.bg:SetVertexColor(color.r, color.g, color.b)
	end

	local function OnClick(self)
		OnLeave(self)

		if ColorPickerFrame:IsShown() then
			ColorPickerFrame:Hide()
		else
			self.r, self.g, self.b = self:GetValue()
			UIDropDownMenuButton_OpenColorPicker(self)
			ColorPickerFrame:SetFrameStrata("TOOLTIP")
			ColorPickerFrame:Raise()
		end
	end

	local function SetColor(self, r, g, b)
		self.swatch:SetVertexColor(r, g, b)
		if not ColorPickerFrame:IsShown() then
			self:SetValue(r, g, b)
		end
	end

	function f:CreateColorPicker(name, parent)
		local frame = CreateFrame("Button", nil, parent or self)
		frame:SetHeight(19)
		frame:SetWidth(200)

		local swatch = frame:CreateTexture(nil, "OVERLAY")
		swatch:SetTexture("Interface\\ChatFrame\\ChatFrameColorSwatch")
		swatch:SetPoint("TOPLEFT")
		swatch:SetPoint("BOTTOMLEFT")
		swatch:SetWidth(19)
		frame.swatch = swatch

		local bg = frame:CreateTexture(nil, "BACKGROUND")
		bg:SetTexture(1, 1, 1)
		bg:SetPoint("TOPLEFT", swatch, 1, -1)
		bg:SetPoint("BOTTOMRIGHT", swatch, -1, 1)
		frame.bg = bg

		local label = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
		label:SetPoint("TOPLEFT", swatch, "TOPRIGHT", 4, 1)
		label:SetPoint("BOTTOMLEFT", swatch, "BOTTOMRIGHT", 4, 1)
		label:SetText(name)
		frame.label = label

		frame.SetColor = SetColor
		frame.swatchFunc = function() frame:SetColor(ColorPickerFrame:GetColorRGB()) end
		frame.cancelFunc = function() frame:SetColor(frame.r, frame.g, frame.b) end

		frame:SetScript("OnClick", OnClick)
		frame:SetScript("OnEnter", OnEnter)
		frame:SetScript("OnLeave", OnLeave)

		return frame
	end
end