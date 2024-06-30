-- FillLevelsDisplayUnitExtension.lua
--
-- author: 4c65736975
--
-- Copyright (c) 2024 VertexFloat. All Rights Reserved.
--
-- This source code is licensed under the GPL-3.0 license found in the
-- LICENSE file in the root directory of this source tree.

FillLevelsDisplayUnitExtension = {}

function FillLevelsDisplayUnitExtension:updateFillLevelFrames(superFunc)
  local _, yOffset = self:getPosition()
  local isFirst = true

  for i = 1, #self.fillLevelBuffer do
    local fillLevelInformation = self.fillLevelBuffer[i]

    if fillLevelInformation.capacity > 0 or fillLevelInformation.fillLevel > 0 then
      local value = 0

      if fillLevelInformation.capacity > 0 then
        value = fillLevelInformation.fillLevel / fillLevelInformation.capacity
      end

      local frame = self.fillTypeFrames[fillLevelInformation.fillType]
      frame:setVisible(true)

      local fillBar = self.fillTypeLevelBars[fillLevelInformation.fillType]
      fillBar:setValue(value)

      local baseX = self:getPosition()

      if isFirst then
        baseX = baseX + self.firstFillTypeOffset
      end

      frame:setPosition(baseX, yOffset)

      local fillTypeName, unitShort
      local fillLevel = fillLevelInformation.fillLevel

      if fillLevelInformation.fillType ~= FillType.UNKNOWN then
        local fillTypeDesc = g_fillTypeManager:getFillTypeByIndex(fillLevelInformation.fillType)
        local targetVehicle = self.targetVehicle

        if targetVehicle ~= nil and targetVehicle.vehicle ~= nil and targetVehicle.vehicle ~= self.vehicle then
          fillTypeDesc = g_fillTypeManager:getFillTypeByIndex(targetVehicle.fillType)

          self.targetVehicle = nil
        end

        local formattedFillLevel, unit = g_additionalUnits:formatFillLevel(fillLevel, fillTypeDesc.name)

        fillTypeName = fillTypeDesc.title
        fillLevel = formattedFillLevel
        unitShort = unit.shortName or fillTypeDesc.unitShort
      end

      local precision = fillLevelInformation.precision or 0
      local formattedNumber

      if precision > 0 then
        local rounded = MathUtil.round(fillLevel, precision)

        formattedNumber = string.format("%d%s%0"..precision.."d", math.floor(rounded), g_i18n.decimalSeparator, (rounded - math.floor(rounded)) * 10 ^ precision)
      else
        formattedNumber = string.format("%d", MathUtil.round(fillLevel))
      end

      self.weightFrames[fillLevelInformation.fillType]:setVisible(fillLevelInformation.maxReached)

      local fillText = string.format("%s%s (%d%%)", formattedNumber, unitShort or "", math.floor(100 * value))
      self.fillLevelTextBuffer[#self.fillLevelTextBuffer + 1] = fillText

      if fillTypeName ~= nil then
        self.fillTypeTextBuffer[#self.fillLevelTextBuffer] = fillTypeName
      end

      yOffset = yOffset + self.frameHeight + self.frameOffsetY
      isFirst = false
    end
  end
end

function FillLevelsDisplayUnitExtension:overwriteGameFunctions()
  FillLevelsDisplay.updateFillLevelFrames = Utils.overwrittenFunction(FillLevelsDisplay.updateFillLevelFrames, FillLevelsDisplayUnitExtension.updateFillLevelFrames)
end