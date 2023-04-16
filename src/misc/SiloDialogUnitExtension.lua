-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.0, 13|04|2023
-- @filename: SiloDialogUnitExtension.lua

SiloDialogUnitExtension = {}

local SiloDialogUnitExtension_mt = Class(SiloDialogUnitExtension)

---Creating SiloDialogUnitExtension instance
---@param additionalUnits table additionalUnits object
---@param fillTypeManager table fillTypeManager object
---@return table instance instance of object
function SiloDialogUnitExtension.new(customMt, additionalUnits, fillTypeManager)
	local self = setmetatable({}, customMt or SiloDialogUnitExtension_mt)

	self.additionalUnits = additionalUnits
	self.fillTypeManager = fillTypeManager

	return self
end

---Initializing SiloDialogUnitExtension
function SiloDialogUnitExtension:initialize()
	self.additionalUnits:overwriteGameFunction(SiloDialog, 'setFillLevels', function (superFunc, dialog, fillLevels, hasInfiniteCapacity)
		superFunc(dialog, fillLevels, hasInfiniteCapacity)

		local fillTypesTable = {}

		for fillTypeIndex, _ in pairs(fillLevels) do
			local fillType = self.fillTypeManager:getFillTypeByIndex(fillTypeIndex)
			local level = Utils.getNoNil(fillLevels[fillTypeIndex], 0)
			local name = nil

			if hasInfiniteCapacity then
				name = string.format('%s', fillType.title)
			else
				local fillText, unit = self.additionalUnits:formatFillLevel(level, fillType.name, 0)

				name = string.format('%s %s', fillType.title, fillText .. ' ' .. unit)
			end

			table.insert(fillTypesTable, name)
		end

		dialog.fillTypesElement:setTexts(fillTypesTable)
	end)
end