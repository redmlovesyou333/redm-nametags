-- Nametags Script (Simplified & Optimized)

-- Config (defaults, override via Config table if present)
local cfg = Config or {}
local nametagDrawDistance = cfg.nametagDrawDistance or 15.0
local minScale = cfg.minScale or 0.15
local maxScale = cfg.maxScale or 0.40
local barVerticalOffset = cfg.barVerticalOffset or 0.033
local font = cfg.font or 1
local textColor = cfg.textColor or { r = 255, g = 255, b = 255, a = 255 }
local barColor = cfg.barColor or { r = 0, g = 0, b = 0, a = 120 }
local borderColor = cfg.borderColor or { r = 150, g = 28, b = 38, a = 255 }
local barThickness = cfg.barThickness or 0.075
local borderThickness = cfg.borderThickness or 0.012
local textSize = cfg.textSize or 1.0
local dynamicBarLength = cfg.dynamicBarLength ~= false
local maxNametagLength = cfg.maxNametagLength or 15
local showServerId = cfg.showServerId or false
local showNametags = cfg.showNametags ~= false
local showOwnNametag = cfg.showOwnNametag ~= false
local onlyShowWhenHoldingKey = cfg.onlyShowWhenHoldingKey or false
local nametagHoldKey = cfg.nametagHoldKey or 0x43CDA5B0
local fadeSpeed = cfg.fadeSpeed or 15
local maxAlpha = cfg.maxAlpha or 255
local showName = cfg.showName ~= false

-- State
local fadeAlpha, keyHeld = 0, false

-- Helper: Get formatted nametag text
local function getNametagText(playerId)
    local name = GetPlayerName(playerId) or "Unknown"
    local serverId = GetPlayerServerId(playerId)
    if not showName then return ("ID: %s"):format(serverId) end
    if #name > maxNametagLength then name = name:sub(1, maxNametagLength) end
    if showServerId then name = ("%s ID: %s"):format(name, serverId) end
    return name
end

-- Helper: Draw 3D text
local function DrawText3D(x, y, z, text, alpha, scale)
    local onScreen, sx, sy = GetScreenCoordFromWorldCoord(x, y, z)
    if onScreen then
        local finalScale = scale * textSize
        SetTextScale(finalScale, finalScale)
        SetTextFontForCurrentCommand(font)
        SetTextColor(textColor.r, textColor.g, textColor.b, math.floor((textColor.a or 255) * (alpha / maxAlpha)))
        SetTextCentre(1)
        DisplayText(CreateVarString(10, "LITERAL_STRING", text), sx, sy)
    end
    return onScreen, sx, sy
end

-- Helper: Calculate bar length for text
local function GetBarLengthForText(text, scale)
    if not dynamicBarLength then return 0.22 * scale end
    return (0.13 * scale * 0.6) + (0.012 * scale * textSize * #text)
end

-- Helper: Draw background bar
local function DrawBackgroundBar(sx, sy, text, alpha, scale)
    local width = GetBarLengthForText(text, scale)
    local height = barThickness * scale
    local border = borderThickness * scale
    local barSy = sy + barVerticalOffset * scale
    local a = math.floor((barColor.a or 255) * (alpha / maxAlpha))
    local ba = math.floor((borderColor.a or 255) * (alpha / maxAlpha))
    DrawRect(sx, barSy, width, height, barColor.r, barColor.g, barColor.b, a)
    DrawRect(sx, barSy - (height / 2) + (border / 2), width, border, borderColor.r, borderColor.g, borderColor.b, ba)
    DrawRect(sx, barSy + (height / 2) - (border / 2), width, border, borderColor.r, borderColor.g, borderColor.b, ba)
end

-- NUI Callbacks for menu integration
RegisterNUICallback('setShowNametags', function(data, cb)
    if data and data.showNametags ~= nil then showNametags = data.showNametags end
    cb({status = 'ok'})
end)
RegisterNUICallback('setShowOwnNametag', function(data, cb)
    if data and data.showOwnNametag ~= nil then showOwnNametag = data.showOwnNametag end
    cb({status = 'ok'})
end)

-- Key handling thread (for hold logic only)
Citizen.CreateThread(function()
    if not onlyShowWhenHoldingKey then return end
    while true do
        keyHeld = IsControlPressed(0, nametagHoldKey)
        Citizen.Wait(10)
    end
end)

-- Main nametag draw loop
Citizen.CreateThread(function()
    while true do
        -- Fade logic
        local shouldShow = not onlyShowWhenHoldingKey or keyHeld
        fadeAlpha = shouldShow and math.min(maxAlpha, fadeAlpha + fadeSpeed) or math.max(0, fadeAlpha - fadeSpeed)
        local myPed, myId = PlayerPedId(), PlayerId()
        local myCoords = GetEntityCoords(myPed)
        for _, playerId in ipairs(GetActivePlayers()) do
            local ped = GetPlayerPed(playerId)
            if ped and DoesEntityExist(ped) then
                local pedCoords = GetEntityCoords(ped)
                local dist = #(myCoords - pedCoords)
                local isSelf = (playerId == myId)
                if fadeAlpha > 0 and ((isSelf and showOwnNametag) or (not isSelf and showNametags and dist <= nametagDrawDistance)) then
                    local alpha = fadeAlpha
                    if not isSelf and dist > nametagDrawDistance * 0.7 then
                        alpha = math.floor(fadeAlpha * (1 - (dist - nametagDrawDistance * 0.7) / (nametagDrawDistance * 0.3)))
                        alpha = math.max(0, math.min(fadeAlpha, alpha))
                    end
                    local scale = (not isSelf and dist > 2.0)
                        and math.max(minScale, maxScale - ((maxScale - minScale) * ((dist - 2.0) / (nametagDrawDistance - 2.0))))
                        or maxScale
                    local z = pedCoords.z + 1.0
                    local nametagText = getNametagText(playerId)
                    local onScreen, sx, sy = DrawText3D(pedCoords.x, pedCoords.y, z, nametagText, alpha, scale)
                    if onScreen then
                        DrawBackgroundBar(sx, sy, nametagText, alpha, scale)
                        DrawText3D(pedCoords.x, pedCoords.y, z, nametagText, alpha, scale)
                    end
                end
            end
        end
        Citizen.Wait(5)
    end
end) 