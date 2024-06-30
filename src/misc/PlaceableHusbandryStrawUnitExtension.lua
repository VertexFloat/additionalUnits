-- PlaceableHusbandryStrawUnitExtension.lua
--
-- author: 4c65736975
--
-- Copyright (c) 2024 VertexFloat. All Rights Reserved.
--
-- This source code is licensed under the GPL-3.0 license found in the
-- LICENSE file in the root directory of this source tree.

PlaceableHusbandryStrawUnitExtension = {}

function PlaceableHusbandryStrawUnitExtension:getConditionInfos(_, superFunc)
  local infos = superFunc(self)
  local spec = self.spec_husbandryStraw

  local info = {}
  local fillType = g_fillTypeManager:getFillTypeByIndex(spec.inputFillType)
  local capacity = self:getHusbandryCapacity(spec.inputFillType)
  local ratio = 0

  info.title = fillType.title
  info.fillType = fillType.name
  info.value = self:getHusbandryFillLevel(spec.inputFillType)

  if capacity > 0 then
    ratio = info.value / capacity
  end

  info.ratio = MathUtil.clamp(ratio, 0, 1)
  info.invertedBar = true

  table.insert(infos, info)

  return infos
end

function PlaceableHusbandryStrawUnitExtension:updateInfo(_, superFunc, infoTable)
  superFunc(self, infoTable)

  local spec = self.spec_husbandryStraw
  local fillLevel = self:getHusbandryFillLevel(spec.inputFillType)
  local formattedFillLevel, unit = g_additionalUnits:formatFillLevel(fillLevel, g_fillTypeManager:getFillTypeNameByIndex(spec.inputFillType))

  spec.info.text = g_i18n:formatVolume(formattedFillLevel, 0, unit.shortName)

  table.insert(infoTable, spec.info)
end

function PlaceableHusbandryStrawUnitExtension:overwriteGameFunctions()
  PlaceableHusbandryStraw.getConditionInfos = Utils.overwrittenFunction(PlaceableHusbandryStraw.getConditionInfos, PlaceableHusbandryStrawUnitExtension.getConditionInfos)

  if not g_modIsLoaded.FS22_InfoDisplayExtension then
    PlaceableHusbandryStraw.updateInfo = Utils.overwrittenFunction(PlaceableHusbandryStraw.updateInfo, PlaceableHusbandryStrawUnitExtension.updateInfo)
  end
end