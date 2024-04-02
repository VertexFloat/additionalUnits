-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.0, 13|04|2023
-- @filename: PlaceableHusbandryMilkUnitExtension.lua

PlaceableHusbandryMilkUnitExtension = {}

function PlaceableHusbandryMilkUnitExtension:getConditionInfos(_, superFunc)
  local infos = superFunc(self)
  local spec = self.spec_husbandryMilk

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

  return infos
end

function PlaceableHusbandryMilkUnitExtension:updateInfo(_, superFunc, infoTable)
  superFunc(self, infoTable)

  local spec = self.spec_husbandryMilk
  local fillLevel = self:getHusbandryFillLevel(spec.fillType)
  local formattedFillLevel, unit = g_additionalUnits:formatFillLevel(fillLevel, g_fillTypeManager:getFillTypeNameByIndex(spec.fillType))

  spec.info.text = g_i18n:formatVolume(formattedFillLevel, 0, unit.shortName)

  table.insert(infoTable, spec.info)
end

function PlaceableHusbandryMilkUnitExtension:overwriteGameFunctions()
  PlaceableHusbandryMilk.getConditionInfos = Utils.overwrittenFunction(PlaceableHusbandryMilk.getConditionInfos, PlaceableHusbandryMilkUnitExtension.getConditionInfos)

  if not g_modIsLoaded.FS22_InfoDisplayExtension then
    PlaceableHusbandryMilk.updateInfo = Utils.overwrittenFunction(PlaceableHusbandryMilk.updateInfo, PlaceableHusbandryMilkUnitExtension.updateInfo)
  end
end