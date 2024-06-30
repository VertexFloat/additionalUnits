-- TargetFillLevelUnitExtension.lua
--
-- author: 4c65736975
--
-- Copyright (c) 2024 VertexFloat. All Rights Reserved.
--
-- This source code is licensed under the GPL-3.0 license found in the
-- LICENSE file in the root directory of this source tree.

TargetFillLevelUnitExtension = {
  OBJECT = _G["FS22_TargetFillLevel"]
}

function TargetFillLevelUnitExtension:addFillLevelDisplay(superFunc, targetVehicle, display)
  if targetVehicle.getFillLevelInformation == nil then
    return
  end

  local spec = targetVehicle.spec_fillUnit

  for i = 1, #spec.fillUnits do
    local fillUnit = spec.fillUnits[i]

    if fillUnit.capacity > 0 and fillUnit.showOnHud then
      local fillLevel = fillUnit.fillLevel

      if fillUnit.fillLevelToDisplay ~= nil then
        fillLevel = fillUnit.fillLevelToDisplay
      end

      local capacity = fillUnit.capacity

      if fillUnit.parentUnitOnHud ~= nil then
        capacity = 0
      end

      display.targetVehicle = {
        vehicle = targetVehicle,
        fillType = fillUnit.fillType
      }

      display:addFillLevel(self:getFillType(), fillLevel, capacity)
    end
  end
end

function TargetFillLevelUnitExtension:overwriteGameFunctions()
  TargetFillLevelUnitExtension.OBJECT.TargetFillLevel.addFillLevelDisplay = Utils.overwrittenFunction(TargetFillLevelUnitExtension.OBJECT.TargetFillLevel.addFillLevelDisplay, TargetFillLevelUnitExtension.addFillLevelDisplay)
end