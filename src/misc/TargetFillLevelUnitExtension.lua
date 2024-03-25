-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.0, 24|03|2024
-- @filename: TargetFillLevelUnitExtension.lua

TargetFillLevelUnitExtension = {}

local TargetFillLevelUnitExtension_mt = Class(TargetFillLevelUnitExtension)

function TargetFillLevelUnitExtension.new(customMt, additionalUnits)
  local self = setmetatable({}, customMt or TargetFillLevelUnitExtension_mt)

  self.additionalUnits = additionalUnits

  return self
end

function TargetFillLevelUnitExtension:loadMap()
  local target = _G["FS22_TargetFillLevel"].TargetFillLevel

  self.additionalUnits:overwriteGameFunction(target, "addFillLevelDisplay", function (superFunc, targetFillLevel, targetVehicle, display)
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

        display:addFillLevel(targetFillLevel:getFillType(), fillLevel, capacity)
      end
    end
  end)
end