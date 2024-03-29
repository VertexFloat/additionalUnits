-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.1, 27|02|2024
-- @filename: ProductionPointUnitExtension.lua

-- Changelog (1.0.0.1):
-- fixed issue attempt to call local 'superFunc' (a table value)

ProductionPointUnitExtension = {}

local ProductionPointUnitExtension_mt = Class(ProductionPointUnitExtension)

function ProductionPointUnitExtension.new(customMt, additionalUnits, i18n, fillTypeManager)
  local self = setmetatable({}, customMt or ProductionPointUnitExtension_mt)

  self.i18n = i18n
  self.additionalUnits = additionalUnits
  self.fillTypeManager = fillTypeManager

  return self
end

function ProductionPointUnitExtension:initialize()
  self.additionalUnits:overwriteGameFunction(ProductionPoint, "updateInfo", function (_, production, infoTable)
    local owningFarm = g_farmManager:getFarmById(production:getOwnerFarmId())

    table.insert(infoTable, {
      title = self.i18n:getText("fieldInfo_ownedBy"),
      text = owningFarm.name
    })

    if #production.activeProductions > 0 then
      table.insert(infoTable, production.infoTables.activeProds)

      local activeProduction = nil

      for i = 1, #production.activeProductions do
        activeProduction = production.activeProductions[i]

        local productionName = activeProduction.name or self.fillTypeManager:getFillTypeTitleByIndex(activeProduction.primaryProductFillType)

        table.insert(infoTable, {
          title = productionName,
          text = self.i18n:getText(ProductionPoint.PROD_STATUS_TO_i18n[production:getProductionStatus(activeProduction.id)])
        })
      end
    else
      table.insert(infoTable, production.infoTables.noActiveProd)
    end

    local fillType, fillLevel = nil
    local formattedFillLevel, unit = nil
    local fillTypesDisplayed = false

    table.insert(infoTable, production.infoTables.storage)

    for i = 1, #production.inputFillTypeIdsArray do
      fillType = production.inputFillTypeIdsArray[i]
      fillLevel = production:getFillLevel(fillType)

      if fillLevel > 1 then
        fillTypesDisplayed = true

        formattedFillLevel, unit = self.additionalUnits:formatFillLevel(fillLevel, self.fillTypeManager:getFillTypeNameByIndex(fillType))

        table.insert(infoTable, {
          title = self.fillTypeManager:getFillTypeTitleByIndex(fillType),
          text = self.i18n:formatVolume(formattedFillLevel, 0, unit.shortName)
        })
      end
    end

    for i = 1, #production.outputFillTypeIdsArray do
      fillType = production.outputFillTypeIdsArray[i]
      fillLevel = production:getFillLevel(fillType)

      if fillLevel > 1 then
        fillTypesDisplayed = true

        formattedFillLevel, unit = self.additionalUnits:formatFillLevel(fillLevel, self.fillTypeManager:getFillTypeNameByIndex(fillType))

        table.insert(infoTable, {
          title = self.fillTypeManager:getFillTypeTitleByIndex(fillType),
          text = self.i18n:formatVolume(formattedFillLevel, 0, unit.shortName)
        })
      end
    end

    if not fillTypesDisplayed then
      table.insert(infoTable, production.infoTables.storageEmpty)
    end

    if production.palletLimitReached then
      table.insert(infoTable, production.infoTables.palletLimitReached)
    end
  end)
end