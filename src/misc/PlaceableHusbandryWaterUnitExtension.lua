-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.1, 02|05|2023
-- @filename: PlaceableHusbandryWaterUnitExtension.lua

-- Changelog (1.0.0.1):
-- fixed issue where water fill level is still visible even when husbandry has automatic water supply

PlaceableHusbandryWaterUnitExtension = {}

local PlaceableHusbandryWaterUnitExtension_mt = Class(PlaceableHusbandryWaterUnitExtension)

function PlaceableHusbandryWaterUnitExtension.new(customMt, additionalUnits, i18n, fillTypeManager)
  local self = setmetatable({}, customMt or PlaceableHusbandryWaterUnitExtension_mt)

  self.i18n = i18n
  self.additionalUnits = additionalUnits
  self.fillTypeManager = fillTypeManager

  return self
end

function PlaceableHusbandryWaterUnitExtension:initialize()
  self.additionalUnits:overwriteGameFunction(PlaceableHusbandryWater, "getConditionInfos", function (_, husbandry, superFunc)
    local infos = superFunc(husbandry)
    local spec = husbandry.spec_husbandryWater

    if not spec.automaticWaterSupply then
      local info = {}
      local fillType = self.fillTypeManager:getFillTypeByIndex(spec.fillType)
      local capacity = husbandry:getHusbandryCapacity(spec.fillType)
      local ratio = 0

      info.title = fillType.title
      info.fillType = fillType.name
      info.value = husbandry:getHusbandryFillLevel(spec.fillType)

      if capacity > 0 then
        ratio = info.value / capacity
      end

      info.ratio = MathUtil.clamp(ratio, 0, 1)
      info.invertedBar = true

      table.insert(infos, info)
    end

    return infos
  end)

  self.additionalUnits:overwriteGameFunction(PlaceableHusbandryWater, "updateInfo", function (_, husbandry, superFunc, infoTable)
    superFunc(husbandry, infoTable)

    local spec = husbandry.spec_husbandryWater

    if not spec.automaticWaterSupply then
      local fillLevel = husbandry:getHusbandryFillLevel(spec.fillType)
      local formattedFillLevel, unit = self.additionalUnits:formatFillLevel(fillLevel, self.fillTypeManager:getFillTypeNameByIndex(spec.fillType))

      spec.info.text = self.i18n:formatVolume(formattedFillLevel, 0, unit.shortName)

      table.insert(infoTable, spec.info)
    end
  end)
end