-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.0, 13|04|2023
-- @filename: InGameMenuAnimalsFrameUnitExtension.lua

InGameMenuAnimalsFrameUnitExtension = {}

local InGameMenuAnimalsFrameUnitExtension_mt = Class(InGameMenuAnimalsFrameUnitExtension)

function InGameMenuAnimalsFrameUnitExtension.new(customMt, additionalUnits, fillTypeManager)
  local self = setmetatable({}, customMt or InGameMenuAnimalsFrameUnitExtension_mt)

  self.additionalUnits = additionalUnits
  self.fillTypeManager = fillTypeManager

  return self
end

function InGameMenuAnimalsFrameUnitExtension:initialize()
  self.additionalUnits:overwriteGameFunction(InGameMenuAnimalsFrame, "updateConditionDisplay", function (superFunc, inGameMenu, husbandry)
    superFunc(inGameMenu, husbandry)

    local infos = husbandry:getConditionInfos()

    for index, row in ipairs(inGameMenu.conditionRow) do
      local info = infos[index]

      if info ~= nil then
        local fillLevel, unit = self.additionalUnits:formatFillLevel(info.value, info.fillType, 0, false, info.customUnitText)
        local valueText = info.valueText or fillLevel .. " " .. unit

        inGameMenu.conditionValue[index]:setText(valueText)
      end
    end
  end)

  self.additionalUnits:overwriteGameFunction(InGameMenuAnimalsFrame, "updateFoodDisplay", function (superFunc, inGameMenu, husbandry)
    superFunc(inGameMenu, husbandry)

    local infos = husbandry:getFoodInfos()

    for index, row in ipairs(inGameMenu.foodRow) do
      local info = infos[index]

      if info ~= nil then
        local fillLevel, unit = self.additionalUnits:formatFillLevel(info.value, self.fillTypeManager:getFillTypeNameByIndex(info.fillType), 0, false)
        local valueText = fillLevel .. " " .. unit

        inGameMenu.foodValue[index]:setText(valueText)
      end
    end
  end)
end