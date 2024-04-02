-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.0, 13|04|2023
-- @filename: PlaceableManureHeapUnitExtension.lua

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