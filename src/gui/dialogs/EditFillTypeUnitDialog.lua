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

  self.additionalUnits = additionalUnits
  self.l10n = l10n

  self:registerControls(EditFillTypeUnitDialog.CONTROLS)

  return self
end

function EditFillTypeUnitDialog:setData(fillType, unitId, massFactor)
  self.dialogTitleElement:setText(string.format(self.l10n:getText("ui_additionalUnits_editFillTypeUnit_title"), fillType.title))
  self.dialogIconElement:setImageFilename(fillType.hudOverlayFilename)

  self.fillTypeMassFactor.lastValidText = ""
  self.fillTypeMassFactor:setText(massFactor and tostring(math.ceil(massFactor * 1000)) or "")

  local unitsTable = {}

  for _, unit in pairs(self.additionalUnits.units) do
    table.insert(unitsTable, unit.name)
  end

  self.optionFillTypeUnit:setTexts(unitsTable)
  self.optionFillTypeUnit:setState(self.additionalUnits:getUnitIndexById(unitId), true)

  self.fillTypeName = fillType.name

  self:udpateButtons(true)
end

function EditFillTypeUnitDialog:udpateButtons(disabled)
  self.yesButton:setDisabled(disabled)
end

function EditFillTypeUnitDialog:onTextChangedMassFactor(element, text)
  if text ~= "" then
    local factor = tonumber(text)

    if factor ~= nil then
      if factor > 0 and factor >= 1 then
        element.lastValidText = text
      else
        element:setText(element.lastValidText)
      end
    else
      element:setText(element.lastValidText)
    end
  else
    element.lastValidText = ""
  end

  self:udpateButtons(false)
end

function EditFillTypeUnitDialog:onClickUnit()
  self:udpateButtons(false)
end

function EditFillTypeUnitDialog:sendCallback(fillType)
  self:onClickBack()

  if self.callbackFunc ~= nil then
    if self.target ~= nil then
      self.callbackFunc(self.target, fillType.name, fillType.unitId, fillType.massFactor)
    else
      self.callbackFunc(fillType.name, fillType.unitId, fillType.massFactor)
    end
  end
end

function EditFillTypeUnitDialog:onClickSave()
  local fillType = {
    name = self.fillTypeName,
    unitId = self.additionalUnits:getUnitIdByIndex(self.optionFillTypeUnit.state),
    massFactor = tonumber(self.fillTypeMassFactor.text)
  }

  if fillType.massFactor ~= nil then
    fillType.massFactor = fillType.massFactor / 1000
  end

  self:sendCallback(fillType)
end

function EditFillTypeUnitDialog:onClickBack()
  self:close()
end