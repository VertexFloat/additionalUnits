-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.0, 13|04|2023
-- @filename: FillLevelsDisplayUnitExtension.lua

FillLevelsDisplayUnitExtension = {}

local FillLevelsDisplayUnitExtension_mt = Class(FillLevelsDisplayUnitExtension)

function FillLevelsDisplayUnitExtension.new(customMt, additionalUnits, fillTypeManager)
  local self = setmetatable({}, customMt or FillLevelsDisplayUnitExtension_mt)

  self.additionalUnits = additionalUnits
  self.fillTypeManager = fillTypeManager

  return self
end

function FillLevelsDisplayUnitExtension:initialize()
  self.additionalUnits:overwriteGameFunction(FillLevelsDisplay, "updateFillLevelFrames", function (superFunc, display)
    local _, yOffset = display:getPosition()
    local isFirst = true
print("updateFillLevelFrames")
    for i = 1, #display.fillLevelBuffer do
      local fillLevelInformation = display.fillLevelBuffer[i]

      if fillLevelInformation.capacity > 0 or fillLevelInformation.fillLevel > 0 then
        local value = 0

        if fillLevelInformation.capacity > 0 then
          value = fillLevelInformation.fillLevel / fillLevelInformation.capacity
        end

        local frame = display.fillTypeFrames[fillLevelInformation.fillType]
        frame:setVisible(true)

        local fillBar = display.fillTypeLevelBars[fillLevelInformation.fillType]
        fillBar:setValue(value)

        local baseX = display:getPosition()

        if isFirst then
          baseX = baseX + display.firstFillTypeOffset
        end

        frame:setPosition(baseX, yOffset)

        local fillTypeName, unitShort
        local fillLevel = fillLevelInformation.fillLevel

        if fillLevelInformation.fillType ~= FillType.UNKNOWN then
          local fillTypeDesc = self.fillTypeManager:getFillTypeByIndex(fillLevelInformation.fillType)
print(fillTypeDesc.name)
print(fillLevel)
          local formattedFillLevel, unit = self.additionalUnits:formatFillLevel(fillLevel, fillTypeDesc.name)

          fillTypeName = fillTypeDesc.title
          fillLevel = formattedFillLevel
          unitShort = unit.shortName or fillTypeDesc.unitShort
        end

        local precision = fillLevelInformation.precision or 0
        local formattedNumber

        if precision > 0 then
          local rounded = MathUtil.round(fillLevel, precision)

          formattedNumber = string.format("%d%s%0"..precision.."d", math.floor(rounded), self.i18n.decimalSeparator, (rounded - math.floor(rounded)) * 10 ^ precision)
        else
          formattedNumber = string.format("%d", MathUtil.round(fillLevel))
        end

        display.weightFrames[fillLevelInformation.fillType]:setVisible(fillLevelInformation.maxReached)

        local fillText = string.format("%s%s (%d%%)", formattedNumber, unitShort or "", math.floor(100 * value))
        display.fillLevelTextBuffer[#display.fillLevelTextBuffer + 1] = fillText

        if fillTypeName ~= nil then
          display.fillTypeTextBuffer[#display.fillLevelTextBuffer] = fillTypeName
        end

        yOffset = yOffset + display.frameHeight + display.frameOffsetY
        isFirst = false
      end
    end
  end)
end