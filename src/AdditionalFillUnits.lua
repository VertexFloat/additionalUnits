-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.0, 13/01/2023
-- @filename: AdditionalFillUnits.lua

AdditionalFillUnits = {
	MOD_SETTINGS_DIRECTORY = g_modSettingsDirectory,
	CONFIG_PATH = g_currentModDirectory .. 'src/resources/volumeUnits.xml'
}

function AdditionalFillUnits:loadMap(filename)
	local configFilename = self:loadConfigFile()
	local volumeUnits, texts = self:loadVolumeUnitsFromXMLFile(configFilename)

	self.volumeUnits = volumeUnits
	self.currentUnit, self.liquidConvert = self:loadVolumeUnitStateFromXMLFile()

	self.volumeUnitOptionElement = self:createGeneralSettingElement(g_i18n:getText('setting_volumeUnit'), 'multiVolumeUnit', g_i18n:getText('toolTip_volumeUnit'), self.onClickVolumeUnit, texts, g_currentMission.inGameMenu.pageSettingsGeneral.multiMoneyUnit)
	self.volumeUnitOptionElement:setState(self.currentUnit)

	self.liquidVolumeUnitCheckboxElement = self:createGeneralSettingElement(g_i18n:getText('setting_liquidUnit'), 'checkLiquidUnitConvert', g_i18n:getText('toolTip_liquidUnit'), self.onClickLiquidUnit, nil, self.volumeUnitOptionElement)
	self.liquidVolumeUnitCheckboxElement:setIsChecked(self.liquidConvert)
	self.liquidVolumeUnitCheckboxElement:setDisabled(self.currentUnit == 1)

	self:overwriteGameFunctions()
end

function AdditionalFillUnits:loadConfigFile()
	local configPath = AdditionalFillUnits.MOD_SETTINGS_DIRECTORY .. 'volumeUnits.xml'

	copyFile(AdditionalFillUnits.CONFIG_PATH, configPath, false)

	if not fileExists(configPath) then
		configPath = AdditionalFillUnits.CONFIG_PATH
	end

	return configPath
end

function AdditionalFillUnits:loadVolumeUnitsFromXMLFile(xmlFilename)
	local xmlFile = XMLFile.loadIfExists('volumeUnitsXML', xmlFilename, 'volumeUnits')
	local units, texts = {}, {}

	if  xmlFile == nil then
		Logging.error('Cannot load volume units config file !')

		return units, texts
	end

	xmlFile:iterate('volumeUnits.volumeUnit', function (_, unitKey)
		local unit = {
			name = g_i18n:getText(xmlFile:getString(unitKey .. '#name', '')),
			shortName = g_i18n:getText(xmlFile:getString(unitKey .. '#shortName', '')),
			factor = xmlFile:getFloat(unitKey .. '#factor', 0),
		}
		local overwrittenPrecision = xmlFile:getInt(unitKey .. '#overwrittenPrecision')

		if overwrittenPrecision ~= nil then
			unit.overwrittenPrecision = overwrittenPrecision
		end

		xmlFile:iterate(unitKey .. '.factors.factor', function (_, factorKey)
			local factor = {
				fillTypeName = xmlFile:getString(factorKey .. '#fillTypeName', ''),
				value = xmlFile:getFloat(factorKey .. '#value', 1)
			}

			if unit.factors == nil then
				unit.factors = {}
			end

			if factor.value ~= 0 and factor.value ~= nil then
				table.insert(unit.factors, factor)
			else
				Logging.error(string.format('Volume unit factor (%s) has wrong value (Must be > 0) !', factor.fillTypeName))
			end
		end)

		table.insert(texts, unit.name:sub(1, 1):upper()..unit.name:sub(2))
		table.insert(units, unit)
	end)

	xmlFile:delete()

	return units, texts
end

function AdditionalFillUnits:loadVolumeUnitStateFromXMLFile()
	local currentUnit, liquidConvert = 1, false

	if g_savegameXML ~= nil then
		local savedUnit = Utils.getNoNil(getXMLInt(g_savegameXML, 'gameSettings.units.volume'), currentUnit)

		if savedUnit <= #self.volumeUnits then
			currentUnit = savedUnit
		end

		liquidConvert = Utils.getNoNil(getXMLBool(g_savegameXML, 'gameSettings.units.liquid'), liquidConvert)
	end

	return currentUnit, liquidConvert
end

function AdditionalFillUnits:saveVolumeUnitStateToXMLFile()
	if g_savegameXML ~= nil then
		setXMLInt(g_savegameXML, 'gameSettings.units.volume', self.currentUnit)
		setXMLBool(g_savegameXML, 'gameSettings.units.liquid', self.liquidConvert)
	end

	g_gameSettings:saveToXMLFile(g_savegameXML)
end

function AdditionalFillUnits:createGeneralSettingElement(title, name, description, callback, optionTexts, prependElement)
	local parentElement = g_currentMission.inGameMenu.pageSettingsGeneral

	if name == nil or name == '' then
		Logging.error(string.format("You didn't define element name for (%s) setting !", title))

		return
	end

	if optionTexts ~= nil then
		parentElement[name] = parentElement.multiMoneyUnit:clone(parentElement)
		parentElement[name]:setTexts(optionTexts)
	else
		parentElement[name] = parentElement.checkUseEasyArmControl:clone(parentElement)
	end

	if prependElement == nil then
		Logging.error(string.format('Defined prependElement for (%s) setting does not exist, using default instead !', title))

		prependElement = parentElement.checkAutoHelp
	end

	local element = parentElement[name]

	element.elements[4]:setText(title)
	element.elements[6]:setText(description)

	function element.onClickCallback(_, ...)
		callback(...)
	end

	local index = #prependElement.parent.elements + 1

	if element.parent ~= nil then
		element.parent:removeElement(element)
	end

	for i = 1, #prependElement.parent.elements do
		if prependElement.parent.elements[i] == prependElement then
			index = i + 1

			break
		end
	end

	table.insert(prependElement.parent.elements, index, element)

	element.parent = prependElement.parent

	return element
end

function AdditionalFillUnits.onClickVolumeUnit(state, optionElement)
	AdditionalFillUnits:setVolumeUnit(state)
end

function AdditionalFillUnits:setVolumeUnit(state)
	self.currentUnit = state

	self.liquidVolumeUnitCheckboxElement:setDisabled(state == 1)
end

function AdditionalFillUnits.onClickLiquidUnit(state, checkboxElement)
	AdditionalFillUnits:setLiquidUnit(state == CheckedOptionElement.STATE_CHECKED)
end

function AdditionalFillUnits:setLiquidUnit(state)
	self.liquidConvert = state
end

function AdditionalFillUnits:formatVolume(liters, fillTypeName, precision, useLongName, isSeperate, isFormatted, customUnit)
	local unit, liquidState = self:getCurrentVolumeUnit(), self:getCurrentLiquidUnitState()
	local unitName = customUnit ~= g_i18n:convertText('$l10n_unit_literShort') and customUnit or (useLongName == true and unit.name or unit.shortName)
	local format = isSeperate == true and '%s %s' or '%s%s'
	local formattedVolume = tonumber(liters)
	local precision = precision or 0

	if unit ~= nil and fillTypeName ~= nil then
		if (g_fillTypeManager:getIsFillTypeInCategory(g_fillTypeManager:getFillTypeIndexByName(fillTypeName), 'LIQUID') or g_fillTypeManager:getIsFillTypeInCategory(g_fillTypeManager:getFillTypeIndexByName(fillTypeName), 'SPRAYER') or g_fillTypeManager:getIsFillTypeInCategory(g_fillTypeManager:getFillTypeIndexByName(fillTypeName), 'SLURRYTANK')) then
			if liquidState == false then
				unitName = customUnit or g_i18n:getVolumeUnit(useLongName)

				if isFormatted then
					formattedVolume = string.format(format, g_i18n:formatNumber(formattedVolume, precision), unitName)
				else
					formattedVolume = string.format(format, MathUtil.round(formattedVolume), unitName)
				end

				return formattedVolume
			end
		end

		if unit.factors ~= nil then
			for _, factor in pairs(unit.factors) do
				if factor.fillTypeName:upper() == fillTypeName:upper() then
					formattedVolume = formattedVolume * factor.value

					if unit.factor ~= 0 then
						formattedVolume = formattedVolume * unit.factor
					end
				end
			end
		end

		if unit.overwrittenPrecision ~= nil then
			precision = unit.overwrittenPrecision
		end
	end

	if isFormatted then
		formattedVolume = string.format(format, g_i18n:formatNumber(formattedVolume, precision), unitName)
	else
		formattedVolume = string.format(format, MathUtil.round(formattedVolume, precision), unitName)
	end

	return formattedVolume
end

function AdditionalFillUnits:getCurrentVolumeUnit()
	return self.volumeUnits[self.currentUnit]
end

function AdditionalFillUnits:getCurrentLiquidUnitState()
	if self.liquidVolumeUnitCheckboxElement:getIsDisabled() == false then
		return self.liquidConvert
	end

	return false
end

function AdditionalFillUnits:getFillTypeNameByTitle(name)
	local fillTypes = g_fillTypeManager:getFillTypes()

	for _, fillType in pairs(fillTypes) do
		if fillType.title == name then
			return fillType.name
		end
	end

	return ''
end
-- Unfortunately I haven't found a better way to change the default unit than overriding the default functions.
function AdditionalFillUnits:overwriteGameFunctions()
	AdditionalFillUnits:overwriteGameFunction(FillLevelsDisplay, 'updateFillLevelFrames', function (superFunc, self)
		local _, yOffset = self:getPosition()
		local isFirst = true

		for i = 1, #self.fillLevelBuffer do
			local fillLevelInformation = self.fillLevelBuffer[i]

			if fillLevelInformation.capacity > 0 or fillLevelInformation.fillLevel > 0 then
				local value = 0

				if fillLevelInformation.capacity > 0 then
					value = fillLevelInformation.fillLevel / fillLevelInformation.capacity
				end

				local frame = self.fillTypeFrames[fillLevelInformation.fillType]

				frame:setVisible(true)

				local fillBar = self.fillTypeLevelBars[fillLevelInformation.fillType]

				fillBar:setValue(value)

				local baseX = self:getPosition()

				if isFirst then
					baseX = baseX + self.firstFillTypeOffset
				end

				frame:setPosition(baseX, yOffset)

				self.weightFrames[fillLevelInformation.fillType]:setVisible(fillLevelInformation.maxReached)

				local precision = fillLevelInformation.precision or 0
				local fillTypeTitle, fillTypeName = nil

				if fillLevelInformation.fillType ~= FillType.UNKNOWN then
					local fillTypeDesc = g_fillTypeManager:getFillTypeByIndex(fillLevelInformation.fillType)

					fillTypeTitle = fillTypeDesc.title
					fillTypeName = fillTypeDesc.name
				end

				local fillText = string.format('%s (%d%%)', AdditionalFillUnits:formatVolume(fillLevelInformation.fillLevel, fillTypeName, precision, false, false, false), math.floor(100 * value))

				self.fillLevelTextBuffer[#self.fillLevelTextBuffer + 1] = fillText

				if fillTypeTitle ~= nil then
					self.fillTypeTextBuffer[#self.fillLevelTextBuffer] = fillTypeTitle
				end

				yOffset = yOffset + self.frameHeight + self.frameOffsetY
				isFirst = false
			end
		end
	end)

	AdditionalFillUnits:overwriteGameFunction(Bale, 'showInfo', function (superFunc, self, box)
		local fillType = self:getFillType()
		local fillLevel = self:getFillLevel()
		local fillTypeDesc = g_fillTypeManager:getFillTypeByIndex(fillType)

		box:addLine(fillTypeDesc.title, AdditionalFillUnits:formatVolume(fillLevel, fillTypeDesc.name, 0, false, true, true))

		if self:getIsFermenting() then
			box:addLine(g_i18n:getText('info_fermenting'), string.format('%d%%', self:getFermentingPercentage() * 100))
		end

		if AdditionalFillUnits.currentUnit == 1 then
			box:addLine(g_i18n:getText('infohud_mass'), g_i18n:formatMass(self:getMass()))
		end
	end)

	AdditionalFillUnits:overwriteGameFunction(SiloDialog, 'setFillLevels', function (superFunc, self, fillLevels, hasInfiniteVolume)
		self.fillLevels = fillLevels
		self.fillTypeMapping = {}

		local fillTypesTable = {}
		local selectedId = 1
		local numFillLevels = 1

		for fillTypeIndex, _ in pairs(fillLevels) do
			local fillType = g_fillTypeManager:getFillTypeByIndex(fillTypeIndex)
			local level = Utils.getNoNil(fillLevels[fillTypeIndex], 0)
			local name = nil

			if hasInfiniteVolume then
				name = string.format('%s', fillType.title)
			else
				name = string.format('%s %s', fillType.title, AdditionalFillUnits:formatVolume(level, fillType.name, 0, false, true, true))
			end

			table.insert(fillTypesTable, name)
			table.insert(self.fillTypeMapping, fillTypeIndex)

			if fillTypeIndex == self.lastSelectedFillType then
				selectedId = numFillLevels
			end

			numFillLevels = numFillLevels + 1
		end

		self.fillTypesElement:setTexts(fillTypesTable)
		self.fillTypesElement:setState(selectedId, true)
	end)

	AdditionalFillUnits:overwriteGameFunction(InGameMenuPricesFrame, 'populateCellForItemInSection', function (superFunc, self, list, section, index, cell)
		if list == self.productList then
			local fillTypeDesc = self.fillTypes[index]

			cell:getAttribute('icon'):setImageFilename(fillTypeDesc.hudOverlayFilename)
			cell:getAttribute('title'):setText(fillTypeDesc.title)

			local usedStorages = {}
			local localLiters = self:getStorageFillLevel(fillTypeDesc, true, usedStorages)
			local foreignLiters = self:getStorageFillLevel(fillTypeDesc, false, usedStorages)

			if localLiters < 0 and foreignLiters < 0 then
				cell:getAttribute('storage'):setText('-')
			else
				cell:getAttribute('storage'):setText(AdditionalFillUnits:formatVolume(math.max(localLiters, 0) + math.max(foreignLiters, 0), fillTypeDesc.name, 0, false, true, true))
			end
		else
			local station = self.currentStations[index]
			local fillTypeDesc = self.fillTypes[self.productList.selectedIndex]
			local hasHotspot = station.owningPlaceable:getHotspot(1) ~= nil

			cell:getAttribute('hotspot'):setVisible(hasHotspot)

			if hasHotspot then
				local isTagActive = g_currentMission.currentMapTargetHotspot ~= nil and station.owningPlaceable:getHotspot(1) == g_currentMission.currentMapTargetHotspot

				cell:getAttribute('hotspot'):applyProfile(isTagActive and 'ingameMenuPriceItemHotspotActive' or 'ingameMenuPriceItemHotspot')
			end

			cell:getAttribute('title'):setText(station.uiName)

			local price = tostring(station:getEffectiveFillTypePrice(fillTypeDesc.index))

			cell:getAttribute('price'):setVisible(station.uiIsSelling)
			cell:getAttribute('buyPrice'):setVisible(not station.uiIsSelling)

			if station.uiIsSelling then
				cell:getAttribute('price'):setValue(price * 1000)

				local priceTrend = station:getCurrentPricingTrend(fillTypeDesc.index)
				local profile = 'ingameMenuPriceArrow'

				if priceTrend ~= nil then
					if Utils.isBitSet(priceTrend, SellingStation.PRICE_GREAT_DEMAND) then
						profile = 'ingameMenuPriceArrowGreatDemand'
					elseif Utils.isBitSet(priceTrend, SellingStation.PRICE_CLIMBING) then
						profile = 'ingameMenuPriceArrowClimbing'
					elseif Utils.isBitSet(priceTrend, SellingStation.PRICE_FALLING) then
						profile = 'ingameMenuPriceArrowFalling'
					end
				end

				cell:getAttribute('priceTrend'):applyProfile(profile)
			else
				cell:getAttribute('buyPrice'):setValue(price * 1000)
				cell:getAttribute('priceTrend'):applyProfile('ingameMenuPriceArrow')
			end
		end
	end)

	AdditionalFillUnits:overwriteGameFunction(InGameMenuAnimalsFrame, 'updateConditionDisplay', function (superFunc, self, husbandry)
		local infos = husbandry:getConditionInfos()

		for index, row in ipairs(self.conditionRow) do
			local info = infos[index]

			row:setVisible(info ~= nil)

			if info ~= nil then
				local valueText = info.valueText or AdditionalFillUnits:formatVolume(info.value, AdditionalFillUnits:getFillTypeNameByTitle(info.title), 0, false, true, true, info.customUnitText)

				self.conditionLabel[index]:setText(info.title)
				self.conditionValue[index]:setText(valueText)
				self:setStatusBarValue(self.conditionStatusBar[index], info.ratio, info.invertedBar)
			end
		end
	end)

	AdditionalFillUnits:overwriteGameFunction(InGameMenuAnimalsFrame, 'updateFoodDisplay', function (superFunc, self, husbandry)
		local infos = husbandry:getFoodInfos()
		local totalCapacity = 0
		local totalValue = 0

		for index, row in ipairs(self.foodRow) do
			local info = infos[index]

			row:setVisible(info ~= nil)

			if info ~= nil then
				local valueText = AdditionalFillUnits:formatVolume(info.value, AdditionalFillUnits:getFillTypeNameByTitle((string.match(info.title, '[%a%s]+'):match('^.*%S'))), 0, false, true, true)

				totalCapacity = info.capacity
				totalValue = totalValue + info.value

				self.foodLabel[index]:setText(info.title)
				self.foodValue[index]:setText(valueText)
				self:setStatusBarValue(self.foodStatusBar[index], info.ratio, info.invertedBar)
			end
		end

		local totalValueText = self.l10n:formatVolume(totalValue, 0)
		local totalRatio = 0

		if totalCapacity > 0 then
			totalRatio = totalValue / totalCapacity
		end

		self.foodRowTotalValue:setText(totalValueText)
		self:setStatusBarValue(self.foodRowTotalStatusBar, totalRatio, false)
		self.foodHeader:setText(string.format('%s (%s)', g_i18n:getText('ui_silos_totalCapacity'), g_i18n:getText('animals_foodMixEffectiveness')))
	end)

	AdditionalFillUnits:overwriteGameFunction(InGameMenuProductionFrame, 'populateCellForItemInSection', function (superFunc, self, list, section, index, cell)
		if list == self.productionList then
			local productionPoint = self:getProductionPoints()[section]
			local production = productionPoint.productions[index]
			local fillTypeDesc = g_fillTypeManager:getFillTypeByIndex(production.primaryProductFillType)

			if fillTypeDesc ~= nil then
				cell:getAttribute('icon'):setImageFilename(fillTypeDesc.hudOverlayFilename)
			end

			cell:getAttribute('icon'):setVisible(fillTypeDesc ~= nil)
			cell:getAttribute('name'):setText(production.name or fillTypeDesc.title)

			local status = production.status
			local activityElement = cell:getAttribute('activity')

			if status == ProductionPoint.PROD_STATUS.RUNNING then
				activityElement:applyProfile('ingameMenuProductionProductionActivityActive')
			elseif status == ProductionPoint.PROD_STATUS.MISSING_INPUTS or status == ProductionPoint.PROD_STATUS.NO_OUTPUT_SPACE then
				activityElement:applyProfile('ingameMenuProductionProductionActivityIssue')
			else
				activityElement:applyProfile('ingameMenuProductionProductionActivity')
			end
		else
			local _, productionPoint = self:getSelectedProduction()
			local fillType, isInput = nil

			if section == 1 then
				fillType = self.selectedProductionPoint.inputFillTypeIdsArray[index]
				isInput = true
			else
				fillType = self.selectedProductionPoint.outputFillTypeIdsArray[index]
				isInput = false
			end

			if fillType ~= FillType.UNKNOWN then
				local fillLevel = self.selectedProductionPoint:getFillLevel(fillType)
				local capacity = self.selectedProductionPoint:getCapacity(fillType)
				local fillTypeDesc = g_fillTypeManager:getFillTypeByIndex(fillType)

				cell:getAttribute('icon'):setImageFilename(fillTypeDesc.hudOverlayFilename)
				cell:getAttribute('fillType'):setText(fillTypeDesc.title)
				cell:getAttribute('fillLevel'):setText(AdditionalFillUnits:formatVolume(fillLevel, fillTypeDesc.name, 0, false, true, true))

				if not isInput then
					local outputMode = productionPoint:getOutputDistributionMode(fillType)
					local outputModeText = self.i18n:getText('ui_production_output_storing')

					if outputMode == ProductionPoint.OUTPUT_MODE.DIRECT_SELL then
						outputModeText = self.i18n:getText('ui_production_output_selling')
					elseif outputMode == ProductionPoint.OUTPUT_MODE.AUTO_DELIVER then
						outputModeText = self.i18n:getText('ui_production_output_distributing')
					end

					cell:getAttribute('outputMode'):setText(outputModeText)
				end

				self:setStatusBarValue(cell:getAttribute('bar'), fillLevel / capacity, isInput)
			end
		end
	end)

	AdditionalFillUnits:overwriteGameFunction(ProductionPoint, 'updateInfo', function (_, self, superFunc, infoTable)
		superFunc(self, infoTable)

		local owningFarm = g_farmManager:getFarmById(self:getOwnerFarmId())

		table.insert(infoTable, {
			title = g_i18n:getText('fieldInfo_ownedBy'),
			text = owningFarm.name
		})

		if #self.activeProductions > 0 then
			table.insert(infoTable, self.infoTables.activeProds)

			local activeProduction = nil

			for i = 1, #self.activeProductions do
				activeProduction = self.activeProductions[i]
				local productionName = activeProduction.name or g_fillTypeManager:getFillTypeTitleByIndex(activeProduction.primaryProductFillType)

				table.insert(infoTable, {
					title = productionName,
					text = g_i18n:getText(ProductionPoint.PROD_STATUS_TO_L10N[self:getProductionStatus(activeProduction.id)])
				})
			end
		else
			table.insert(infoTable, self.infoTables.noActiveProd)
		end

		local fillType, fillLevel = nil
		local fillTypesDisplayed = false

		table.insert(infoTable, self.infoTables.storage)

		for i = 1, #self.inputFillTypeIdsArray do
			fillType = self.inputFillTypeIdsArray[i]
			fillLevel = self:getFillLevel(fillType)

			if fillLevel > 1 then
				fillTypesDisplayed = true

				table.insert(infoTable, {
					title = g_fillTypeManager:getFillTypeTitleByIndex(fillType),
					text = AdditionalFillUnits:formatVolume(fillLevel, g_fillTypeManager:getFillTypeNameByIndex(fillType), 0, false, true, true)
				})
			end
		end

		for i = 1, #self.outputFillTypeIdsArray do
			fillType = self.outputFillTypeIdsArray[i]
			fillLevel = self:getFillLevel(fillType)

			if fillLevel > 1 then
				fillTypesDisplayed = true

				table.insert(infoTable, {
					title = g_fillTypeManager:getFillTypeTitleByIndex(fillType),
					text = AdditionalFillUnits:formatVolume(fillLevel, g_fillTypeManager:getFillTypeNameByIndex(fillType), 0, false, true, true)
				})
			end
		end

		if not fillTypesDisplayed then
			table.insert(infoTable, self.infoTables.storageEmpty)
		end

		if self.palletLimitReached then
			table.insert(infoTable, self.infoTables.palletLimitReached)
		end
	end)
end

function AdditionalFillUnits:overwriteGameFunction(object, funcName, newFunc)
	if object == nil then
		return
	end

	local oldFunc = object[funcName]

	if oldFunc ~= nil then
		object[funcName] = function (...)
			return newFunc(oldFunc, ...)
		end
	end
end

AdditionalFillUnits:overwriteGameFunction(FillUnit, 'showInfo', function (_, self, superFunc, box)
	local spec = self.spec_fillUnit

	if spec.isInfoDirty then
		spec.fillUnitInfos = {}

		local fillTypeToInfo = {}

		for _, fillUnit in ipairs(spec.fillUnits) do
			if fillUnit.showOnInfoHud and fillUnit.fillLevel > 0 then
				local info = fillTypeToInfo[fillUnit.fillType]

				if info == nil then
					local fillType = g_fillTypeManager:getFillTypeByIndex(fillUnit.fillType)

					info = {title = fillType.title, name = fillType.name, fillLevel = 0, unit = fillUnit.unitText, precision = 0}

					table.insert(spec.fillUnitInfos, info)

					fillTypeToInfo[fillUnit.fillType] = info
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
		local formattedNumber = nil

		formattedNumber = string.format('%s', AdditionalFillUnits:formatVolume(info.fillLevel, info.name, info.precision, false, true, true, info.unit))

		box:addLine(info.title, formattedNumber)
	end

	superFunc(self, box)
end)

AdditionalFillUnits:overwriteGameFunction(PlaceableSilo, 'updateInfo', function (_, self, superFunc, infoTable)
	superFunc(self, infoTable)

	local spec = self.spec_silo
	local farmId = g_currentMission:getFarmId()

	for fillType, fillLevel in pairs(spec.loadingStation:getAllFillLevels(farmId)) do
		spec.fillTypesAndLevelsAuxiliary[fillType] = (spec.fillTypesAndLevelsAuxiliary[fillType] or 0) + fillLevel
	end

	table.clear(spec.infoTriggerFillTypesAndLevels)

	for fillType, fillLevel in pairs(spec.fillTypesAndLevelsAuxiliary) do
		if fillLevel > 0.1 then
			spec.fillTypeToFillTypeStorageTable[fillType] = spec.fillTypeToFillTypeStorageTable[fillType] or {
				fillType = fillType,
				fillLevel = fillLevel
			}
			spec.fillTypeToFillTypeStorageTable[fillType].fillLevel = fillLevel

			table.insert(spec.infoTriggerFillTypesAndLevels, spec.fillTypeToFillTypeStorageTable[fillType])
		end
	end

	table.clear(spec.fillTypesAndLevelsAuxiliary)
	table.sort(spec.infoTriggerFillTypesAndLevels, function (a, b)
		return b.fillLevel < a.fillLevel
	end)

	local numEntries = math.min(#spec.infoTriggerFillTypesAndLevels, PlaceableSilo.INFO_TRIGGER_NUM_DISPLAYED_FILLTYPES)

	if numEntries > 0 then
		for i = 1, numEntries do
			local fillTypeAndLevel = spec.infoTriggerFillTypesAndLevels[i]

			table.insert(infoTable, {
				title = g_fillTypeManager:getFillTypeTitleByIndex(fillTypeAndLevel.fillType),
				text = AdditionalFillUnits:formatVolume(fillTypeAndLevel.fillLevel, g_fillTypeManager:getFillTypeNameByIndex(fillTypeAndLevel.fillType), 0, false, true, true)
			})
		end
	else
		table.insert(infoTable, {
			text = '',
			title = g_i18n:getText('infohud_siloEmpty')
		})
	end
end)

AdditionalFillUnits:overwriteGameFunction(PlaceableSilo, 'canBeSold', function (superFunc, self)
	local spec = self.spec_silo

	if spec.storagePerFarm then
		return false, nil
	end

	local warning = spec.sellWarningText .. '\n'
	local totalFillLevel = 0

	spec.totalFillTypeSellPrice = 0

	for fillTypeIndex, fillLevel in pairs(spec.storages[1].fillLevels) do
		totalFillLevel = totalFillLevel + fillLevel

		if fillLevel > 0 then
			local lowestSellPrice = math.huge

			for _, unloadingStation in pairs(g_currentMission.storageSystem:getUnloadingStations()) do
				if unloadingStation.owningPlaceable ~= nil and unloadingStation.isSellingPoint and unloadingStation.acceptedFillTypes[fillTypeIndex] then
					local price = unloadingStation:getEffectiveFillTypePrice(fillTypeIndex)

					if price > 0 then
						lowestSellPrice = math.min(lowestSellPrice, price)
					end
				end
			end

			if lowestSellPrice == math.huge then
				lowestSellPrice = 0.5
			end

			local price = fillLevel * lowestSellPrice * PlaceableSilo.PRICE_SELL_FACTOR
			local fillType = g_fillTypeManager:getFillTypeByIndex(fillTypeIndex)

			warning = string.format('%s%s (%s) - %s: %s\n', warning, fillType.title, AdditionalFillUnits:formatVolume(fillLevel, g_fillTypeManager:getFillTypeNameByIndex(fillTypeIndex), 0, false, true, true), g_i18n:getText('ui_sellValue'), g_i18n:formatMoney(price, 0, true, true))

			spec.totalFillTypeSellPrice = spec.totalFillTypeSellPrice + price
		end
	end

	if totalFillLevel > 0 then
		return true, warning
	end

	return true, nil
end)

AdditionalFillUnits:overwriteGameFunction(PlaceableHusbandryWater, 'updateInfo', function (_, self, superFunc, infoTable)
	superFunc(self, infoTable)

	local spec = self.spec_husbandryWater

	if not spec.automaticWaterSupply then
		local fillLevel = self:getHusbandryFillLevel(spec.fillType)

		spec.info.text = AdditionalFillUnits:formatVolume(fillLevel, g_fillTypeManager:getFillTypeNameByIndex(spec.fillType), 0, false, true, true)

		table.insert(infoTable, spec.info)
	end
end)

AdditionalFillUnits:overwriteGameFunction(PlaceableHusbandryMilk, 'updateInfo', function (_, self, superFunc, infoTable)
	local spec = self.spec_husbandryMilk

	superFunc(self, infoTable)

	local fillLevel = self:getHusbandryFillLevel(spec.fillType)

	spec.info.text = AdditionalFillUnits:formatVolume(fillLevel, g_fillTypeManager:getFillTypeNameByIndex(spec.fillType), 0, false, true, true)

	table.insert(infoTable, spec.info)
end)

AdditionalFillUnits:overwriteGameFunction(PlaceableHusbandryStraw, 'updateInfo', function (_, self, superFunc, infoTable)
	superFunc(self, infoTable)

	local spec = self.spec_husbandryStraw
	local fillLevel = self:getHusbandryFillLevel(spec.inputFillType)

	spec.info.text = AdditionalFillUnits:formatVolume(fillLevel, g_fillTypeManager:getFillTypeNameByIndex(spec.inputFillType), 0, false, true, true)

	table.insert(infoTable, spec.info)
end)

AdditionalFillUnits:overwriteGameFunction(PlaceableHusbandryLiquidManure, 'updateInfo', function (_, self, superFunc, infoTable)
	superFunc(self, infoTable)

	local spec = self.spec_husbandryLiquidManure
	local fillLevel = self:getHusbandryFillLevel(spec.fillType)

	spec.info.text = AdditionalFillUnits:formatVolume(fillLevel, g_fillTypeManager:getFillTypeNameByIndex(spec.fillType), 0, false, true, true)

	table.insert(infoTable, spec.info)
end)

AdditionalFillUnits:overwriteGameFunction(FeedingRobot, 'updateInfo', function (superFunc, self, infoTable)
	if self.infos ~= nil then
		for _, info in ipairs(self.infos) do
			local fillLevel = 0
			local fillTypeName = ''

			for _, fillType in ipairs(info.fillTypes) do
				fillLevel = fillLevel + self:getFillLevel(fillType)

				fillTypeName = g_fillTypeManager:getFillTypeNameByIndex(fillType)
			end

			info.text = AdditionalFillUnits:formatVolume(fillLevel, fillTypeName, 0, false, true, true)

			table.insert(infoTable, info)
		end
	end
end)

AdditionalFillUnits:overwriteGameFunction(PlaceableManureHeap, 'updateInfo', function (_, self, superFunc, infoTable)
	superFunc(self, infoTable)

	local spec = self.spec_manureHeap

	if spec.manureHeap == nil then
		return
	end

	local fillLevel = spec.manureHeap:getFillLevel(spec.manureHeap.fillTypeIndex)

	spec.infoFillLevel.text = AdditionalFillUnits:formatVolume(fillLevel, AdditionalFillUnits:getFillTypeNameByTitle(spec.infoFillLevel.title), 0, false, true, true)

	table.insert(infoTable, spec.infoFillLevel)
end)

AdditionalFillUnits:overwriteGameFunction(PlayerHUDUpdater, 'showPalletInfo', function (superFunc, self, pallet)
	local mass = pallet:getTotalMass()
	local farm = g_farmManager:getFarmById(pallet:getOwnerFarmId())
	local box = self.objectBox

	box:clear()

	if SpecializationUtil.hasSpecialization(BigBag, pallet.specializations) then
		box:setTitle(g_i18n:getText('shopItem_bigBag'))
	else
		box:setTitle(g_i18n:getText('infohud_pallet'))
	end

	if farm ~= nil then
		box:addLine(g_i18n:getText('fieldInfo_ownedBy'), self:convertFarmToName(farm))
	end

	if AdditionalFillUnits.currentUnit == 1 then
		box:addLine(g_i18n:getText('infohud_mass'), g_i18n:formatMass(mass))
	end

	pallet:showInfo(box)
	box:showNextFrame()
end)

local function onFrameClose()
	AdditionalFillUnits:saveVolumeUnitStateToXMLFile()
end

InGameMenuGeneralSettingsFrame.onFrameClose = Utils.appendedFunction(InGameMenuGeneralSettingsFrame.onFrameClose, onFrameClose)

local function saveToXMLFile()
	AdditionalFillUnits:saveVolumeUnitStateToXMLFile()
end

FSCareerMissionInfo.saveToXMLFile = Utils.appendedFunction(FSCareerMissionInfo.saveToXMLFile, saveToXMLFile)

addModEventListener(AdditionalFillUnits)