-- EditUnitDialog.lua
--
-- author: 4c65736975
--
-- Copyright (c) 2024 VertexFloat. All Rights Reserved.
--
-- This source code is licensed under the GPL-3.0 license found in the
-- LICENSE file in the root directory of this source tree.

EditUnitDialog = {
  CONTROLS = {
    "textUnitName",
    "textUnitShortName",
    "checkedUnitVolume",
    "optionUnitPrecision",
    "textUnitFactor"
  }
}

EditUnitDialog.MAX_PRECISION = 6
EditUnitDialog.UNIT_TEMPLATE = {
  name = "",
  shortName = "",
  precision = 1,
  factor = 1,
  isVolume = true
}

local EditUnitDialog_mt = Class(EditUnitDialog, YesNoDialog)

function EditUnitDialog.new(target, customMt, additionalUnits, i18n)
  local self = YesNoDialog.new(target, customMt or EditUnitDialog_mt)

  self.i18n = i18n
  self.additionalUnits = additionalUnits

  self.precisionMapping = {}
  self.unit = table.copy(EditUnitDialog.UNIT_TEMPLATE)

  self:registerControls(EditUnitDialog.CONTROLS)

  return self
end

function EditUnitDialog:setData(data)
  local title = self.i18n:getText("ui_additionalUnits_editUnit_title_new")

  if data ~= nil then
    title = string.format(self.i18n:getText("ui_additionalUnits_editUnit_title"), data.name)

    self.unit = data
  end

  self.dialogTitleElement:setText(title)

  self.textUnitName:setText(self.unit.name)
  self.textUnitShortName:setText(self.unit.shortName)
  self.checkedUnitVolume:setState(self.unit.isVolume and 2 or 1)

  local unitFactor = tostring(MathUtil.round(self.unit.factor, 7))
  self.textUnitFactor.lastValidText = ""
  self.textUnitFactor:setText(unitFactor)

  local precisions = {}

  for i = 0, EditUnitDialog.MAX_PRECISION do
    table.insert(precisions, tostring(i))
    table.insert(self.precisionMapping, i)
  end

  self.optionUnitPrecision:setTexts(precisions)
  self.optionUnitPrecision:setState(self.unit.precision + 1, true)

  local isDefault = self.unit.isDefault or false
  self.textUnitName:setDisabled(isDefault)
  self.textUnitShortName:setDisabled(isDefault)
  self.checkedUnitVolume:setDisabled(isDefault)
  self.textUnitFactor:setDisabled(isDefault)
  self.yesButton:setDisabled(true)
end

function EditUnitDialog:udpateButtons()
  local disabled = self.textUnitName.text == "" or self.textUnitShortName.text == "" or self.textUnitFactor.text == ""

  self.yesButton:setDisabled(disabled)
end

function EditUnitDialog:onTextChangedName(element, text)
  self.unit.name = text

  self:udpateButtons()
end

function EditUnitDialog:onTextChangedShortName(element, text)
  self.unit.shortName = text

  self:udpateButtons()
end

function EditUnitDialog:onClickVolume()
  self.unit.isVolume = self.checkedUnitVolume.state == 2 and true or false

  self:udpateButtons()
end

function EditUnitDialog:onClickPrecision()
  self.unit.precision = self.precisionMapping[self.optionUnitPrecision.state]

  self:udpateButtons()
end

function EditUnitDialog:onTextChangedFactor(element, text)
  local factor = tonumber(text)

  if factor ~= nil then
    element.lastValidText = text

    self.unit.factor = factor
  end

  if text == "" then
    element.lastValidText = ""
  end

  element:setText(element.lastValidText)

  self:udpateButtons()
end

function EditUnitDialog:sendCallback(unit)
  self:onClickBack()

  if self.callbackFunc ~= nil then
    if self.target ~= nil then
      self.callbackFunc(self.target, unit)
    else
      self.callbackFunc(unit)
    end
  end
end

function EditUnitDialog:onClickSave()
  self.unit.id = self.unit.id or self.additionalUnits:getUnitLastId() + 1

  self:sendCallback(self.unit)
end

function EditUnitDialog:onClickBack()
  self:close()
end

function EditUnitDialog:onClose()
  EditUnitDialog:superClass().onClose(self)

  self.precisionMapping = {}
  self.unit = table.copy(EditUnitDialog.UNIT_TEMPLATE)
end