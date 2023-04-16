-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.0, 13|04|2023
-- @filename: FillLevelsDisplayUnitExtension.lua

FillLevelsDisplayUnitExtension = {}

local FillLevelsDisplayUnitExtension_mt = Class(FillLevelsDisplayUnitExtension)

---Creating FillLevelsDisplayUnitExtension instance
---@param additionalUnits table additionalUnits object
---@param fillTypeManager table fillTypeManager object
---@return table instance instance of object
function FillLevelsDisplayUnitExtension.new(customMt, additionalUnits, fillTypeManager)
	local self = setmetatable({}, customMt or FillLevelsDisplayUnitExtension_mt)

	self.additionalUnits = additionalUnits
	self.fillTypeManager = fillTypeManager

	return self
end

---Initializing FillLevelsDisplayUnitExtension
function FillLevelsDisplayUnitExtension:initialize()
	self.additionalUnits:overwriteGameFunction(FillLevelsDisplay, 'updateFillLevelFrames', function (superFunc, display)
		superFunc(display)

		local bufferIndex = 1

		for i = 1, #display.fillLevelBuffer do
			local fillLevelInformation = display.fillLevelBuffer[i]

			if fillLevelInformation.capacity > 0 or fillLevelInformation.fillLevel > 0 then
				local value = 0

				if fillLevelInformation.capacity > 0 then
					value = fillLevelInformation.fillLevel / fillLevelInformation.capacity
				end

				local fillTypeDesc = self.fillTypeManager:getFillTypeByIndex(fillLevelInformation.fillType)
				local fillLevel, unit = self.additionalUnits:formatFillLevel(fillLevelInformation.fillLevel, fillTypeDesc.name, fillLevelInformation.precision, false)
				local fillText = string.format('%s%s (%d%%)', fillLevel, unit or '', math.floor(100 * value))

				display.fillLevelTextBuffer[bufferIndex] = fillText

				bufferIndex = bufferIndex + 1
			end
		end
	end)
end