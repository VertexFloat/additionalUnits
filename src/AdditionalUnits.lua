-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.0, 13|01|2023
-- @filename: AdditionalUnits.lua

AdditionalUnits = {
	MOD_DIRECTORY = g_currentModDirectory,
	MOD_SETTINGS_DIRECTORY = g_currentModSettingsDirectory
}

AdditionalUnits.DEFAULT_UNITS_XML_PATH = AdditionalUnits.MOD_DIRECTORY .. 'data/units.xml'
AdditionalUnits.DEFAULT_MASS_FACTOR_XML_PATH = AdditionalUnits.MOD_DIRECTORY .. 'data/massFactors.xml'

source(AdditionalUnits.MOD_DIRECTORY .. 'src/shared/globals.lua')
source(AdditionalUnits.MOD_DIRECTORY .. 'src/gui/AdditionalUnitsGui.lua')
source(AdditionalUnits.MOD_DIRECTORY .. 'src/misc/BaleUnitExtension.lua')
source(AdditionalUnits.MOD_DIRECTORY .. 'src/misc/FeedingRobotUnitExtension.lua')
source(AdditionalUnits.MOD_DIRECTORY .. 'src/misc/FillLevelsDisplayUnitExtension.lua')
source(AdditionalUnits.MOD_DIRECTORY .. 'src/misc/FillUnitUnitExtension.lua')
source(AdditionalUnits.MOD_DIRECTORY .. 'src/misc/InGameMenuAnimalsFrameUnitExtension.lua')
source(AdditionalUnits.MOD_DIRECTORY .. 'src/misc/InGameMenuPricesFrameUnitExtension.lua')
source(AdditionalUnits.MOD_DIRECTORY .. 'src/misc/InGameMenuProductionFrameUnitExtension.lua')
source(AdditionalUnits.MOD_DIRECTORY .. 'src/misc/PlaceableHusbandryFoodUnitExtension.lua')
source(AdditionalUnits.MOD_DIRECTORY .. 'src/misc/PlaceableHusbandryLiquidManureUnitExtension.lua')
source(AdditionalUnits.MOD_DIRECTORY .. 'src/misc/PlaceableHusbandryMilkUnitExtension.lua')
source(AdditionalUnits.MOD_DIRECTORY .. 'src/misc/PlaceableHusbandryStrawUnitExtension.lua')
source(AdditionalUnits.MOD_DIRECTORY .. 'src/misc/PlaceableHusbandryWaterUnitExtension.lua')
source(AdditionalUnits.MOD_DIRECTORY .. 'src/misc/PlaceableManureHeapUnitExtension.lua')
source(AdditionalUnits.MOD_DIRECTORY .. 'src/misc/PlaceableSiloUnitExtension.lua')
source(AdditionalUnits.MOD_DIRECTORY .. 'src/misc/ProductionPointUnitExtension.lua')
source(AdditionalUnits.MOD_DIRECTORY .. 'src/misc/SiloDialogUnitExtension.lua')

local AdditionalUnits_mt = Class(AdditionalUnits)

---Creating AdditionalUnits instance
---@param gui table gui object
---@param l10n table l10n object
---@param fillTypeManager table fillTypeManager object
---@return table instance instance of object
function AdditionalUnits.new(customMt, gui, l10n, fillTypeManager)
	local self = setmetatable({}, customMt or AdditionalUnits_mt)

	self.l10n = l10n
	self.fillTypeManager = fillTypeManager
	self.units = {}
	self.massFactors = {}
	self.fillTypesUnits = {}

	self.gui = AdditionalUnitsGui.new(_, self, gui, l10n, fillTypeManager)
	self.baleUnitExtension = BaleUnitExtension.new(_, self, l10n, fillTypeManager)
	self.feedingRobotUnitExtension = FeedingRobotUnitExtension.new(_, self, fillTypeManager)
	self.fillLevelsDisplayUnitExtension = FillLevelsDisplayUnitExtension.new(_, self, fillTypeManager)
	self.fillUnitUnitExtension = FillUnitUnitExtension.new(_, self, fillTypeManager)
	self.inGameMenuAnimalsFrameUnitExtension = InGameMenuAnimalsFrameUnitExtension.new(_, self, fillTypeManager)
	self.inGameMenuPricesFrameUnitExtension = InGameMenuPricesFrameUnitExtension.new(_, self)
	self.inGameMenuProductionFrameUnitExtension = InGameMenuProductionFrameUnitExtension.new(_, self, fillTypeManager)
	self.placeableHusbandryFoodUnitExtension = PlaceableHusbandryFoodUnitExtension.new(_, self)
	self.placeableHusbandryLiquidManureUnitExtension = PlaceableHusbandryLiquidManureUnitExtension.new(_, self, fillTypeManager)
	self.placeableHusbandryMilkUnitExtension = PlaceableHusbandryMilkUnitExtension.new(_, self, fillTypeManager)
	self.placeableHusbandryStrawUnitExtension = PlaceableHusbandryStrawUnitExtension.new(_, self, fillTypeManager)
	self.placeableHusbandryWaterUnitExtension = PlaceableHusbandryWaterUnitExtension.new(_, self, fillTypeManager)
	self.placeableManureHeapUnitExtension = PlaceableManureHeapUnitExtension.new(_, self, fillTypeManager)
	self.placeableSiloUnitExtension = PlaceableSiloUnitExtension.new(_, self, l10n, fillTypeManager)
	self.productionPointUnitExtension = ProductionPointUnitExtension.new(_, self, l10n, fillTypeManager)
	self.siloDialogUnitExtension = SiloDialogUnitExtension.new(_, self, fillTypeManager)

	return self
end

---Initializing AdditionalUnits
function AdditionalUnits:initialize()
	self:loadUnitsFromXML()
	self:loadMassFactorsFromXML()

	self.gui:initialize(AdditionalUnits.MOD_DIRECTORY)
	self.baleUnitExtension:initialize()
	self.feedingRobotUnitExtension:initialize()
	self.fillLevelsDisplayUnitExtension:initialize()
	self.fillUnitUnitExtension:initialize()
	self.inGameMenuAnimalsFrameUnitExtension:initialize()
	self.inGameMenuPricesFrameUnitExtension:initialize()
	self.inGameMenuProductionFrameUnitExtension:initialize()
	self.placeableHusbandryFoodUnitExtension:initialize()
	self.placeableHusbandryLiquidManureUnitExtension:initialize()
	self.placeableHusbandryMilkUnitExtension:initialize()
	self.placeableHusbandryStrawUnitExtension:initialize()
	self.placeableHusbandryWaterUnitExtension:initialize()
	self.placeableManureHeapUnitExtension:initialize()
	self.placeableSiloUnitExtension:initialize()
	self.productionPointUnitExtension:initialize()
	self.siloDialogUnitExtension:initialize()
end

---Callback on map loading
---@param filename string map file path
function AdditionalUnits:loadMap(filename)
	self:loadFillTypesUnitsFromXML()

	self.gui:loadMap(AdditionalUnits.MOD_DIRECTORY)
end

---Loading config file path
---@param file string filename
---@param defaultPath string default file path
---@return string configPath config path
function AdditionalUnits:loadConfigFile(file, defaultPath)
	local configPath = AdditionalUnits.MOD_SETTINGS_DIRECTORY .. file .. '.xml'

	createFolder(AdditionalUnits.MOD_SETTINGS_DIRECTORY)
	copyFile(defaultPath, configPath, false)

	if not fileExists(configPath) then
		configPath = defaultPath
	end

	return configPath
end

---Loading units
---@return boolean isSuccess true if loaded, false if not
function AdditionalUnits:loadUnitsFromXML()
	local xmlFilename = self:loadConfigFile('units', AdditionalUnits.DEFAULT_UNITS_XML_PATH)
	local xmlFile = XMLFile.loadIfExists('unitsXML', xmlFilename, 'units')

	if xmlFile == nil then
		Logging.error(string.format('Cannot load units xml from (%s) path!', xmlFilename))

		return false
	end

	local foundDefault = false

	xmlFile:iterate('units.unit', function (index, key)
		local unit = {
			id = xmlFile:getInt(key .. '#id', index),
			name = xmlFile:getString(key .. '#name', ''),
			unitShort = xmlFile:getString(key .. '#unitShort', ''),
			precision = xmlFile:getInt(key .. '#precision', 1),
			factor = xmlFile:getFloat(key .. '#factor', 1),
			isVolume = xmlFile:getBool(key .. '#isVolume', true)
		}

		local isDefault = xmlFile:getBool(key .. '#isDefault')

		if isDefault ~= nil then
			unit.isDefault = isDefault

			if isDefault == true then
				foundDefault = true
			end
		end

		if self.l10n:hasText(unit.name) then
			unit.name = self.l10n:getText(unit.name)
		end

		if self.l10n:hasText(unit.unitShort) then
			unit.unitShort = self.l10n:getText(unit.unitShort)
		end

		unit.name = unit.name:sub(1, 1):upper()..unit.name:sub(2)

		table.insert(self.units, unit)
	end)

	if not foundDefault then
		Logging.warning('AdditionalUnits could not find the default unit! All settings restored to default!')

		self:reset()
	end

	xmlFile:delete()

	return true
end

---Saving units
function AdditionalUnits:saveUnitsToXMLFile()
	local xmlFile = XMLFile.create('unitsXML', AdditionalUnits.MOD_SETTINGS_DIRECTORY .. 'units.xml', 'units')

	if xmlFile == nil then
		return
	end

	for i = 1, #self.units do
		local key = string.format('units.unit(%d)', i - 1)
		local unit = self.units[i]

		xmlFile:setInt(key .. '#id', unit.id)
		xmlFile:setString(key .. '#name', unit.name)
		xmlFile:setString(key .. '#unitShort', unit.unitShort)
		xmlFile:setInt(key .. '#precision', unit.precision)
		xmlFile:setFloat(key .. '#factor', unit.factor)
		xmlFile:setBool(key .. '#isVolume', unit.isVolume)

		if unit.isDefault ~= nil then
			xmlFile:setBool(key .. '#isDefault', unit.isDefault)
		end
	end

	xmlFile:save()
	xmlFile:delete()
end

---Loading mass factors
---@return boolean isSuccess true if loaded, false if not
function AdditionalUnits:loadMassFactorsFromXML()
	local xmlFilename = self:loadConfigFile('massFactors', AdditionalUnits.DEFAULT_MASS_FACTOR_XML_PATH)
	local xmlFile = XMLFile.loadIfExists('massFactorsXML', xmlFilename, 'massFactors')

	if xmlFile == nil then
		Logging.error(string.format('Cannot load mass factors xml from (%s) path!', xmlFilename))

		return false
	end

	xmlFile:iterate('massFactors.massFactor', function (_, key)
		local fillTypeName = xmlFile:getString(key .. '#fillTypeName', '')
		local value = xmlFile:getFloat(key .. '#value', 1)

		self.massFactors[fillTypeName] = value
	end)

	xmlFile:delete()

	return true
end

---Saving mass factors
function AdditionalUnits:saveMassFactorsToXMLFile()
	local xmlFile = XMLFile.create('massFactorsXML', AdditionalUnits.MOD_SETTINGS_DIRECTORY .. 'massFactors.xml', 'massFactors')

	if xmlFile == nil then
		return
	end

	local i = 0

	for name, value in pairs(self.massFactors) do
		local key = string.format('massFactors.massFactor(%d)', i)

		xmlFile:setString(key .. '#fillTypeName', name)
		xmlFile:setFloat(key .. '#value', value)

		i = i + 1
	end

	xmlFile:save()
	xmlFile:delete()
end

---Loading modified fillTypes units
---@return boolean isSuccess true if loaded from XML file, false if not
function AdditionalUnits:loadFillTypesUnitsFromXML()
	local xmlFile = XMLFile.loadIfExists('fillTypesUnitsXML', AdditionalUnits.MOD_SETTINGS_DIRECTORY .. 'fillTypes.xml', 'fillTypes')

	if xmlFile == nil then
		for _, fillTypesDesc in pairs(self.fillTypeManager:getFillTypes()) do
			if fillTypesDesc.showOnPriceTable or MISSING_FILLTYPE[fillTypesDesc.name] == true then
				self.fillTypesUnits[fillTypesDesc.name] = self:getDefaultUnitId()
			end
		end

		return false
	end

	xmlFile:iterate('fillTypes.fillType', function (_, key)
		local fillTypeName = xmlFile:getString(key .. '#fillTypeName', '')
		local value = xmlFile:getInt(key .. '#value', 1)

		self.fillTypesUnits[fillTypeName] = self:getIsUnitIdValid(value)
	end)

	xmlFile:delete()

	return true
end

---Saving modified fillTypes units
function AdditionalUnits:saveFillTypesUnitsToXMLFile()
	local xmlFile = XMLFile.create('fillTypesUnitsXML', AdditionalUnits.MOD_SETTINGS_DIRECTORY .. 'fillTypes.xml', 'fillTypes')

	if xmlFile == nil then
		return
	end

	local i = 0

	for name, value in pairs(self.fillTypesUnits) do
		local key = string.format('fillTypes.fillType(%d)', i)

		xmlFile:setString(key .. '#fillTypeName', name)
		xmlFile:setInt(key .. '#value', value)

		i = i + 1
	end

	xmlFile:save()
	xmlFile:delete()
end

---Formatting fillLevel and fillType unit
---@param fillLevel float fill level
---@param fillType string fillType name
---@param precision integer decimal places
---@param useLongName boolean use unit long name if true, short name otherwise
---@param customUnitText string use custom unit text if given, otherwise formatted
---@return string formattedNumber formatted fillLevel
---@return string unitText formatted fillType unit
function AdditionalUnits:formatFillLevel(fillLevel, fillType, precision, useLongName, customUnitText)
	local unit = self:getUnitById(self:getFillTypeUnitByFillTypeName(fillType))
	local massFactor = self:getMassFactorByFillTypeName(fillType) or 1
	local precision = unit.precision or precision
	local unitText = useLongName and unit.name or unit.unitShort

	if customUnitText == nil then
		if not unit.isVolume then
			fillLevel = fillLevel * massFactor
		end

		fillLevel = fillLevel * unit.factor
	else
		unitText = customUnitText
	end

	local formattedNumber

	if precision > 0 then
		local rounded = MathUtil.round(fillLevel, precision)

		formattedNumber = string.format('%d%s%0'..precision..'d', math.floor(rounded), self.l10n.decimalSeparator, (rounded - math.floor(rounded)) * 10 ^ precision)
	else
		formattedNumber = string.format('%d', MathUtil.round(fillLevel))
	end

	return formattedNumber, unitText
end

---Gets unit object by id
---@param id integer unit id
---@return table unit unit object if found, default unit object otherwise
function AdditionalUnits:getUnitById(id)
	for i = 1, #self.units do
		if self.units[i].id == id then
			return self.units[i]
		end
	end

	return self:getUnitById(self:getDefaultUnitId())
end

---Gets unit latest id
---@return integer id unit id
function AdditionalUnits:getUnitLastId()
	local id = 0

	for i = 1, #self.units do
		if self.units[i].id > id then
			id = self.units[i].id
		end
	end

	return id
end

---Gets unit index by unit id
---@param id integer unit id
---@return integer i unit index
function AdditionalUnits:getUnitIndexById(id)
	for i = 1, #self.units do
		if self.units[i].id == id then
			return i
		end
	end
end

---Gets default unit id
---@return integer id unit id
function AdditionalUnits:getDefaultUnitId()
	local id = 1

	for i = 1, #self.units do
		if self.units[i].isDefault then
			id = self.units[i].id

			break
		end
	end

	return id
end

---Gets unit id by unit index
---@param index integer unit index
---@return integer id unit id
function AdditionalUnits:getUnitIdByIndex(index)
	local id = 1

	for i = 1, #self.units do
		if i == index then
			id = self.units[i].id

			break
		end
	end

	return id
end

---Gets unit by unit index
---@param index integer unit index
---@return table unit unit object
function AdditionalUnits:getUnitByIndex(index)
	return self.units[index]
end

---Gets whether the unit id is valid
---@param id integer unit id
---@return integer id given unit id if valid, default unit id if not
function AdditionalUnits:getIsUnitIdValid(id)
	return self:getUnitById(id).id
end

---Gets unit id by given fillType name
---@param name string fillType name
---@return integer id unit id
function AdditionalUnits:getFillTypeUnitByFillTypeName(name)
	return self.fillTypesUnits[name]
end

---Gets mass factor by given fillType name
---@param name string fillType name
---@return float massFactor mass factor value
function AdditionalUnits:getMassFactorByFillTypeName(name)
	return self.massFactors[name]
end

---Resets all additional units settings to default
function AdditionalUnits:reset()
	self.units = {}
	self.massFactors = {}
	self.fillTypesUnits = {}

	if fileExists(AdditionalUnits.MOD_SETTINGS_DIRECTORY .. 'units.xml') then
		deleteFolder(AdditionalUnits.MOD_SETTINGS_DIRECTORY)
	end

	self:loadUnitsFromXML()
	self:loadMassFactorsFromXML()
	self:loadFillTypesUnitsFromXML()
end

---Overwrites game function
---@param object table function object
---@param funcName string funtion name
---@param newFunc func new function
function AdditionalUnits:overwriteGameFunction(object, funcName, newFunc)
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

g_additionalUnits = AdditionalUnits.new(_, g_gui, g_i18n, g_fillTypeManager)

addModEventListener(g_additionalUnits)

local function validateTypes(self)
	if self.typeName == 'vehicle' then
		g_additionalUnits:initialize()
	end
end

TypeManager.validateTypes = Utils.prependedFunction(TypeManager.validateTypes, validateTypes)