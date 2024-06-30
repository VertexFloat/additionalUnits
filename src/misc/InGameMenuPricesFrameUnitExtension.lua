-- InGameMenuPricesFrameUnitExtension.lua
--
-- author: 4c65736975
--
-- Copyright (c) 2024 VertexFloat. All Rights Reserved.
--
-- This source code is licensed under the GPL-3.0 license found in the
-- LICENSE file in the root directory of this source tree.

InGameMenuPricesFrameUnitExtension = {}

function InGameMenuPricesFrameUnitExtension:populateCellForItemInSection(superFunc, list, section, index, cell)
  superFunc(self, list, section, index, cell)

  if list == self.productList then
    local fillTypeDesc = self.fillTypes[index]
    local usedStorages = {}
    local localLiters = self:getStorageFillLevel(fillTypeDesc, true, usedStorages)
    local foreignLiters = self:getStorageFillLevel(fillTypeDesc, false, usedStorages)

    if localLiters < 0 and foreignLiters < 0 then
      cell:getAttribute("storage"):setText("-")
    else
      local formattedFillLevel, unit = g_additionalUnits:formatFillLevel(math.max(localLiters, 0) + math.max(foreignLiters, 0), fillTypeDesc.name)

      cell:getAttribute("storage"):setText(g_i18n:formatVolume(formattedFillLevel, 0, unit.shortName))
    end
  end
end

function InGameMenuPricesFrameUnitExtension:overwriteGameFunctions()
  InGameMenuPricesFrame.populateCellForItemInSection = Utils.overwrittenFunction(InGameMenuPricesFrame.populateCellForItemInSection, InGameMenuPricesFrameUnitExtension.populateCellForItemInSection)
end