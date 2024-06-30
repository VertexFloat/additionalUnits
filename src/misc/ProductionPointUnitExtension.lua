-- ProductionPointUnitExtension.lua
--
-- author: 4c65736975
--
-- Copyright (c) 2024 VertexFloat. All Rights Reserved.
--
-- This source code is licensed under the GPL-3.0 license found in the
-- LICENSE file in the root directory of this source tree.

ProductionPointUnitExtension = {}

function ProductionPointUnitExtension:updateInfo(superFunc, infoTable)
  local owningFarm = g_farmManager:getFarmById(self:getOwnerFarmId())

  table.insert(infoTable, {
    title = g_i18n:getText("fieldInfo_ownedBy"),
    text = owningFarm.name
  })

  if #self.activeProductions > 0 then
    table.insert(infoTable, self.infoTables.activeProds)

    local activeProduction = nil

    for i = 1, #self.activeProductions do
      activeProduction = self.activeProductions[i]

      local productionName = activeProduction.name or g_fillTypeManager:getFillTypeTitleByIndex(activeProduction.primaryProductFillType)

      table.insert(infoTable, {
        title = productionName,
        text = g_i18n:getText(ProductionPoint.PROD_STATUS_TO_L10N[self:getProductionStatus(activeProduction.id)])
      })
    end
  else
    table.insert(infoTable, self.infoTables.noActiveProd)
  end

  local fillType, fillLevel = nil
  local formattedFillLevel, unit = nil
  local fillTypesDisplayed = false

  table.insert(infoTable, self.infoTables.storage)

  for i = 1, #self.inputFillTypeIdsArray do
    fillType = self.inputFillTypeIdsArray[i]
    fillLevel = self:getFillLevel(fillType)

    if fillLevel > 1 then
      fillTypesDisplayed = true

      formattedFillLevel, unit = g_additionalUnits:formatFillLevel(fillLevel, g_fillTypeManager:getFillTypeNameByIndex(fillType))

      table.insert(infoTable, {
        title = g_fillTypeManager:getFillTypeTitleByIndex(fillType),
        text = g_i18n:formatVolume(formattedFillLevel, 0, unit.shortName)
      })
    end
  end

  for i = 1, #self.outputFillTypeIdsArray do
    fillType = self.outputFillTypeIdsArray[i]
    fillLevel = self:getFillLevel(fillType)

    if fillLevel > 1 then
      fillTypesDisplayed = true

      formattedFillLevel, unit = g_additionalUnits:formatFillLevel(fillLevel, g_fillTypeManager:getFillTypeNameByIndex(fillType))

      table.insert(infoTable, {
        title = g_fillTypeManager:getFillTypeTitleByIndex(fillType),
        text = g_i18n:formatVolume(formattedFillLevel, 0, unit.shortName)
      })
    end
  end

  if not fillTypesDisplayed then
    table.insert(infoTable, self.infoTables.storageEmpty)
  end

  if self.palletLimitReached then
    table.insert(infoTable, self.infoTables.palletLimitReached)
  end
end

function ProductionPointUnitExtension:overwriteGameFunctions()
  if not g_modIsLoaded.FS22_InfoDisplayExtension then
    ProductionPoint.updateInfo = Utils.overwrittenFunction(ProductionPoint.updateInfo, ProductionPointUnitExtension.updateInfo)
  end
end
