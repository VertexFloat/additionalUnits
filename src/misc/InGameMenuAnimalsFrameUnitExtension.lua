-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.0, 13|04|2023
-- @filename: InGameMenuAnimalsFrameUnitExtension.lua

InGameMenuAnimalsFrameUnitExtension = {}

local InGameMenuAnimalsFrameUnitExtension_mt = Class(InGameMenuAnimalsFrameUnitExtension)

function InGameMenuAnimalsFrameUnitExtension.new(customMt, additionalUnits, i18n, fillTypeManager)
  local self = setmetatable({}, customMt or InGameMenuAnimalsFrameUnitExtension_mt)

  self.i18n = i18n
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
        local formattedFillLevel, unit = self.additionalUnits:formatFillLevel(info.value, info.fillType)
        local valueText = info.valueText or self.i18n:formatVolume(formattedFillLevel, 0, info.customUnitText or unit.shortName)

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
        local formattedFillLevel, unit = self.additionalUnits:formatFillLevel(info.value, self.fillTypeManager:getFillTypeNameByIndex(info.fillType))
        local valueText = self.i18n:formatVolume(formattedFillLevel, 0, unit.shortName)

        inGameMenu.foodValue[index]:setText(valueText)
      end
    end
  end)
end