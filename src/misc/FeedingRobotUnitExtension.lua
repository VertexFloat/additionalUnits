-- FeedingRobotUnitExtension.lua
--
-- author: 4c65736975
--
-- Copyright (c) 2024 VertexFloat. All Rights Reserved.
--
-- This source code is licensed under the GPL-3.0 license found in the
-- LICENSE file in the root directory of this source tree.

FeedingRobotUnitExtension = {}

function FeedingRobotUnitExtension:updateInfo(superFunc, infoTable)
  if self.infos ~= nil then
    for _, info in ipairs(self.infos) do
      local fillLevel = 0
      local fillTypeName = "UNKNOWN"

      for _, fillType in ipairs(info.fillTypes) do
        fillLevel = fillLevel + self:getFillLevel(fillType)
        fillTypeName = g_fillTypeManager:getFillTypeNameByIndex(fillType)
      end

      local formattedFillLevel, unit = g_additionalUnits:formatFillLevel(fillLevel, fillTypeName)

      info.text = string.format("%d %s", formattedFillLevel, unit.shortName)

      table.insert(infoTable, info)
    end
  end
end

function FeedingRobotUnitExtension:overwriteGameFunctions()
  if not g_modIsLoaded.FS22_InfoDisplayExtension then
    FeedingRobot.updateInfo = Utils.overwrittenFunction(FeedingRobot.updateInfo, FeedingRobotUnitExtension.updateInfo)
  end
end