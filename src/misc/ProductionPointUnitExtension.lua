-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.0, 13|04|2023
-- @filename: ProductionPointUnitExtension.lua

ProductionPointUnitExtension = {}

local ProductionPointUnitExtension_mt = Class(ProductionPointUnitExtension)

---Creating ProductionPointUnitExtension instance
---@param additionalUnits table additionalUnits object
---@param l10n table l10n object
---@param fillTypeManager table fillTypeManager object
---@return table instance instance of object
function ProductionPointUnitExtension.new(customMt, additionalUnits, l10n, fillTypeManager)
	local self = setmetatable({}, customMt or ProductionPointUnitExtension_mt)

	self.additionalUnits = additionalUnits
	self.l10n = l10n
	self.fillTypeManager = fillTypeManager

	return self
end

---Initializing ProductionPointUnitExtension
function ProductionPointUnitExtension:initialize()
	self.additionalUnits:overwriteGameFunction(ProductionPoint, 'updateInfo', function (_, production, superFunc, infoTable)
		superFunc(production, infoTable)

		local owningFarm = g_farmManager:getFarmById(production:getOwnerFarmId())

		table.insert(infoTable, {
			title = self.l10n:getText('fieldInfo_ownedBy'),
			text = owningFarm.name
		})

		if #production.activeProductions > 0 then
			table.insert(infoTable, production.infoTables.activeProds)

			local activeProduction = nil

			for i = 1, #production.activeProductions do
				activeProduction = production.activeProductions[i]

				local productionName = activeProduction.name or self.fillTypeManager:getFillTypeTitleByIndex(activeProduction.primaryProductFillType)

				table.insert(infoTable, {
					title = productionName,
					text = self.l10n:getText(ProductionPoint.PROD_STATUS_TO_L10N[production:getProductionStatus(activeProduction.id)])
				})
			end
		else
			table.insert(infoTable, production.infoTables.noActiveProd)
		end

		local fillType, fillLevel = nil
		local fillText, unit = nil
		local fillTypesDisplayed = false

		table.insert(infoTable, production.infoTables.storage)

		for i = 1, #production.inputFillTypeIdsArray do
			fillType = production.inputFillTypeIdsArray[i]
			fillLevel = production:getFillLevel(fillType)

			if fillLevel > 1 then
				fillTypesDisplayed = true

				fillText, unit = self.additionalUnits:formatFillLevel(fillLevel, self.fillTypeManager:getFillTypeNameByIndex(fillType), 0)

				table.insert(infoTable, {
					title = self.fillTypeManager:getFillTypeTitleByIndex(fillType),
					text = fillText .. ' ' .. unit
				})
			end
		end

		for i = 1, #production.outputFillTypeIdsArray do
			fillType = production.outputFillTypeIdsArray[i]
			fillLevel = production:getFillLevel(fillType)

			if fillLevel > 1 then
				fillTypesDisplayed = true

				fillText, unit = self.additionalUnits:formatFillLevel(fillLevel, self.fillTypeManager:getFillTypeNameByIndex(fillType), 0)

				table.insert(infoTable, {
					title = self.fillTypeManager:getFillTypeTitleByIndex(fillType),
					text = fillText .. ' ' .. unit
				})
			end
		end

		if not fillTypesDisplayed then
			table.insert(infoTable, production.infoTables.storageEmpty)
		end

		if production.palletLimitReached then
			table.insert(infoTable, production.infoTables.palletLimitReached)
		end
	end)
end