-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.0, 13|04|2023
-- @filename: FillUnitUnitExtension.lua

FillUnitUnitExtension = {}

local FillUnitUnitExtension_mt = Class(FillUnitUnitExtension)

function FillUnitUnitExtension.new(customMt, additionalUnits, fillTypeManager)
  local self = setmetatable({}, customMt or FillUnitUnitExtension_mt)

  self.additionalUnits = additionalUnits
  self.fillTypeManager = fillTypeManager

  return self
end

function FillUnitUnitExtension:initialize()
  self.additionalUnits:overwriteGameFunction(FillUnit, "showInfo", function (_, fillUnit, superFunc, box)
    local spec = fillUnit.spec_fillUnit

    if spec.isInfoDirty then
      spec.fillUnitInfos = {}

      local fillTypeToInfo = {}

      for _, fillUnit in ipairs(spec.fillUnits) do
        if fillUnit.showOnInfoHud and fillUnit.fillLevel > 0 then
          local info = fillTypeToInfo[fillUnit.fillType]

          if info == nil then
            local fillType = self.fillTypeManager:getFillTypeByIndex(fillUnit.fillType)

            info = {title = fillType.title, name = fillType.name, fillLevel = 0, unit = fillUnit.unitText, precision = 0}

            fillTypeToInfo[fillUnit.fillType] = info

            table.insert(spec.fillUnitInfos, info)
          end

          info.fillLevel = info.fillLevel + fillUnit.fillLevel

          if info.precision == 0 and fillUnit.fillLevel > 0 then
            info.precision = fillUnit.uiPrecision or 0
          end
        end
      end

      spec.isInfoDirty = false
    end

    for _, info in ipairs(spec.fillUnitInfos) do
      local fillText, unit = self.additionalUnits:formatFillLevel(info.fillLevel, info.name, info.precision)

      box:addLine(info.title, fillText .. " " .. (unit or info.unit))
    end

    superFunc(fillUnit, box)
  end)
end