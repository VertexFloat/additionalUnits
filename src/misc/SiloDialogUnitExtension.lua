-- SiloDialogUnitExtension.lua
--
-- author: 4c65736975
--
-- Copyright (c) 2024 VertexFloat. All Rights Reserved.
--
-- This source code is licensed under the GPL-3.0 license found in the
-- LICENSE file in the root directory of this source tree.

SiloDialogUnitExtension = {}

function SiloDialogUnitExtension:setFillLevels(superFunc, fillLevels, hasInfiniteCapacity)
  self.fillLevels = fillLevels
  self.fillTypeMapping = {}

  local fillTypesTable = {}
  local selectedId = 1
  local numFillLevels = 1

  for fillTypeIndex, _ in pairs(fillLevels) do
    local fillType = g_fillTypeManager:getFillTypeByIndex(fillTypeIndex)
    local level = Utils.getNoNil(fillLevels[fillTypeIndex], 0)
    local formattedFillLevel, unit = g_additionalUnits:formatFillLevel(level, fillType.name)
    local name = nil

    if hasInfiniteCapacity then
      name = string.format("%s", fillType.title)
    else
      name = string.format("%s %s", fillType.title, g_i18n:formatVolume(formattedFillLevel, 0, unit.shortName))
    end

    table.insert(fillTypesTable, name)
    table.insert(self.fillTypeMapping, fillTypeIndex)

    if fillTypeIndex == self.lastSelectedFillType then
      selectedId = numFillLevels
    end

    numFillLevels = numFillLevels + 1
  end

  self.fillTypesElement:setTexts(fillTypesTable)
  self.fillTypesElement:setState(selectedId, true)
end

function SiloDialogUnitExtension:overwriteGameFunctions()
  SiloDialog.setFillLevels = Utils.overwrittenFunction(SiloDialog.setFillLevels, SiloDialogUnitExtension.setFillLevels)
end