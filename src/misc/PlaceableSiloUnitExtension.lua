-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.0, 13|04|2023
-- @filename: PlaceableSiloUnitExtension.lua

PlaceableSiloUnitExtension = {}

local PlaceableSiloUnitExtension_mt = Class(PlaceableSiloUnitExtension)

function PlaceableSiloUnitExtension.new(customMt, additionalUnits, i18n, fillTypeManager)
  local self = setmetatable({}, customMt or PlaceableSiloUnitExtension_mt)

  self.i18n = i18n
  self.additionalUnits = additionalUnits
  self.fillTypeManager = fillTypeManager

  return self
end

function PlaceableSiloUnitExtension:initialize()
  self.additionalUnits:overwriteGameFunction(PlaceableSilo, "updateInfo", function (_, silo, superFunc, infoTable)
    superFunc(silo, infoTable)

    local spec = silo.spec_silo
    local farmId = g_currentMission:getFarmId()

    for fillType, fillLevel in pairs(spec.loadingStation:getAllFillLevels(farmId)) do
      spec.fillTypesAndLevelsAuxiliary[fillType] = (spec.fillTypesAndLevelsAuxiliary[fillType] or 0) + fillLevel
    end

    table.clear(spec.infoTriggerFillTypesAndLevels)

    for fillType, fillLevel in pairs(spec.fillTypesAndLevelsAuxiliary) do
      if fillLevel > 0.1 then
        spec.fillTypeToFillTypeStorageTable[fillType] = spec.fillTypeToFillTypeStorageTable[fillType] or { fillType = fillType, fillLevel = fillLevel }
        spec.fillTypeToFillTypeStorageTable[fillType].fillLevel = fillLevel

        table.insert(spec.infoTriggerFillTypesAndLevels, spec.fillTypeToFillTypeStorageTable[fillType])
      end
    end

    table.clear(spec.fillTypesAndLevelsAuxiliary)
    table.sort(spec.infoTriggerFillTypesAndLevels, function(a, b) return a.fillLevel > b.fillLevel end)

    local numEntries = math.min(#spec.infoTriggerFillTypesAndLevels, PlaceableSilo.INFO_TRIGGER_NUM_DISPLAYED_FILLTYPES)

    if numEntries > 0 then
      for i = 1, numEntries do
        local fillTypeAndLevel = spec.infoTriggerFillTypesAndLevels[i]
        local fillLevel, unit = self.additionalUnits:formatFillLevel(fillTypeAndLevel.fillLevel, self.fillTypeManager:getFillTypeNameByIndex(fillTypeAndLevel.fillType), 0)

        table.insert(infoTable, {title = self.fillTypeManager:getFillTypeTitleByIndex(fillTypeAndLevel.fillType), text = fillLevel .. " " .. unit})
      end
    else
      table.insert(infoTable, {title = self.i18n:getText("infohud_siloEmpty"), text = ""})
    end
  end)

  self.additionalUnits:overwriteGameFunction(PlaceableSilo, "canBeSold", function (_, silo, superFunc)
    local spec = silo.spec_silo

    if spec.storagePerFarm then
      return false, nil
    end

    local warning = spec.sellWarningText .. "\n"
    local totalFillLevel = 0

    spec.totalFillTypeSellPrice = 0

    for fillTypeIndex, fillLevel in pairs(spec.storages[1].fillLevels) do
      totalFillLevel = totalFillLevel + fillLevel

      if fillLevel > 0 then
        local lowestSellPrice = math.huge

        for _, unloadingStation in pairs(g_currentMission.storageSystem:getUnloadingStations()) do
          if unloadingStation.owningPlaceable ~= nil and unloadingStation.isSellingPoint and unloadingStation.acceptedFillTypes[fillTypeIndex] then
            local price = unloadingStation:getEffectiveFillTypePrice(fillTypeIndex)

            if price > 0 then
              lowestSellPrice = math.min(lowestSellPrice, price)
            end
          end
        end

        if lowestSellPrice == math.huge then
          lowestSellPrice = 0.5
        end

        local price = fillLevel * lowestSellPrice * PlaceableSilo.PRICE_SELL_FACTOR
        local fillType = self.fillTypeManager:getFillTypeByIndex(fillTypeIndex)
        local fillText, unit = self.additionalUnits:formatFillLevel(fillLevel, fillType.name, 0)

        warning = string.format("%s%s (%s) - %s: %s\n", warning, fillType.title, fillText .. " " .. unit, self.i18n:getText("ui_sellValue"), self.i18n:formatMoney(price, 0, true, true))

        spec.totalFillTypeSellPrice = spec.totalFillTypeSellPrice + price
      end
    end

    if totalFillLevel > 0 then
      return true, warning
    end

    return true, nil
  end)
end