-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.0, 13|04|2023
-- @filename: BaleUnitExtension.lua

BaleUnitExtension = {}

local BaleUnitExtension_mt = Class(BaleUnitExtension)

---Creating BaleUnitExtension instance
---@param additionalUnits table additionalUnits object
---@param l10n table l10n object
---@param fillTypeManager table fillTypeManager object
---@return table instance instance of object
function BaleUnitExtension.new(customMt, additionalUnits, l10n, fillTypeManager)
	local self = setmetatable({}, customMt or BaleUnitExtension_mt)

	self.additionalUnits = additionalUnits
	self.l10n = l10n
	self.fillTypeManager = fillTypeManager

	return self
end

---Initializing BaleUnitExtension
function BaleUnitExtension:initialize()
	self.additionalUnits:overwriteGameFunction(Bale, 'showInfo', function (superFunc, bale, box)
		local fillType = bale:getFillType()
		local fillLevel = bale:getFillLevel()
		local fillTypeDesc = self.fillTypeManager:getFillTypeByIndex(fillType)
		local fillText, unit = self.additionalUnits:formatFillLevel(fillLevel, fillTypeDesc.name, 0, false)

		box:addLine(fillTypeDesc.title, string.format('%s %s', fillText, unit or ''))

		if bale:getIsFermenting() then
			box:addLine(self.l10n:getText('info_fermenting'), string.format('%d%%', bale:getFermentingPercentage() * 100))
		end

		box:addLine(self.l10n:getText('infohud_mass'), self.l10n:formatMass(bale:getMass()))
	end)
end