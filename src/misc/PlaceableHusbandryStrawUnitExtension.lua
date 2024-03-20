-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.0, 13|04|2023
-- @filename: PlaceableHusbandryStrawUnitExtension.lua

PlaceableHusbandryStrawUnitExtension = {}

local PlaceableHusbandryStrawUnitExtension_mt = Class(PlaceableHusbandryStrawUnitExtension)

function PlaceableHusbandryStrawUnitExtension.new(customMt, additionalUnits, fillTypeManager)
  local self = setmetatable({}, customMt or PlaceableHusbandryStrawUnitExtension_mt)

  self.additionalUnits = additionalUnits
  self.fillTypeManager = fillTypeManager

  return self
end

function PlaceableHusbandryStrawUnitExtension:initialize()
  self.additionalUnits:overwriteGameFunction(PlaceableHusbandryStraw, "getConditionInfos", function (_, husbandry, superFunc)
    local infos = superFunc(husbandry)
    local spec = husbandry.spec_husbandryStraw

    local info = {}
    local fillType = self.fillTypeManager:getFillTypeByIndex(spec.inputFillType)
    local capacity = husbandry:getHusbandryCapacity(spec.inputFillType)
    local ratio = 0

    info.title = fillType.title
    info.fillType = fillType.name
    info.value = husbandry:getHusbandryFillLevel(spec.inputFillType)

    if capacity > 0 then
      ratio = info.value / capacity
    end

    info.ratio = MathUtil.clamp(ratio, 0, 1)
    info.invertedBar = true

    table.insert(infos, info)

    return infos
  end)

  self.additionalUnits:overwriteGameFunction(PlaceableHusbandryStraw, "updateInfo", function (_, husbandry, superFunc, infoTable)
    superFunc(husbandry, infoTable)

    local spec = husbandry.spec_husbandryStraw
    local fillLevel = husbandry:getHusbandryFillLevel(spec.inputFillType)
    local formattedFillLevel, unit = self.additionalUnits:formatFillLevel(fillLevel, self.fillTypeManager:getFillTypeNameByIndex(spec.inputFillType), 0)

    spec.info.text = formattedFillLevel .. " " .. unit

    table.insert(infoTable, spec.info)
  end)
end