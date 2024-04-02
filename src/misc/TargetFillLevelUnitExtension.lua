-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.0, 24|03|2024
-- @filename: TargetFillLevelUnitExtension.lua

TargetFillLevelUnitExtension = {
  OBJECT = _G["FS22_TargetFillLevel"].TargetFillLevel
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
  TargetFillLevelUnitExtension.OBJECT.addFillLevelDisplay = Utils.overwrittenFunction(TargetFillLevelUnitExtension.OBJECT.addFillLevelDisplay, TargetFillLevelUnitExtension.addFillLevelDisplay)
end