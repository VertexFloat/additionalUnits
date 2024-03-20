-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.0, 13|04|2023
-- @filename: InGameMenuPricesFrameUnitExtension.lua

InGameMenuPricesFrameUnitExtension = {}

local InGameMenuPricesFrameUnitExtension_mt = Class(InGameMenuPricesFrameUnitExtension)

function InGameMenuPricesFrameUnitExtension.new(customMt, additionalUnits)
  local self = setmetatable({}, customMt or InGameMenuPricesFrameUnitExtension_mt)

  self.additionalUnits = additionalUnits

  return self
end

function InGameMenuPricesFrameUnitExtension:initialize()
  self.additionalUnits:overwriteGameFunction(InGameMenuPricesFrame, "populateCellForItemInSection", function (superFunc, inGameMenu, list, section, index, cell)
    superFunc(inGameMenu, list, section, index, cell)

    if list == inGameMenu.productList then
      local fillTypeDesc = inGameMenu.fillTypes[index]
      local usedStorages = {}
      local localLiters = inGameMenu:getStorageFillLevel(fillTypeDesc, true, usedStorages)
      local foreignLiters = inGameMenu:getStorageFillLevel(fillTypeDesc, false, usedStorages)

      if localLiters < 0 and foreignLiters < 0 then
        cell:getAttribute("storage"):setText("-")
      else
        local fillLevel, unit = self.additionalUnits:formatFillLevel(math.max(localLiters, 0) + math.max(foreignLiters, 0), fillTypeDesc.name, 0)

        cell:getAttribute("storage"):setText(fillLevel .. " " .. unit)
      end
    end
  end)
end