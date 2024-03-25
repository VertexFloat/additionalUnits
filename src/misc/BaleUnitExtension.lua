-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.0, 13|04|2023
-- @filename: BaleUnitExtension.lua

BaleUnitExtension = {}

local BaleUnitExtension_mt = Class(BaleUnitExtension)

function BaleUnitExtension.new(customMt, additionalUnits, i18n, fillTypeManager)
  local self = setmetatable({}, customMt or BaleUnitExtension_mt)

  self.i18n = i18n
  self.additionalUnits = additionalUnits
  self.fillTypeManager = fillTypeManager

  return self
end

function BaleUnitExtension:initialize()
  self.additionalUnits:overwriteGameFunction(Bale, "showInfo", function (superFunc, bale, box)
    local fillType = bale:getFillType()
    local fillLevel = bale:getFillLevel()
    local fillTypeDesc = self.fillTypeManager:getFillTypeByIndex(fillType)
    local formattedFillLevel, unit = self.additionalUnits:formatFillLevel(fillLevel, fillTypeDesc.name)

    box:addLine(fillTypeDesc.title, self.i18n:formatVolume(formattedFillLevel, unit.precision or 0, unit.shortName))

    if bale:getIsFermenting() then
      box:addLine(self.i18n:getText("info_fermenting"), string.format("%d%%", bale:getFermentingPercentage() * 100))
    end

    box:addLine(self.i18n:getText("infohud_mass"), self.i18n:formatMass(bale:getMass()))
  end)
end