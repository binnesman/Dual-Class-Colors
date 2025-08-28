--[[--------------------------------------------------------------------
	CustomClassColors
	Change class colors without breaking parts of the Blizzard UI.
	Copyright (c) 2009-2014 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info12513
	http://www.curse.com/addons/wow/classcolors
----------------------------------------------------------------------]]

local _, ns = ...
if ns.alreadyLoaded then
	return
end

local strfind, format, gsub, strmatch, strsub = string.find, string.format, string.gsub, string.match, string.sub
local pairs, type = pairs, type

------------------------------------------------------------------------

local addonFuncs = { }

local blizzHexColors = { }
if RAID_CLASS_COLORS then
	for class, color in pairs(RAID_CLASS_COLORS) do
		if color and color.r and color.g and color.b then
			local colorStr = color.colorStr
			if not colorStr then
				-- Generate colorStr if it doesn't exist (3.3.5a compatibility)
				colorStr = format("ff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
			end
			blizzHexColors[colorStr] = class
		end
	end
end

-- Create CLASS_SORT_ORDER for 3.3.5a compatibility
local CLASS_SORT_ORDER = CLASS_SORT_ORDER or {
	"WARRIOR",
	"PALADIN", 
	"HUNTER",
	"ROGUE",
	"PRIEST",
	"DEATHKNIGHT",
	"SHAMAN",
	"MAGE",
	"WARLOCK",
	"DRUID"
}

------------------------------------------------------------------------
-- ChatConfigFrame.xml

do
	local function ColorLegend(self)
		if not self.classStrings then return end
		for i = 1, #self.classStrings do
			local class = CLASS_SORT_ORDER[i]
			if class and CUSTOM_CLASS_COLORS[class] then
				local color = CUSTOM_CLASS_COLORS[class]
				local className = LOCALIZED_CLASS_NAMES_MALE[class]
				if className then
					self.classStrings[i]:SetFormattedText("|c%s%s|r\n", color.colorStr, className)
				end
			end
		end
	end
	
	-- Check if these frames exist before hooking
	if ChatConfigChatSettingsClassColorLegend then
		ChatConfigChatSettingsClassColorLegend:HookScript("OnShow", ColorLegend)
	end
	if ChatConfigChannelSettingsClassColorLegend then
		ChatConfigChannelSettingsClassColorLegend:HookScript("OnShow", ColorLegend)
	end
end

------------------------------------------------------------------------
-- ChatFrame.lua

function GetColoredName(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12)
	local chatType = strsub(event, 10)
	if strsub(chatType, 1, 7) == "WHISPER" then
		chatType = "WHISPER"
	elseif strsub(chatType, 1, 7) == "CHANNEL" then
		chatType = "CHANNEL"..arg8
	else
		chatType = strsub(event, 10)
	end

	if chatType == "GUILD" then
		arg2 = Ambiguate and Ambiguate(arg2, "guild") or arg2
	else
		arg2 = Ambiguate and Ambiguate(arg2, "none") or arg2
	end

	local info = ChatTypeInfo[chatType]
	if info and info.colorNameByClass and arg12 and arg12 ~= "" then
		local _, class = GetPlayerInfoByGUID and GetPlayerInfoByGUID(arg12)
		if class then
			local color = CUSTOM_CLASS_COLORS[class]
			if color then
				return format("|c%s%s|r", color.colorStr, arg2)
			end
		end
	end

	return arg2
end

do
	-- Fix class colors in chat messages
	local AddMessage = {}

	local function FixClassColors(frame, message, ...)
		if type(message) == "string" and strfind(message, "|cff") then
			for hex, class in pairs(blizzHexColors) do
				local color = CUSTOM_CLASS_COLORS[class]
				if color then
					message = gsub(message, hex, color.colorStr)
				end
			end
		end
		return AddMessage[frame](frame, message, ...)
	end

	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G["ChatFrame"..i]
		if frame and frame.AddMessage then
			AddMessage[frame] = frame.AddMessage
			frame.AddMessage = FixClassColors
		end
	end
end

------------------------------------------------------------------------
--	CompactUnitFrame.lua - Not available in 3.3.5a, skip this section

------------------------------------------------------------------------
--	FriendsFrame.lua

hooksecurefunc("WhoList_Update", function()
	local offset = FauxScrollFrame_GetOffset(WhoListScrollFrame)
	for i = 1, WHOS_TO_DISPLAY do
		local who = i + offset
		local name, guild, level, race, class, zone, classFileName = GetWhoInfo(who)
		if classFileName then
			local color = CUSTOM_CLASS_COLORS[classFileName]
			if color then
				local classText = _G["WhoFrameButton"..i.."Class"]
				if classText then
					classText:SetTextColor(color.r, color.g, color.b)
				end
			end
		end
	end
end)

------------------------------------------------------------------------
--	LFDFrame.lua - Not available in 3.3.5a, skip this section

------------------------------------------------------------------------
-- LFGFrame.lua - Simplified for 3.3.5a

-- Note: 3.3.5a has a different LFG system, these functions may not exist
if LFGCooldownCover_Update then
	hooksecurefunc("LFGCooldownCover_Update", function(self)
		-- Implementation would depend on 3.3.5a specific LFG system
	end)
end

------------------------------------------------------------------------
--	LFRFrame.lua - Not available in 3.3.5a, skip this section

------------------------------------------------------------------------
--	LootFrame.lua

if MasterLooterFrame then
	hooksecurefunc("MasterLooterFrame_UpdatePlayers", function()
		for k, playerFrame in pairs(MasterLooterFrame) do
			if type(k) == "string" and strmatch(k, "^player%d+$") and type(playerFrame) == "table" and playerFrame.id and playerFrame.Name then
				local i = playerFrame.id
				local _, class
				if IsInRaid() then
					_, class = UnitClass("raid"..i)
				elseif i > 1 then
					_, class = UnitClass("party"..(i-1))
				else
					_, class = UnitClass("player")
				end
				if class then
					local color = CUSTOM_CLASS_COLORS[class]
					if color then
						playerFrame.Name:SetTextColor(color.r, color.g, color.b)
					end
				end
			end
		end
	end)
end

------------------------------------------------------------------------
--	LootHistory.lua - Not available in 3.3.5a, skip this section

------------------------------------------------------------------------
--	PaperDollFrame.lua

hooksecurefunc("PaperDollFrame_SetLevel", function()
	local className, class = UnitClass("player")
	local color = CUSTOM_CLASS_COLORS[class]
	if color then
		-- 3.3.5a doesn't have specializations, so just show class
		CharacterLevelText:SetFormattedText(PLAYER_LEVEL_NO_SPEC or "%d |c%s%s|r", UnitLevel("player"), color.colorStr, className)
	end
end)

------------------------------------------------------------------------
--	RaidFinder.lua - Not available in 3.3.5a, skip this section

------------------------------------------------------------------------
--	RaidWarning.lua

do
	local AddMessage = RaidNotice_AddMessage
	if AddMessage then
		RaidNotice_AddMessage = function(frame, message, ...)
			if type(message) == "string" and strfind(message, "|cff") then
				for hex, class in pairs(blizzHexColors) do
					local color = CUSTOM_CLASS_COLORS[class]
					if color then
						message = gsub(message, hex, color.colorStr)
					end
				end
			end
			return AddMessage(frame, message, ...)
		end
	end
end

------------------------------------------------------------------------
--	Blizzard_Calendar.lua - Not available in 3.3.5a, skip this section

------------------------------------------------------------------------
--	Blizzard_ChallengesUI.lua - Not available in 3.3.5a, skip this section

------------------------------------------------------------------------
--	Blizzard_GuildRoster.lua

addonFuncs["Blizzard_GuildUI"] = function()
	if GuildRosterButton_SetStringText then
		hooksecurefunc("GuildRosterButton_SetStringText", function(buttonString, text, isOnline, class)
			if isOnline and class then
				local color = CUSTOM_CLASS_COLORS[class]
				if color then
					buttonString:SetTextColor(color.r, color.g, color.b)
				end
			end
		end)
	end
end

------------------------------------------------------------------------
--	InspectPaperDollFrame.lua

addonFuncs["Blizzard_InspectUI"] = function()
	if InspectPaperDollFrame_SetLevel then
		hooksecurefunc("InspectPaperDollFrame_SetLevel", function()
			local unit = InspectFrame and InspectFrame.unit
			if not unit then return end

			local className, class = UnitClass(unit)
			if class then
				local color = CUSTOM_CLASS_COLORS[class]
				if color then
					local level = UnitLevel(unit)
					if level == -1 then
						level = "??"
					end
					-- 3.3.5a doesn't have specializations
					if InspectLevelText then
						InspectLevelText:SetFormattedText(PLAYER_LEVEL_NO_SPEC or "%s |c%s%s|r", level, color.colorStr, className)
					end
				end
			end
		end)
	end
end

------------------------------------------------------------------------
--	Blizzard_RaidUI.lua

addonFuncs["Blizzard_RaidUI"] = function()
	local _G = _G
	local min = math.min
	local GetNumRaidMembers, GetRaidRosterInfo, UnitClass = GetNumRaidMembers, GetRaidRosterInfo, UnitClass
	local MAX_RAID_MEMBERS = MAX_RAID_MEMBERS or 40
	local MEMBERS_PER_RAID_GROUP = MEMBERS_PER_RAID_GROUP or 5

	if RaidGroupFrame_Update then
		hooksecurefunc("RaidGroupFrame_Update", function()
			if not IsInRaid() then return end
			local numMembers = GetNumRaidMembers()
			for i = 1, min(numMembers, MAX_RAID_MEMBERS) do
				local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(i)
				if fileName and online and not isDead then
					local color = CUSTOM_CLASS_COLORS[fileName]
					if color then
						local button = _G["RaidGroupButton"..i]
						if button and button.subframes then
							if button.subframes.name then
								button.subframes.name:SetTextColor(color.r, color.g, color.b)
							end
							if button.subframes.class then
								button.subframes.class:SetTextColor(color.r, color.g, color.b)
							end
							if button.subframes.level then
								button.subframes.level:SetTextColor(color.r, color.g, color.b)
							end
						end
					end
				end
			end
		end)
	end
end

------------------------------------------------------------------------
--	Blizzard_TradeSkillUI.lua - Simplified for 3.3.5a

addonFuncs["Blizzard_TradeSkillUI"] = function()
	-- 3.3.5a has a different tradeskill system, may need adjustment
end

------------------------------------------------------------------------

local numAddons = 0

for addon, func in pairs(addonFuncs) do
	if IsAddOnLoaded(addon) then
		addonFuncs[addon] = nil
		func()
	else
		numAddons = numAddons + 1
	end
end

if numAddons > 0 then
	local f = CreateFrame("Frame")
	f:RegisterEvent("ADDON_LOADED")
	f:SetScript("OnEvent", function(self, event, addon)
		local func = addonFuncs[addon]
		if func then
			addonFuncs[addon] = nil
			numAddons = numAddons - 1
			func()
		end
		if numAddons == 0 then
			self:UnregisterEvent("ADDON_LOADED")
			self:SetScript("OnEvent", nil)
		end
	end)
end