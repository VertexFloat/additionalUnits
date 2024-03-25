-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.0, 25|03|2024
-- @filename: StrawHarvestPackUnitExtension.lua

StrawHarvestPackUnitExtension = {}

local StrawHarvestPackUnitExtension_mt = Class(StrawHarvestPackUnitExtension)

function StrawHarvestPackUnitExtension.new(customMt, additionalUnits, i18n)
  local self = setmetatable({}, customMt or StrawHarvestPackUnitExtension_mt)

  self.i18n = i18n
  self.additionalUnits = additionalUnits

  return self
end

function StrawHarvestPackUnitExtension:loadMap()
  local target = _G["FS22_strawHarvestPack"].StrawHarvestPalletizer

  self.additionalUnits:overwriteGameFunction(target, "showStatistics", function (superFunc, palletizer)
    local statsText = self.i18n:getText("statistics_palletizer_bags", "FS22_strawHarvestPack"):format(palletizer.bagsToday, palletizer.palletsToday)

    g_currentMission:addExtraPrintText(statsText)

    local capacity = palletizer.pelletizerBuffer:getCapacity()
    local bunkerFillLevel = palletizer.bunkerBuffer:getFillLevel()
    local fillLevel = palletizer.pelletizerBuffer:getFillLevel()
    local numBagToGoLeft = (fillLevel + bunkerFillLevel) / palletizer.literPerBag
    local numMinutesLeft = numBagToGoLeft * palletizer.animationUtil:getAnimationPackageDuration(palletizer.bagFillAnimationPackage) * 0.001 / 60
    local timeText = self.i18n:getText("statistics_palletizer_time", "FS22_strawHarvestPack"):format(math.floor(numMinutesLeft), math.floor((numMinutesLeft - math.floor(numMinutesLeft)) * 60))

    g_currentMission:addExtraPrintText(timeText)

    local fillType = g_fillTypeManager:getFillTypeByIndex(palletizer.pelletizerBuffer:getFillType())
    local fillTypeName = fillType ~= nil and fillType.title or ""
    local formattedFillLevel, unit = self.additionalUnits:formatFillLevel(fillLevel, fillType.name)
    local fillInfoText = string.format(self.i18n:getText("info_fillLevel") .. " %s: %s (%d%%)", fillTypeName, self.i18n:formatVolume(formattedFillLevel, 0, unit.shortName), math.floor(100 * fillLevel / capacity))

    g_currentMission:addExtraPrintText(fillInfoText)

    if not palletizer.isActive and not palletizer:hasAvailableOutputPlaces() then
      g_currentMission:addExtraPrintText(self.i18n:getText("statistics_palletizer_blocked", "FS22_strawHarvestPack"))
    end
  end)
end