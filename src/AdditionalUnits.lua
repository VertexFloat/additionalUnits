-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.2, 28|02|2024
-- @filename: AdditionalUnits.lua

-- Changelog (1.0.0.1):
-- added DEF support

-- Changelog (1.0.0.2):
-- cleaned code

AdditionalUnits = {
  MOD_NAME = g_currentModName,
  MOD_DIRECTORY = g_currentModDirectory,
  MOD_SETTINGS_DIRECTORY = g_currentModSettingsDirectory
}

AdditionalUnits.DEFAULT_UNITS_XML_PATH = AdditionalUnits.MOD_DIRECTORY .. "data/units.xml"
AdditionalUnits.DEFAULT_MASS_FACTOR_XML_PATH = AdditionalUnits.MOD_DIRECTORY .. "data/massFactors.xml"

source(AdditionalUnits.MOD_DIRECTORY .. "src/gui/AdditionalUnitsGui.lua")
source(AdditionalUnits.MOD_DIRECTORY .. "src/misc/BaleUnitExtension.lua")
source(AdditionalUnits.MOD_DIRECTORY .. "src/misc/FeedingRobotUnitExtension.lua")
source(AdditionalUnits.MOD_DIRECTORY .. "src/misc/FillLevelsDisplayUnitExtension.lua")
source(AdditionalUnits.MOD_DIRECTORY .. "src/misc/FillUnitUnitExtension.lua")
source(AdditionalUnits.MOD_DIRECTORY .. "src/misc/InGameMenuAnimalsFrameUnitExtension.lua")
source(AdditionalUnits.MOD_DIRECTORY .. "src/misc/InGameMenuPricesFrameUnitExtension.lua")
source(AdditionalUnits.MOD_DIRECTORY .. "src/misc/InGameMenuProductionFrameUnitExtension.lua")
source(AdditionalUnits.MOD_DIRECTORY .. "src/misc/PlaceableHusbandryFoodUnitExtension.lua")
source(AdditionalUnits.MOD_DIRECTORY .. "src/misc/PlaceableHusbandryLiquidManureUnitExtension.lua")
source(AdditionalUnits.MOD_DIRECTORY .. "src/misc/PlaceableHusbandryMilkUnitExtension.lua")
source(AdditionalUnits.MOD_DIRECTORY .. "src/misc/PlaceableHusbandryStrawUnitExtension.lua")
source(AdditionalUnits.MOD_DIRECTORY .. "src/misc/PlaceableHusbandryWaterUnitExtension.lua")
source(AdditionalUnits.MOD_DIRECTORY .. "src/misc/PlaceableManureHeapUnitExtension.lua")
source(AdditionalUnits.MOD_DIRECTORY .. "src/misc/PlaceableSiloUnitExtension.lua")
source(AdditionalUnits.MOD_DIRECTORY .. "src/misc/ProductionPointUnitExtension.lua")
source(AdditionalUnits.MOD_DIRECTORY .. "src/misc/SiloDialogUnitExtension.lua")
source(AdditionalUnits.MOD_DIRECTORY .. "src/misc/TargetFillLevelUnitExtension.lua")
source(AdditionalUnits.MOD_DIRECTORY .. "src/misc/InfoDisplayExtensionUnitExtension.lua")
source(AdditionalUnits.MOD_DIRECTORY .. "src/misc/StrawHarvestPackUnitExtension.lua")
source(AdditionalUnits.MOD_DIRECTORY .. "src/shared/constants.lua")

local AdditionalUnits_mt = Class(AdditionalUnits)

function AdditionalUnits.new(customMt, gui, i18n, fillTypeManager)
  local self = setmetatable({}, customMt or AdditionalUnits_mt)

  self.i18n = i18n
  self.fillTypeManager = fillTypeManager

  self.units = {}
  self.fillTypesUnits = {}

  self.gui = AdditionalUnitsGui.new(_, self, gui, i18n, fillTypeManager)
  self.baleUnitExtension = BaleUnitExtension.new(_, self, i18n, fillTypeManager)
  self.feedingRobotUnitExtension = FeedingRobotUnitExtension.new(_, self, fillTypeManager)
  self.fillLevelsDisplayUnitExtension = FillLevelsDisplayUnitExtension.new(_, self, fillTypeManager)
  self.fillUnitUnitExtension = FillUnitUnitExtension.new(_, self, fillTypeManager)
  self.inGameMenuAnimalsFrameUnitExtension = InGameMenuAnimalsFrameUnitExtension.new(_, self, i18n, fillTypeManager)
  self.inGameMenuPricesFrameUnitExtension = InGameMenuPricesFrameUnitExtension.new(_, self, i18n)
  self.inGameMenuProductionFrameUnitExtension = InGameMenuProductionFrameUnitExtension.new(_, self, i18n, fillTypeManager)
  self.placeableHusbandryFoodUnitExtension = PlaceableHusbandryFoodUnitExtension.new(_, self)
  self.placeableHusbandryLiquidManureUnitExtension = PlaceableHusbandryLiquidManureUnitExtension.new(_, self, i18n, fillTypeManager)
  self.placeableHusbandryMilkUnitExtension = PlaceableHusbandryMilkUnitExtension.new(_, self, i18n, fillTypeManager)
  self.placeableHusbandryStrawUnitExtension = PlaceableHusbandryStrawUnitExtension.new(_, self, i18n, fillTypeManager)
  self.placeableHusbandryWaterUnitExtension = PlaceableHusbandryWaterUnitExtension.new(_, self, i18n, fillTypeManager)
  self.placeableManureHeapUnitExtension = PlaceableManureHeapUnitExtension.new(_, self, i18n, fillTypeManager)
  self.placeableSiloUnitExtension = PlaceableSiloUnitExtension.new(_, self, i18n, fillTypeManager)
  self.productionPointUnitExtension = ProductionPointUnitExtension.new(_, self, i18n, fillTypeManager)
  self.siloDialogUnitExtension = SiloDialogUnitExtension.new(_, self, i18n, fillTypeManager)
  self.targetFillLevelUnitExtension = TargetFillLevelUnitExtension.new(_, self)
  self.infoDisplayExtensionUnitExtension = InfoDisplayExtensionUnitExtension.new(_, self)
  self.strawHarvestPackUnitExtension = StrawHarvestPackUnitExtension.new(_, self, i18n)

  return self
end

function AdditionalUnits:initialize()
  if not self:loadUnitsFromXML() then
    return
  end

  self.gui:initialize()
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

function AdditionalUnits:loadMap(filename)
  if g_modIsLoaded["FS22_DefPack"] then
    MISSING_FILLTYPES.DEF = true
  end

  if g_modIsLoaded["FS22_TargetFillLevel"] then
    self.targetFillLevelUnitExtension:loadMap()
  end

  if g_modIsLoaded["FS22_InfoDisplayExtension"] then
    self.infoDisplayExtensionUnitExtension:loadMap()
  end

  if g_modIsLoaded["FS22_strawHarvestPack"] then
    self.strawHarvestPackUnitExtension:loadMap()
  end

  self:loadFillTypesUnitsFromXML()

  self.gui:loadMap()
end

function AdditionalUnits:loadConfigFile(file, defaultPath)
  local configPath = AdditionalUnits.MOD_SETTINGS_DIRECTORY .. file .. ".xml"

  createFolder(AdditionalUnits.MOD_SETTINGS_DIRECTORY)
  copyFile(defaultPath, configPath, false)

  if not fileExists(configPath) then
    configPath = defaultPath
  end

  return configPath
end

function AdditionalUnits:loadUnitsFromXML()
  local xmlFilename = self:loadConfigFile("units", AdditionalUnits.DEFAULT_UNITS_XML_PATH)
  local xmlFile = XMLFile.loadIfExists("unitsXML", xmlFilename, "units")

  if xmlFile == nil then
    Logging.error(string.format("Additional Units: Failed to load units from (%s) path!", xmlFilename))

    return false
  end

  local foundDefault = false

  xmlFile:iterate("units.unit", function (index, key)
    local unit = {
      id = xmlFile:getInt(key .. "#id", index),
      name = xmlFile:getI18NValue(key .. "#name", "", AdditionalUnits.MOD_NAME),
      shortName = xmlFile:getI18NValue(key .. "#shortName", "", AdditionalUnits.MOD_NAME),
      precision = xmlFile:getInt(key .. "#precision", 1),
      factor = xmlFile:getFloat(key .. "#factor", 1),
      isVolume = xmlFile:getBool(key .. "#isVolume", true)
    }

    local isDefault = xmlFile:getBool(key .. "#isDefault")

    if isDefault ~= nil then
      unit.isDefault = isDefault

      foundDefault = isDefault
    end

    unit.name = unit.name:sub(1, 1):upper() .. unit.name:sub(2)

    table.insert(self.units, unit)
  end)

  if not foundDefault then
    Logging.warning("Additional Units: failed to find default unit! All settings are restored to default!")

    self:reset()
  end

  xmlFile:delete()

  return true
end

function AdditionalUnits:saveUnitsToXMLFile()
  local xmlFile = XMLFile.create("unitsXML", AdditionalUnits.MOD_SETTINGS_DIRECTORY .. "units.xml", "units")

  if xmlFile == nil then
    Logging.error("Additional Units: Something went wrong while trying to save units!")

    return
  end

  for i = 1, #self.units do
    local key = string.format("units.unit(%d)", i - 1)
    local unit = self.units[i]

    xmlFile:setInt(key .. "#id", unit.id)
    xmlFile:setString(key .. "#name", unit.name)
    xmlFile:setString(key .. "#shortName", unit.shortName)
    xmlFile:setInt(key .. "#precision", unit.precision)
    xmlFile:setFloat(key .. "#factor", unit.factor)
    xmlFile:setBool(key .. "#isVolume", unit.isVolume)

    if unit.isDefault ~= nil then
      xmlFile:setBool(key .. "#isDefault", unit.isDefault)
    end
  end

  xmlFile:save()
  xmlFile:delete()
end

function AdditionalUnits:loadMassFactorsFromXML()
  local xmlFile = XMLFile.loadIfExists("massFactorsXML", AdditionalUnits.DEFAULT_MASS_FACTOR_XML_PATH, "massFactors")
  local massFactors = {}

  if xmlFile == nil then
    Logging.error(string.format("Additional Units: Failed to load mass factors from (%s) path!", AdditionalUnits.DEFAULT_MASS_FACTOR_XML_PATH))

    return massFactors
  end

  xmlFile:iterate("massFactors.massFactor", function (_, key)
    local fillTypeName = xmlFile:getString(key .. "#fillTypeName", "")
    local value = xmlFile:getFloat(key .. "#value", 1)

    massFactors[fillTypeName] = value
  end)

  xmlFile:delete()

  return massFactors
end

function AdditionalUnits:loadFillTypesUnitsFromXML()
  local xmlFile = XMLFile.loadIfExists("fillTypesUnitsXML", AdditionalUnits.MOD_SETTINGS_DIRECTORY .. "fillTypes.xml", "fillTypes")

  if xmlFile == nil then
    local massFactors = self:loadMassFactorsFromXML()

    for _, fillTypesDesc in pairs(self.fillTypeManager:getFillTypes()) do
      local fillTypeName = fillTypesDesc.name

      if fillTypesDesc.showOnPriceTable or MISSING_FILLTYPES[fillTypeName] == true then
        self.fillTypesUnits[fillTypeName] = {
          unitId = self:getDefaultUnitId(),
          massFactor = massFactors[fillTypeName]
        }
      end
    end

    return
  end

  xmlFile:iterate("fillTypes.fillType", function (_, key)
    local name = xmlFile:getString(key .. "#name", "")

    self.fillTypesUnits[name] = {
      unitId = xmlFile:getInt(key .. "#unitId", 1),
      massFactor = xmlFile:getFloat(key .. "#massFactor", 1)
    }
  end)

  xmlFile:delete()
end

function AdditionalUnits:saveFillTypesUnitsToXMLFile()
  local xmlFile = XMLFile.create("fillTypesUnitsXML", AdditionalUnits.MOD_SETTINGS_DIRECTORY .. "fillTypes.xml", "fillTypes")

  if xmlFile == nil then
    Logging.error("Additional Units: Something went wrong while trying to save fill types units!")

    return
  end

  local i = 0

  for name, fillTypeUnit in pairs(self.fillTypesUnits) do
    local key = string.format("fillTypes.fillType(%d)", i)

    xmlFile:setString(key .. "#name", name)
    xmlFile:setInt(key .. "#unitId", fillTypeUnit.unitId)

    local massFactor = fillTypeUnit.massFactor

    if massFactor ~= nil then
      xmlFile:setFloat(key .. "#massFactor", massFactor)
    end

    i = i + 1
  end

  xmlFile:save()
  xmlFile:delete()
end

function AdditionalUnits:formatFillLevel(fillLevel, fillTypeName)
  local fillTypeUnit = self:getFillTypeUnitByFillTypeName(fillTypeName)
  local unit = self:getUnitById(0)

  if fillTypeUnit ~= nil then
    unit = self:getUnitById(fillTypeUnit.unitId)

    if not unit.isVolume then
      local massFactor = fillTypeUnit.massFactor or 1

      fillLevel = fillLevel * massFactor
    end

    fillLevel = fillLevel * unit.factor
  end

  return fillLevel, unit
end

function AdditionalUnits:getUnitById(id)
  for i = 1, #self.units do
    local unit = self.units[i]

    if unit.id == id then
      return unit
    end
  end

  return self:getUnitById(self:getDefaultUnitId())
end

function AdditionalUnits:getUnitByIndex(index)
  return self.units[index]
end

function AdditionalUnits:getUnitLastId()
  local id = 0

  for i = 1, #self.units do
    id = math.max(self.units[i].id, id)
  end

  return id
end

function AdditionalUnits:getUnitIndexById(id)
  for i = 1, #self.units do
    if self.units[i].id == id then
      return i
    end
  end
end

function AdditionalUnits:getUnitIdByIndex(index)
  local id = self:getDefaultUnitId()

  for i = 1, #self.units do
    if i == index then
      id = self.units[i].id
      break
    end
  end

  return id
end

function AdditionalUnits:getDefaultUnitId()
  local id = 1

  for i = 1, #self.units do
    local unit = self.units[i]

    if unit.isDefault then
      id = unit.id
      break
    end
  end

  return id
end

function AdditionalUnits:getFillTypeUnitByFillTypeName(name)
  return self.fillTypesUnits[name]
end

function AdditionalUnits:reset()
  self.units = {}
  self.fillTypesUnits = {}

  if fileExists(AdditionalUnits.MOD_SETTINGS_DIRECTORY .. "units.xml") then
    deleteFolder(AdditionalUnits.MOD_SETTINGS_DIRECTORY)
  end

  if self:loadUnitsFromXML() then
    self:loadFillTypesUnitsFromXML()
  end
end

function AdditionalUnits:overwriteGameFunction(object, funcName, newFunc)
  if object == nil then
    return
  end

  local oldFunc = object[funcName]

  if oldFunc ~= nil then
    object[funcName] = function(...)
      return newFunc(oldFunc, ...)
    end
  end
end

g_additionalUnits = AdditionalUnits.new(_, g_gui, g_i18n, g_fillTypeManager)

addModEventListener(g_additionalUnits)

local function validateTypes(self)
  if self.typeName == "vehicle" then
    g_additionalUnits:initialize()
  end
end

TypeManager.validateTypes = Utils.prependedFunction(TypeManager.validateTypes, validateTypes)