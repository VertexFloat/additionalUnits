AdditionalWeightUnits = {
    MOD_NAME = g_currentModName,
    MOD_SETTINGS_DIRECTORY = g_modSettingsDirectory,
    DEFAULT_CONFIG_PATH = g_currentModDirectory .. 'src/resources/weightUnits.xml'
}

function AdditionalWeightUnits:loadMap(filename)
    local configFilename = self:copyConfigFile()
    local weightUnits, texts = self:loadWeightUnitsFromXMLFile(configFilename)

    self.weightUnits = weightUnits

    local currentUnit = self:loadWeightUnitStateFromXMLFile()

    self.currentUnit = currentUnit

    self.weightUnitOptionElement = self:createWeightUnitOptionElement(g_currentMission.inGameMenu.pageSettingsGeneral)
    self.weightUnitOptionElement:setTexts(texts)
    self.weightUnitOptionElement:setState(self.currentUnit)
end

function AdditionalWeightUnits:copyConfigFile()
    local configPath = AdditionalWeightUnits.MOD_SETTINGS_DIRECTORY .. 'weightUnits.xml'

    copyFile(AdditionalWeightUnits.DEFAULT_CONFIG_PATH, configPath, false)

    if not fileExists(configPath) then
        configPath = AdditionalWeightUnits.DEFAULT_CONFIG_PATH
    end

    return configPath
end

function AdditionalWeightUnits:loadWeightUnitsFromXMLFile(xmlFilename)
    local units = {}
    local texts = {}
    local xmlFile = XMLFile.loadIfExists('weightUnitsXML', xmlFilename, 'weightUnits')

    if  xmlFile == nil then
        Logging.error('Cannot load weight units config file !')

        return units, texts
    end

    local i = 0

    while true do
        local key = string.format('weightUnits.weightUnit(%d)', i)

        if not xmlFile:hasProperty(key) then
            break
        end

        local j = 0
        local unit = {
            name = xmlFile:getI18NValue(key .. '#name', '', AdditionalWeightUnits.MOD_NAME, true),
            shortName = xmlFile:getI18NValue(key .. '#shortName', '', AdditionalWeightUnits.MOD_NAME, true)
        }

        while true do
            local factorKey = string.format(key .. '.factors.factor(%d)', j)

            if not xmlFile:hasProperty(factorKey) then
                break
            end

            local factor = {
                fillTypeName = xmlFile:getString(factorKey .. '#fillTypeName', ''),
                value = xmlFile:getFloat(factorKey .. '#value', 0)
            }

            if factor.value ~= 0 and factor.value ~= nil then
                if unit.factors == nil then
                    unit.factors = {}
                end

                table.insert(unit.factors, factor)
            else
                Logging.error(string.format('Weight unit factor (%s) has wrong value (Must be > 0) !', factor.fillTypeName))
            end

            j = j + 1
        end

        table.insert(texts, unit.name)
        table.insert(units, unit)

        i = i + 1
    end

    xmlFile:delete()

    return units, texts
end

function AdditionalWeightUnits:loadWeightUnitStateFromXMLFile()
    local unit = 1

    if g_savegameXML ~= nil then
        local savedUnit = Utils.getNoNil(getXMLInt(g_savegameXML, 'gameSettings.weightUnit'), unit)

        if savedUnit <= #self.weightUnits then
            unit = savedUnit
        end
    end

    return unit
end

function AdditionalWeightUnits:saveWeightUnitStateToXMLFile()
    if g_savegameXML ~= nil then
        setXMLInt(g_savegameXML, 'gameSettings.weightUnit', self.currentUnit)
    end

    g_gameSettings:saveToXMLFile(g_savegameXML)
end

function AdditionalWeightUnits:createWeightUnitOptionElement(pageSettingsGeneral)
    local multiMoneyUnit = pageSettingsGeneral.multiMoneyUnit

    pageSettingsGeneral.weightUnitOptionElement = multiMoneyUnit:clone(pageSettingsGeneral)

    local weightUnitOptionElement = pageSettingsGeneral.weightUnitOptionElement

    weightUnitOptionElement.elements[4]:setText(g_i18n:getText('setting_weightUnit'))
    weightUnitOptionElement.elements[6]:setText(g_i18n:getText('toolTip_weightUnit'))
    weightUnitOptionElement.onClickCallback = self.onClickWeightUnit

    local index = #multiMoneyUnit.parent.elements + 1

    if weightUnitOptionElement.parent ~= nil then
        weightUnitOptionElement.parent:removeElement(weightUnitOptionElement)
    end

    for i = 1, #multiMoneyUnit.parent.elements do
        if multiMoneyUnit.parent.elements[i] == multiMoneyUnit then
            index = i + 1

            break
        end
    end

    table.insert(multiMoneyUnit.parent.elements, index, weightUnitOptionElement)

    weightUnitOptionElement.parent = multiMoneyUnit.parent

    return weightUnitOptionElement
end

function AdditionalWeightUnits.onClickWeightUnit(self, state, optionElement)
    AdditionalWeightUnits:setWeightUnit(state)
end

function AdditionalWeightUnits:setWeightUnit(state)
    self.currentUnit = state
end

function AdditionalWeightUnits:formatWeight(liters, fillTypeName, precision, useLongName)
    local currentUnit = AdditionalWeightUnits:getCurrentWeightUnit()
    local formattedNumber = liters
    local unitName = currentUnit.shortName

    if useLongName then
        unitName = currentUnit.name
    end

    if currentUnit ~= nil then
        if currentUnit.factors ~= nil then
            for _, factor in pairs(currentUnit.factors) do
                if fillTypeName ~= nil then
                    if factor.fillTypeName:upper() == fillTypeName:upper() then
                        formattedNumber = formattedNumber * factor.value
                    end
                end
            end
        end
    end

    if precision > 0 then
        local rounded = MathUtil.round(formattedNumber, precision)

        -- formattedNumber = string.format("%d%s%0"..precision.."d", math.floor(rounded), g_i18n.decimalSeparator, (rounded - math.floor(rounded)) * 10 ^ precision)
        formattedNumber = string.format("%s %s", g_i18n:formatNumber(rounded, 1), unitName)
    else
        formattedNumber = string.format("%d%s", MathUtil.round(formattedNumber), unitName)
    end

    return formattedNumber
end

function AdditionalWeightUnits:getCurrentWeightUnit()
    return self.weightUnits[self.currentUnit]
end

local function onFrameClose()
    AdditionalWeightUnits:saveWeightUnitStateToXMLFile()
end

InGameMenuGeneralSettingsFrame.onFrameClose = Utils.appendedFunction(InGameMenuGeneralSettingsFrame.onFrameClose, onFrameClose)

local function saveToXMLFile()
    AdditionalWeightUnits:saveWeightUnitStateToXMLFile()
end

FSCareerMissionInfo.saveToXMLFile = Utils.appendedFunction(FSCareerMissionInfo.saveToXMLFile, saveToXMLFile)

local function updateFillLevelFrames(self)
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

            local precision = fillLevelInformation.precision or 0

            local formattedNumber

            if precision > 0 then
                local rounded = MathUtil.round(fillLevelInformation.fillLevel, precision)

                formattedNumber = string.format("%d%s%0"..precision.."d", math.floor(rounded), g_i18n.decimalSeparator, (rounded - math.floor(rounded)) * 10 ^ precision)
            else
                formattedNumber = string.format("%d", MathUtil.round(fillLevelInformation.fillLevel))
            end

            self.weightFrames[fillLevelInformation.fillType]:setVisible(fillLevelInformation.maxReached)

            local fillTypeName
            local fillType

            if fillLevelInformation.fillType ~= FillType.UNKNOWN then
                local fillTypeDesc = g_fillTypeManager:getFillTypeByIndex(fillLevelInformation.fillType)

                fillTypeName = fillTypeDesc.title
                fillType = fillTypeDesc.name
            end

            local fillText = string.format("%s (%d%%)", AdditionalWeightUnits:formatWeight(formattedNumber, fillType, precision), math.floor(100 * value))

            self.fillLevelTextBuffer[#self.fillLevelTextBuffer + 1] = fillText

            if fillTypeName ~= nil then
                self.fillTypeTextBuffer[#self.fillLevelTextBuffer] = fillTypeName
            end

            yOffset = yOffset + self.frameHeight + self.frameOffsetY
            isFirst = false
        end
    end
end

FillLevelsDisplay.updateFillLevelFrames = Utils.overwrittenFunction(FillLevelsDisplay.updateFillLevelFrames, updateFillLevelFrames)

-- Updates player hud while pointing on object

-- local function showInfo(self, superFunc, superFunc, box)
--     local spec = self.spec_fillUnit

--     if spec.isInfoDirty then
--         spec.fillUnitInfos = {}
--         local fillTypeToInfo = {}

--         for _, fillUnit in ipairs(spec.fillUnits) do
--             if fillUnit.showOnInfoHud and fillUnit.fillLevel > 0 then
--                 local info = fillTypeToInfo[fillUnit.fillType]
--                 if info == nil then
--                     local fillType = g_fillTypeManager:getFillTypeByIndex(fillUnit.fillType)
--                     info = {title=fillType.title, fillLevel=0, unit=fillUnit.unitText, precision=0}
--                     table.insert(spec.fillUnitInfos, info)
--                     fillTypeToInfo[fillUnit.fillType] = info
--                 end

--                 info.fillLevel = info.fillLevel + fillUnit.fillLevel
--                 if info.precision == 0 and fillUnit.fillLevel > 0 then
--                     info.precision = fillUnit.uiPrecision or 0
--                 end
--             end
--         end

--         spec.isInfoDirty = false
--     end

--     for _, info in ipairs(spec.fillUnitInfos) do
--         local formattedNumber
--         if info.precision > 0 then
--             local rounded = MathUtil.round(info.fillLevel, info.precision)
--             formattedNumber = string.format("%d%s%0"..info.precision.."d", math.floor(rounded), g_i18n.decimalSeparator, (rounded - math.floor(rounded)) * 10 ^ info.precision)
--         else
--             formattedNumber = string.format("%d", MathUtil.round(info.fillLevel))
--         end

--         formattedNumber = formattedNumber .. " " .. (info.unit or g_i18n:getVolumeUnit())

--         box:addLine(info.title, formattedNumber)
--     end

--     superFunc(self, box)
-- end

-- FillUnit.showInfo = Utils.overwrittenFunction(FillUnit.showInfo, showInfo)

-- Updates silo refill hud

local function setFillLevels(self, superFunc, fillLevels, hasInfiniteCapacity)
    self.fillLevels = fillLevels
    self.fillTypeMapping = {}

    local fillTypesTable = {}
    local selectedId = 1
    local numFillLevels = 1

    for fillTypeIndex, _ in pairs(fillLevels) do
        local fillType = g_fillTypeManager:getFillTypeByIndex(fillTypeIndex)
        local level = Utils.getNoNil(fillLevels[fillTypeIndex], 0)
        local name = nil

        if hasInfiniteCapacity then
            name = string.format("%s", fillType.title)
        else
            -- name = string.format("%s %s", fillType.title, g_i18n:formatMass(level)) -- Using I18N formatMass, to consider if just change formatMass or new function
            name = string.format("%s %s", fillType.title, AdditionalWeightUnits:formatWeight(level, fillType.name, 1))
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
end

SiloDialog.setFillLevels = Utils.overwrittenFunction(SiloDialog.setFillLevels, setFillLevels)

addModEventListener(AdditionalWeightUnits)