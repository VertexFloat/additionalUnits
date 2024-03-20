-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.0, 13|04|2023
-- @filename: FeedingRobotUnitExtension.lua

FeedingRobotUnitExtension = {}

local FeedingRobotUnitExtension_mt = Class(FeedingRobotUnitExtension)

function FeedingRobotUnitExtension.new(customMt, additionalUnits, fillTypeManager)
  local self = setmetatable({}, customMt or FeedingRobotUnitExtension_mt)

  self.additionalUnits = additionalUnits
  self.fillTypeManager = fillTypeManager

  return self
end

function FeedingRobotUnitExtension:initialize()
  self.additionalUnits:overwriteGameFunction(FeedingRobot, "updateInfo", function (superFunc, robot, infoTable)
    if robot.infos ~= nil then
      for _, info in ipairs(robot.infos) do
        local fillLevel = 0
        local fillTypeName = "UNKNOWN"

        for _, fillType in ipairs(info.fillTypes) do
          fillLevel = fillLevel + robot:getFillLevel(fillType)
          fillTypeName = self.fillTypeManager:getFillTypeNameByIndex(fillType)
        end

        local fillText, unit = self.additionalUnits:formatFillLevel(fillLevel, fillTypeName, 0, false)

        info.text = string.format("%d %s", fillText, unit)

        table.insert(infoTable, info)
      end
    end
  end)
end