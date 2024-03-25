-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.0, 13|04|2023
-- @filename: SiloDialogUnitExtension.lua

SiloDialogUnitExtension = {}

local SiloDialogUnitExtension_mt = Class(SiloDialogUnitExtension)

function SiloDialogUnitExtension.new(customMt, additionalUnits, i18n, fillTypeManager)
  local self = setmetatable({}, customMt or SiloDialogUnitExtension_mt)

  self.i18n = i18n
  self.additionalUnits = additionalUnits
  self.fillTypeManager = fillTypeManager

  return self
end

function SiloDialogUnitExtension:initialize()
  self.additionalUnits:overwriteGameFunction(SiloDialog, "setFillLevels", function (superFunc, dialog, fillLevels, hasInfiniteCapacity)
    dialog.fillLevels = fillLevels
    dialog.fillTypeMapping = {}

    local fillTypesTable = {}
    local selectedId = 1
    local numFillLevels = 1

    for fillTypeIndex, _ in pairs(fillLevels) do
      local fillType = self.fillTypeManager:getFillTypeByIndex(fillTypeIndex)
      local level = Utils.getNoNil(fillLevels[fillTypeIndex], 0)
      local formattedFillLevel, unit = self.additionalUnits:formatFillLevel(level, fillType.name)
      local name = nil

      if hasInfiniteCapacity then
        name = string.format("%s", fillType.title)
      else
        name = string.format("%s %s", fillType.title, self.i18n:formatVolume(formattedFillLevel, 0, unit.shortName))
      end

      table.insert(fillTypesTable, name)
      table.insert(dialog.fillTypeMapping, fillTypeIndex)

      if fillTypeIndex == dialog.lastSelectedFillType then
        selectedId = numFillLevels
      end

      numFillLevels = numFillLevels + 1
    end

    dialog.fillTypesElement:setTexts(fillTypesTable)
    dialog.fillTypesElement:setState(selectedId, true)
  end)
end