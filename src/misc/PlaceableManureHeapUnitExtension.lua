-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.0, 13|04|2023
-- @filename: PlaceableManureHeapUnitExtension.lua

PlaceableManureHeapUnitExtension = {}

local PlaceableManureHeapUnitExtension_mt = Class(PlaceableManureHeapUnitExtension)

function PlaceableManureHeapUnitExtension.new(customMt, additionalUnits, fillTypeManager)
  local self = setmetatable({}, customMt or PlaceableManureHeapUnitExtension_mt)

  self.additionalUnits = additionalUnits
  self.fillTypeManager = fillTypeManager

  return self
end

function PlaceableManureHeapUnitExtension:initialize()
  self.additionalUnits:overwriteGameFunction(PlaceableManureHeap, "updateInfo", function (_, heap, superFunc, infoTable)
    superFunc(heap, infoTable)

    local spec = heap.spec_manureHeap

    if spec.manureHeap == nil then
      return
    end

    local fillLevel = spec.manureHeap:getFillLevel(spec.manureHeap.fillTypeIndex)
    local fillText, unit = self.additionalUnits:formatFillLevel(fillLevel, self.fillTypeManager:getFillTypeNameByIndex(spec.manureHeap.fillTypeIndex), 0)

    spec.infoFillLevel.text = fillText .. " " .. unit

    table.insert(infoTable, spec.infoFillLevel)
  end)
end