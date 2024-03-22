-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.0, 05|04|2023
-- @filename: AdditionalUnitsMenu.lua

AdditionalUnitsMenu = {}

local AdditionalUnitsMenu_mt = Class(AdditionalUnitsMenu, ScreenElement)

AdditionalUnitsMenu.CONTROLS = {
  "unitsList",
  "fillTypesList",
  "smoothListLayout",
  "deleteButton"
}

function AdditionalUnitsMenu.new(target, customMt, additionalUnits, gui, l10n, fillTypeManager)
  local self = AdditionalUnitsMenu:superClass().new(target, customMt or AdditionalUnitsMenu_mt)

  self.gui = gui
  self.l10n = l10n
  self.additionalUnits = additionalUnits
  self.fillTypeManager = fillTypeManager

  self.fillTypes = {}
  self.lastSelectedList = nil

  self:registerControls(AdditionalUnitsMenu.CONTROLS)

  return self
end

function AdditionalUnitsMenu.createFromExistingGui(gui, guiName)
  local newGui = AdditionalUnitsMenu.new(nil, nil, gui.additionalUnits, gui.gui, gui.l10n, gui.fillTypeManager)

  g_gui.guis[gui.name].target:delete()
  g_gui.guis[gui.name]:delete()

  g_gui:loadGui(gui.xmlFilename, guiName, newGui)

  return newGui
end

function AdditionalUnitsMenu:copyAttributes(src)
  AdditionalUnitsMenu:superClass().copyAttributes(self, src)

  self.gui = src.gui
  self.l10n = src.l10n
  self.additionalUnits = src.additionalUnits
  self.fillTypeManager = src.fillTypeManager
end

function AdditionalUnitsMenu:onGuiSetupFinished()
  AdditionalUnitsMenu:superClass().onGuiSetupFinished(self)

  self.unitsList:setDataSource(self)
  self.fillTypesList:setDataSource(self)
end

function AdditionalUnitsMenu:onOpen()
  AdditionalUnitsMenu:superClass().onOpen(self)

  self:rebuildTables()

  FocusManager:setFocus(self.fillTypesList)
end

function AdditionalUnitsMenu:updateMenuButtons()
  local disabled = true

  if FocusManager:getFocusedElement() == self.unitsList and self.additionalUnits:getUnitByIndex(self.unitsList.selectedIndex).isDefault == nil then
    disabled = false
  end

  self.deleteButton:setDisabled(disabled)
end

function AdditionalUnitsMenu:rebuildTables()
  self.fillTypes = {}

  for _, fillTypesDesc in pairs(self.fillTypeManager:getFillTypes()) do
    if fillTypesDesc.showOnPriceTable or MISSING_FILLTYPES[fillTypesDesc.name] == true then
      table.insert(self.fillTypes, fillTypesDesc)
    end
  end

  self.unitsList:reloadData()
  self.fillTypesList:reloadData()
end

function AdditionalUnitsMenu:getNumberOfItemsInSection(list, section)
  if list == self.fillTypesList then
    return #self.fillTypes
  else
    return #self.additionalUnits.units
  end
end

function AdditionalUnitsMenu:populateCellForItemInSection(list, section, index, cell)
  if list == self.fillTypesList then
    local fillTypeDesc = self.fillTypes[index]
    local fillTypeUnit = self.additionalUnits:getFillTypeUnitByFillTypeName(fillTypeDesc.name)

    if fillTypeUnit == nil then
      return
    end

    local unit = self.additionalUnits:getUnitById(fillTypeUnit.unitId)
    local massFactor = fillTypeUnit.massFactor and string.format(self.l10n:getText("ui_additionalUnits_massFactor"), math.ceil(fillTypeUnit.massFactor * 1000)) or "-"

    cell:getAttribute("icon"):setImageFilename(fillTypeDesc.hudOverlayFilename)
    cell:getAttribute("title"):setText(fillTypeDesc.title)
    cell:getAttribute("unit"):setText(unit.shortName)
    cell:getAttribute("mass"):setText(massFactor)
  else
    local unit = self.additionalUnits:getUnitByIndex(index)

    cell:getAttribute("name"):setText(unit.name .. " - " .. unit.shortName)
    cell:getAttribute("precision"):setText(unit.precision)
    cell:getAttribute("factor"):setText(MathUtil.round(unit.factor, 7))
  end
end

function AdditionalUnitsMenu:onListSelectionChanged(list, section, index)
  self.lastSelectedList = list

  self:updateMenuButtons()
end

function AdditionalUnitsMenu:onDoubleClickFillTypesListItem(list, section, index, element)
  local selectedFillType = self.fillTypes[index]
  local fillTypeUnit = self.additionalUnits:getFillTypeUnitByFillTypeName(selectedFillType.name)

  fillTypeUnit.fillType = selectedFillType

  self.additionalUnits.gui:showEditFillTypeUnitDialog({
    data = fillTypeUnit,
    callback = self.onEditFillTypeUnit,
    target = self
  })
end

function AdditionalUnitsMenu:onEditFillTypeUnit(fillTypeName, fillTypeUnit)
  if fillTypeName ~= "" and fillTypeUnit ~= nil then
    self.additionalUnits.fillTypesUnits[fillTypeName] = fillTypeUnit
    self.additionalUnits:saveFillTypesUnitsToXMLFile()

    self:rebuildTables()
  end
end

function AdditionalUnitsMenu:onDoubleClickUnitsListItem(list, section, index, element)
  self.additionalUnits.gui:showEditUnitDialog({
    data = self.additionalUnits:getUnitByIndex(index),
    callback = self.onEditUnit,
    target = self
  })
end

function AdditionalUnitsMenu:onEditUnit(unit)
  local unitIndex = self.additionalUnits:getUnitIndexById(unit.id)

  if unitIndex ~= nil then
    self.additionalUnits.units[unitIndex] = unit
    self.additionalUnits:saveUnitsToXMLFile()

    self:rebuildTables()
  end
end

function AdditionalUnitsMenu:onClickNew()
  self.additionalUnits.gui:showEditUnitDialog({
    callback = self.onNewUnit,
    target = self
  })
end

function AdditionalUnitsMenu:onNewUnit(unit)
  table.insert(self.additionalUnits.units, unit)

  self.gui:showInfoDialog({
    dialogType = DialogElement.TYPE_INFO,
    text = string.format(self.l10n:getText("ui_additionalUnits_createdNewUnit"), unit.name)
  })

  self.unitsList:reloadData()
  self.additionalUnits:saveUnitsToXMLFile()
end

function AdditionalUnitsMenu:onClickDelete()
  local unit = self.additionalUnits:getUnitByIndex(self.unitsList.selectedIndex)

  self.gui:showYesNoDialog({
    text = string.format(self.l10n:getText("ui_additionalUnits_youWantToDeleteUnit"), unit.name),
    title = self.l10n:getText("button_delete"),
    dialogType = DialogElement.TYPE_QUESTION,
    callback = self.onYesNoDeleteUnit,
    args = unit,
    target = self
  })
end

function AdditionalUnitsMenu:onYesNoDeleteUnit(yes, unit)
  if not yes then
    return
  end

  for name, fillTypeUnit in pairs(self.additionalUnits.fillTypesUnits) do
    if fillTypeUnit.unitId == unit.id then
      self.additionalUnits.fillTypesUnits[name].unitId = self.additionalUnits:getDefaultUnitId()
    end
  end

  table.remove(self.additionalUnits.units, self.unitsList.selectedIndex)

  self.gui:showInfoDialog({
    dialogType = DialogElement.TYPE_INFO,
    text = self.l10n:getText("ui_additionalUnits_deletedUnit")
  })

  self.additionalUnits:saveUnitsToXMLFile()
  self.additionalUnits:saveFillTypesUnitsToXMLFile()

  self:rebuildTables()
end

function AdditionalUnitsMenu:onClickChange()
  if self.lastSelectedList ~= nil then
    if self.lastSelectedList == self.fillTypesList then
      self:onDoubleClickFillTypesListItem(self.lastSelectedList, nil, self.lastSelectedList.selectedIndex, nil)
    else
      self:onDoubleClickUnitsListItem(self.lastSelectedList, nil, self.lastSelectedList.selectedIndex, nil)
    end
  end
end

function AdditionalUnitsMenu:onClickReset()
  self.gui:showYesNoDialog({
    text = self.l10n:getText("ui_loadDefaultSettings"),
    title = self.l10n:getText("button_reset"),
    dialogType = DialogElement.TYPE_WARNING,
    callback = self.onYesNoResetSettings,
    target = self
  })
end

function AdditionalUnitsMenu:onYesNoResetSettings(yes)
  if not yes then
    return
  end

  self.additionalUnits:reset()

  self.gui:showInfoDialog({
    dialogType = DialogElement.TYPE_INFO,
    text = self.l10n:getText("ui_loadedDefaultSettings")
  })

  self:rebuildTables()
end

function AdditionalUnitsMenu:onClickBack()
  AdditionalUnitsMenu:superClass().onClickBack(self)

  self:changeScreen(nil)
end