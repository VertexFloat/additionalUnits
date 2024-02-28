-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.0, 13|04|2023
-- @filename: InGameMenuProductionFrameUnitExtension.lua

InGameMenuProductionFrameUnitExtension = {}

local InGameMenuProductionFrameUnitExtension_mt = Class(InGameMenuProductionFrameUnitExtension)

---Creating InGameMenuProductionFrameUnitExtension instance
---@param additionalUnits table additionalUnits object
---@param fillTypeManager table fillTypeManager object
---@return table instance instance of object
function InGameMenuProductionFrameUnitExtension.new(customMt, additionalUnits, fillTypeManager)
  local self = setmetatable({}, customMt or InGameMenuProductionFrameUnitExtension_mt)

  self.additionalUnits = additionalUnits
  self.fillTypeManager = fillTypeManager

  return self
end

---Initializing InGameMenuProductionFrameUnitExtension
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
        local fillText, unit = self.additionalUnits:formatFillLevel(fillLevel, fillTypeDesc.name, 0)

        cell:getAttribute("fillLevel"):setText(fillText .. " " .. unit)
      end
    end
  end)
end