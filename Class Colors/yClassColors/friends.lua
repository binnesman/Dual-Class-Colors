local _, ns = ...
local ycc = ns.ycc

local WHITE = {r = 1, g = 1, b = 1}
local FRIENDS_LEVEL_TEMPLATE = FRIENDS_LEVEL_TEMPLATE:gsub('%%d', '%%s')
FRIENDS_LEVEL_TEMPLATE = FRIENDS_LEVEL_TEMPLATE:gsub('%$d', '%$s') -- '%2$s %1$d-го уровня'
local function friendsFrame()
    local scrollFrame = FriendsFrameFriendsScrollFrame
    local offset = HybridScrollFrame_GetOffset(scrollFrame)
    local buttons = scrollFrame.buttons

    local playerArea = GetRealZoneText()

    for i = 1, #buttons do
        local nameText, infoText
        button = buttons[i]
        index = offset + i
        if(button:IsShown()) then
            if ( button.buttonType == FRIENDS_BUTTON_TYPE_WOW ) then
                local name, level, class, area, connected, status, note = GetFriendInfo(button.id)
                if(connected) then
                    nameText = ycc.classColor[class] .. name.."|r, "..format(FRIENDS_LEVEL_TEMPLATE, ycc.diffColor[level] .. level .. '|r', class)
                    if(areaName == playerArea) then
                        infoText = format('|cff00ff00%s|r', area)
                    end
                end
            elseif (button.buttonType == FRIENDS_BUTTON_TYPE_BNET) then
                local presenceID, presenceName, battleTag, isBattleTagPresence, toonName, toonID, client, isOnline, lastOnline, isAFK, isDND, messageText, noteText, isRIDFriend, messageTime, canSoR = BNGetFriendInfo(button.id)
                if(isOnline and client==BNET_CLIENT_WOW) then
                    local hasFocus, toonName, client, realmName, realmID, faction, race, class, guild, zoneName, level, gameText, broadcastText, broadcastTime = BNGetToonInfo(toonID)
                    if(presenceName and toonName and class) then
                        nameText = presenceName .. ' ' .. FRIENDS_WOW_NAME_COLOR_CODE..'('..
                                    ycc.classColor[class] .. toonName .. FRIENDS_WOW_NAME_COLOR_CODE .. ')'
                        if(zoneName == playerArea) then
                            infoText = format('|cff00ff00%s|r', zoneName)
                        end
                    end
                end
            end
        end

        if(nameText) then
            button.name:SetText(nameText)
        end
        if(infoText) then
            button.info:SetText(infoText)
        end
    end
end

-- Check if the scroll frame and its update method exist before hooking
if FriendsFrameFriendsScrollFrame and FriendsFrameFriendsScrollFrame.update then
    hooksecurefunc(FriendsFrameFriendsScrollFrame, 'update', friendsFrame)
end

-- Hook the friends frame update function
if FriendsFrame_UpdateFriends then
    hooksecurefunc('FriendsFrame_UpdateFriends', friendsFrame)
end

-- For 3.3.5a compatibility, also try these alternative function names
if FriendsList_Update then
    hooksecurefunc('FriendsList_Update', friendsFrame)
end

if FriendsFrame_Update then
    hooksecurefunc('FriendsFrame_Update', friendsFrame)
end