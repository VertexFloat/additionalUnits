-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.0, 15|04|2023
-- @filename: PlaceableHusbandryFoodUnitExtension.lua

PlaceableHusbandryFoodUnitExtension = {}

local PlaceableHusbandryFoodUnitExtension_mt = Class(PlaceableHusbandryFoodUnitExtension)

---Creating PlaceableHusbandryFoodUnitExtension instance
---@param additionalUnits table additionalUnits object
---@return table instance instance of object
function PlaceableHusbandryFoodUnitExtension.new(customMt, additionalUnits)
  local self = setmetatable({}, customMt or PlaceableHusbandryFoodUnitExtension_mt)

  self.additionalUnits = additionalUnits

  return self
end

---Initializing PlaceableHusbandryFoodUnitExtension
function PlaceableHusbandryFoodUnitExtension:initialize()
  self.additionalUnits:overwriteGameFunction(PlaceableHusbandryFood, "getFoodInfos", function (_, husbandry, superFunc)
    local foodInfos = superFunc(husbandry)
    local spec = husbandry.spec_husbandryFood

    local animalFood = g_currentMission.animalFoodSystem:getAnimalFood(spec.animalTypeIndex)

    if animalFood ~= nil then
      for _, foodGroup in pairs(animalFood.groups) do
        local title = foodGroup.title
        local fillLevel = 0
        local capacity = spec.capacity

        for _, fillTypeIndex in pairs(foodGroup.fillTypes) do
          if spec.fillLevels[fillTypeIndex] ~= nil then
            fillLevel = fillLevel + spec.fillLevels[fillTypeIndex]
          end
        end

        local info = {}

        info.title = string.format("%s (%d%%)", title, MathUtil.round(foodGroup.productionWeight * 100))
        info.value = fillLevel
        info.capacity = capacity
        info.ratio = 0

        if #foodGroup.fillTypes == 1 then
          info.fillType = foodGroup.fillTypes[1]
        end

        if capacity > 0 then
          info.ratio = fillLevel / capacity
        end

        table.insert(foodInfos, info)
      end
    end

    return foodInfos
  end)
end