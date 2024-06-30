-- InGameMenuProductionFrameUnitExtension.lua
--
-- author: 4c65736975
--
-- Copyright (c) 2024 VertexFloat. All Rights Reserved.
--
-- This source code is licensed under the GPL-3.0 license found in the
-- LICENSE file in the root directory of this source tree.

InGameMenuProductionFrameUnitExtension = {}

function InGameMenuProductionFrameUnitExtension:populateCellForItemInSection(superFunc, list, section, index, cell)
  superFunc(self, list, section, index, cell)

  if list ~= self.productionList then
    local fillType = nil

    if section == 1 then
      fillType = self.selectedProductionPoint.inputFillTypeIdsArray[index]
    else
      fillType = self.selectedProductionPoint.outputFillTypeIdsArray[index]
    end

    if fillType ~= FillType.UNKNOWN then
      local fillLevel = self.selectedProductionPoint:getFillLevel(fillType)
      local fillTypeDesc = g_fillTypeManager:getFillTypeByIndex(fillType)
      local formattedFillLevel, unit = g_additionalUnits:formatFillLevel(fillLevel, fillTypeDesc.name)

      cell:getAttribute("fillLevel"):setText(g_i18n:formatVolume(formattedFillLevel, 0, unit.shortName))
    end
  end
end

function InGameMenuProductionFrameUnitExtension:overwriteGameFunctions()
  InGameMenuProductionFrame.populateCellForItemInSection = Utils.overwrittenFunction(InGameMenuProductionFrame.populateCellForItemInSection, InGameMenuProductionFrameUnitExtension.populateCellForItemInSection)
end