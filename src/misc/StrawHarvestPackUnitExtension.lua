-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.0, 25|03|2024
-- @filename: StrawHarvestPackUnitExtension.lua

StrawHarvestPackUnitExtension = {
  OBJECT = _G["FS22_strawHarvestPack"]
}

function StrawHarvestPackUnitExtension:showStatistics(superFunc)
  local statsText = g_i18n:getText("statistics_palletizer_bags", "FS22_strawHarvestPack"):format(self.bagsToday, self.palletsToday)

  g_currentMission:addExtraPrintText(statsText)

  local capacity = self.pelletizerBuffer:getCapacity()
  local bunkerFillLevel = self.bunkerBuffer:getFillLevel()
  local fillLevel = self.pelletizerBuffer:getFillLevel()
  local numBagToGoLeft = (fillLevel + bunkerFillLevel) / self.literPerBag
  local numMinutesLeft = numBagToGoLeft * self.animationUtil:getAnimationPackageDuration(self.bagFillAnimationPackage) * 0.001 / 60
  local timeText = g_i18n:getText("statistics_palletizer_time", "FS22_strawHarvestPack"):format(math.floor(numMinutesLeft), math.floor((numMinutesLeft - math.floor(numMinutesLeft)) * 60))

  g_currentMission:addExtraPrintText(timeText)

  local fillType = g_fillTypeManager:getFillTypeByIndex(self.pelletizerBuffer:getFillType())
  local fillTypeName = fillType ~= nil and fillType.title or ""
  local formattedFillLevel, unit = g_additionalUnits:formatFillLevel(fillLevel, fillType.name)
  local fillInfoText = string.format(g_i18n:getText("info_fillLevel") .. " %s: %s (%d%%)", fillTypeName, g_i18n:formatVolume(formattedFillLevel, 0, unit.shortName), math.floor(100 * fillLevel / capacity))

  g_currentMission:addExtraPrintText(fillInfoText)

  if not self.isActive and not self:hasAvailableOutputPlaces() then
    g_currentMission:addExtraPrintText(g_i18n:getText("statistics_palletizer_blocked", "FS22_strawHarvestPack"))
  end
end

function StrawHarvestPackUnitExtension:updateInfo(_, superFunc, infoTable)
  superFunc(self, infoTable)

  local spec = self.spec_husbandryBeddingMulti

  for _, inputFillType in ipairs(spec.inputFillTypes) do
    local addInfo = true

    if pdlc_pumpsAndHosesPackIsLoaded then
      addInfo = inputFillType ~= FillType.SEPARATED_MANURE
    end

    if addInfo then
      local fillLevel = self:getHusbandryFillLevel(inputFillType)
      local formattedFillLevel, unit = g_additionalUnits:formatFillLevel(fillLevel, g_fillTypeManager:getFillTypeNameByIndex(inputFillType))

      spec.info[inputFillType].text = g_i18n:formatVolume(formattedFillLevel, 0, unit.shortName)

      table.insert(infoTable, spec.info[inputFillType])
    end
  end
end

function StrawHarvestPackUnitExtension:overwriteGameFunctions()
  StrawHarvestPackUnitExtension.OBJECT.StrawHarvestPalletizer.showStatistics = Utils.overwrittenFunction(StrawHarvestPackUnitExtension.OBJECT.StrawHarvestPalletizer.showStatistics, StrawHarvestPackUnitExtension.showStatistics)
  StrawHarvestPackUnitExtension.OBJECT.PlaceableHusbandryBeddingMulti.updateInfo = Utils.overwrittenFunction(StrawHarvestPackUnitExtension.OBJECT.PlaceableHusbandryBeddingMulti.updateInfo, StrawHarvestPackUnitExtension.updateInfo)
end