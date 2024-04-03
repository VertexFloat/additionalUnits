-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.1, 02|05|2023
-- @filename: PlaceableHusbandryWaterUnitExtension.lua

-- Changelog (1.0.0.1):
-- fixed issue where water fill level is still visible even when husbandry has automatic water supply

PlaceableHusbandryWaterUnitExtension = {}

function PlaceableHusbandryWaterUnitExtension:getConditionInfos(_, superFunc)
  local infos = superFunc(self)
  local spec = self.spec_husbandryWater

  if not spec.automaticWaterSupply then
    local info = {}
    local fillType = g_fillTypeManager:getFillTypeByIndex(spec.fillType)
    local capacity = self:getHusbandryCapacity(spec.fillType)
    local ratio = 0

    info.title = fillType.title
    info.fillType = fillType.name
    info.value = self:getHusbandryFillLevel(spec.fillType)

    if capacity > 0 then
      ratio = info.value / capacity
    end

    info.ratio = MathUtil.clamp(ratio, 0, 1)
    info.invertedBar = true

    table.insert(infos, info)
  end

  return infos
end

function PlaceableHusbandryWaterUnitExtension:updateInfo(_, superFunc, infoTable)
  superFunc(self, infoTable)

  local spec = self.spec_husbandryWater

  if not spec.automaticWaterSupply then
    local fillLevel = self:getHusbandryFillLevel(spec.fillType)
    local formattedFillLevel, unit = g_additionalUnits:formatFillLevel(fillLevel, g_fillTypeManager:getFillTypeNameByIndex(spec.fillType))

    spec.info.text = g_i18n:formatVolume(formattedFillLevel, 0, unit.shortName)

    table.insert(infoTable, spec.info)
  end
end

function PlaceableHusbandryWaterUnitExtension:overwriteGameFunctions()
  PlaceableHusbandryWater.getConditionInfos = Utils.overwrittenFunction(PlaceableHusbandryWater.getConditionInfos, PlaceableHusbandryWaterUnitExtension.getConditionInfos)

  if not g_modIsLoaded.FS22_InfoDisplayExtension then
    PlaceableHusbandryWater.updateInfo = Utils.overwrittenFunction(PlaceableHusbandryWater.updateInfo, PlaceableHusbandryWaterUnitExtension.updateInfo)
  end
end