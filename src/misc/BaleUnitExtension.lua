-- BaleUnitExtension.lua
--
-- author: 4c65736975
--
-- Copyright (c) 2024 VertexFloat. All Rights Reserved.
--
-- This source code is licensed under the GPL-3.0 license found in the
-- LICENSE file in the root directory of this source tree.

BaleUnitExtension = {}

function BaleUnitExtension:showInfo(superFunc, box)
  local fillType = self:getFillType()
  local fillLevel = self:getFillLevel()
  local fillTypeDesc = g_fillTypeManager:getFillTypeByIndex(fillType)
  local formattedFillLevel, unit = g_additionalUnits:formatFillLevel(fillLevel, fillTypeDesc.name)

  box:addLine(fillTypeDesc.title, g_i18n:formatVolume(formattedFillLevel, unit.precision or 0, unit.shortName))

  if self:getIsFermenting() then
    box:addLine(g_i18n:getText("info_fermenting"), string.format("%d%%", self:getFermentingPercentage() * 100))
  end

  box:addLine(g_i18n:getText("infohud_mass"), g_i18n:formatMass(self:getMass()))
end

function BaleUnitExtension:overwriteGameFunctions()
  Bale.showInfo = Utils.overwrittenFunction(Bale.showInfo, BaleUnitExtension.showInfo)
end