Config = {}

Config.showNametags = true -- Show own nametags can still be shown even if this is false

-- Show your own nametag above your head
Config.showServerId = true
Config.showName = true
Config.showOwnNametag = true

Config.onlyShowWhenHoldingKey = true
Config.nametagHoldKey = 0x43CDA5B0 -- (hold Z by default)

Config.nametagDrawDistance = 20.0
Config.fadeSpeed = 15      -- How fast the nametag fades in/out (higher = faster)
Config.maxAlpha = 255      -- Maximum alpha value for nametag (0-255)

Config.minScale = 0.10
Config.maxScale = 0.40
Config.barVerticalOffset = 0.033

Config.font = 1
Config.textColor = { r = 255, g = 255, b = 255, a = 255 }
Config.barColor = { r = 0, g = 0, b = 0, a = 120 }
Config.borderColor = { r = 150, g = 28, b = 38, a = 255 }

-- Bar and border visual dimensions
Config.barThickness = 0.095  -- Default: 0.075
Config.borderThickness = 0.009 -- Default: 0.012

Config.dynamicBarLength = true
Config.maxNametagLength = 15

Config.textSize = 1.0