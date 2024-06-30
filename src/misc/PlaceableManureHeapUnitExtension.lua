-- PlaceableManureHeapUnitExtension.lua
--
-- author: 4c65736975
--
-- Copyright (c) 2024 VertexFloat. All Rights Reserved.
--
-- This source code is licensed under the GPL-3.0 license found in the
-- LICENSE file in the root directory of this source tree.

PlaceableManureHeapUnitExtension = {}

function PlaceableManureHeapUnitExtension:updateInfo(_, superFunc, infoTable)
  superFunc(self, infoTable)

  local spec = self.spec_manureHeap

  if spec.manureHeap == nil then
    return
  end

  local fillLevel = spec.manureHeap:getFillLevel(spec.manureHeap.fillTypeIndex)
  local formattedFillLevel, unit = g_additionalUnits:formatFillLevel(fillLevel, g_fillTypeManager:getFillTypeNameByIndex(spec.manureHeap.fillTypeIndex))

  spec.infoFillLevel.text = g_i18n:formatVolume(formattedFillLevel, 0, unit.shortName)

  table.insert(infoTable, spec.infoFillLevel)
end

function PlaceableManureHeapUnitExtension:overwriteGameFunctions()
  if not g_modIsLoaded.FS22_InfoDisplayExtension then
    PlaceableManureHeap.updateInfo = Utils.overwrittenFunction(PlaceableManureHeap.updateInfo, PlaceableManureHeapUnitExtension.updateInfo)
  end
end