-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.0, 15|04|2023
-- @filename: PlaceableHusbandryFoodUnitExtension.lua

PlaceableHusbandryFoodUnitExtension = {}

function PlaceableHusbandryFoodUnitExtension:getFoodInfos(_, superFunc)
  local foodInfos = superFunc(self)
  local spec = self.spec_husbandryFood
  local animalFood = g_currentMission.animalFoodSystem:getAnimalFood(spec.animalTypeIndex)

  if animalFood ~= nil then
    for _, foodGroup in pairs(animalFood.groups) do
      local title = foodGroup.title
      local fillLevel = 0
      local fillType = FillType.UNKNOWN
      local capacity = spec.capacity

      for _, fillTypeIndex in pairs(foodGroup.fillTypes) do
        if spec.fillLevels[fillTypeIndex] ~= nil then
          fillLevel = fillLevel + spec.fillLevels[fillTypeIndex]
          fillType = fillTypeIndex
        end
      end

      local info = {
        title = string.format("%s (%d%%)", title, MathUtil.round(foodGroup.productionWeight * 100)),
        value = fillLevel,
        capacity = capacity,
        fillType = fillType,
        ratio = 0
      }

      if capacity > 0 then
        info.ratio = fillLevel / capacity
      end

      table.insert(foodInfos, info)
    end
  end

  return foodInfos
end

function PlaceableHusbandryFoodUnitExtension:overwriteGameFunctions()
  PlaceableHusbandryFood.getFoodInfos = Utils.overwrittenFunction(PlaceableHusbandryFood.getFoodInfos, PlaceableHusbandryFoodUnitExtension.getFoodInfos)
end