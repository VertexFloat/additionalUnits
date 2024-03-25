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

            info = {
              title = fillType.title,
              name = fillType.name,
              fillLevel = 0,
              unit = fillUnit.unitText,
              precision = 0
            }

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
      local formattedNumber
      local formattedFillLevel, unit = self.additionalUnits:formatFillLevel(info.fillLevel, info.name)

      if info.precision > 0 then
        local rounded = MathUtil.round(formattedFillLevel, info.precision)

        formattedNumber = string.format("%d%s%0"..info.precision.."d", math.floor(rounded), self.i18n.decimalSeparator, (rounded - math.floor(rounded)) * 10 ^ info.precision)
      else
        formattedNumber = string.format("%d", MathUtil.round(formattedFillLevel))
      end

      formattedNumber = formattedNumber .. " " .. (unit.shortName or info.unit or self.i18n:getVolumeUnit())

      box:addLine(info.title, formattedNumber)
    end

    superFunc(fillUnit, box)
  end)
end