-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.0, 07|04|2023
-- @filename: EditFillTypeUnitDialog.lua

EditFillTypeUnitDialog = {
  CONTROLS = {
    "fillTypeMassFactor",
    "optionFillTypeUnit",
    "dialogIconElement"
  }
}

local EditFillTypeUnitDialog_mt = Class(EditFillTypeUnitDialog, YesNoDialog)

function EditFillTypeUnitDialog.new(target, customMt, additionalUnits, l10n)
  local self = YesNoDialog.new(target, customMt or EditFillTypeUnitDialog_mt)

  self.l10n = l10n
  self.additionalUnits = additionalUnits

  self:registerControls(EditFillTypeUnitDialog.CONTROLS)

  return self
end

function EditFillTypeUnitDialog:setData(data)
  local title = string.format(self.l10n:getText("ui_additionalUnits_editFillTypeUnit_title"), data.fillType.title)
  self.dialogTitleElement:setText(title)
  self.dialogIconElement:setImageFilename(data.fillType.hudOverlayFilename)

  local massFactor = data.massFactor and tostring(math.ceil(data.massFactor * 1000)) or ""
  self.fillTypeMassFactor.lastValidText = ""
  self.fillTypeMassFactor:setText(massFactor)

  local unitsTable = {}

  for _, unit in pairs(self.additionalUnits.units) do
    table.insert(unitsTable, unit.name)
  end

  self.optionFillTypeUnit:setTexts(unitsTable)
  self.optionFillTypeUnit:setState(self.additionalUnits:getUnitIndexById(data.unitId), true)

  self.fillTypeName = data.fillType.name

  self:udpateButtons(true)
end

function EditFillTypeUnitDialog:udpateButtons(disabled)
  self.yesButton:setDisabled(disabled)
end

function EditFillTypeUnitDialog:onTextChangedMassFactor(element, text)
  local factor = tonumber(text)

  if factor ~= nil and factor > 0 and factor >= 1 then
    element.lastValidText = text
  end

  if text == "" then
    element.lastValidText = ""
  end

  element:setText(element.lastValidText)

  self:udpateButtons(false)
end

function EditFillTypeUnitDialog:onClickUnit()
  self:udpateButtons(false)
end

function EditFillTypeUnitDialog:sendCallback(fillTypeName, fillTypeUnit)
  self:onClickBack()

  if self.callbackFunc ~= nil then
    if self.target ~= nil then
      self.callbackFunc(self.target, fillTypeName, fillTypeUnit)
    else
      self.callbackFunc(fillTypeName, fillTypeUnit)
    end
  end
end

function EditFillTypeUnitDialog:onClickSave()
  local fillTypeUnit = {}
  local massFactor = tonumber(self.fillTypeMassFactor.text)

  if massFactor ~= nil then
    fillTypeUnit.massFactor = massFactor / 1000
  end

  fillTypeUnit.unitId = self.additionalUnits:getUnitIdByIndex(self.optionFillTypeUnit.state)

  self:sendCallback(self.fillTypeName, fillTypeUnit)
end

function EditFillTypeUnitDialog:onClickBack()
  self:close()
end