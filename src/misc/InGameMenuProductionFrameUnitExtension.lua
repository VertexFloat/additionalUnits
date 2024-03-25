-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.0, 13|04|2023
-- @filename: InGameMenuProductionFrameUnitExtension.lua

InGameMenuProductionFrameUnitExtension = {}

local InGameMenuProductionFrameUnitExtension_mt = Class(InGameMenuProductionFrameUnitExtension)

function InGameMenuProductionFrameUnitExtension.new(customMt, additionalUnits, i18n, fillTypeManager)
  local self = setmetatable({}, customMt or InGameMenuProductionFrameUnitExtension_mt)

  self.i18n = i18n
  self.additionalUnits = additionalUnits
  self.fillTypeManager = fillTypeManager

  return self
end

function InGameMenuProductionFrameUnitExtension:initialize()
  self.additionalUnits:overwriteGameFunction(InGameMenuProductionFrame, "populateCellForItemInSection", function (superFunc, inGameMenu, list, section, index, cell)
    superFunc(inGameMenu, list, section, index, cell)

    if list ~= inGameMenu.productionList then
      local fillType = nil

      if section == 1 then
        fillType = inGameMenu.selectedProductionPoint.inputFillTypeIdsArray[index]
      else
        fillType = inGameMenu.selectedProductionPoint.outputFillTypeIdsArray[index]
      end

      if fillType ~= FillType.UNKNOWN then
        local fillLevel = inGameMenu.selectedProductionPoint:getFillLevel(fillType)
        local fillTypeDesc = self.fillTypeManager:getFillTypeByIndex(fillType)
        local formattedFillLevel, unit = self.additionalUnits:formatFillLevel(fillLevel, fillTypeDesc.name)

        cell:getAttribute("fillLevel"):setText(self.i18n:formatVolume(formattedFillLevel, 0, unit.shortName))
      end
    end
  end)
end