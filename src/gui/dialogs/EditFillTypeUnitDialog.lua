-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.0, 07|04|2023
-- @filename: EditFillTypeUnitDialog.lua

EditFillTypeUnitDialog = {
	CONTROLS = {
		'fillTypeMassFactor',
		'optionFillTypeUnit',
		'dialogIconElement'
	}
}

local EditFillTypeUnitDialog_mt = Class(EditFillTypeUnitDialog, YesNoDialog)

---Creating EditFillTypeUnitDialog instance
---@param additionalUnits table additionalUnits object
---@param l10n table l10n object
---@return table instance instance of object
function EditFillTypeUnitDialog.new(target, customMt, additionalUnits, l10n)
	local self = YesNoDialog.new(target, customMt or EditFillTypeUnitDialog_mt)

	self.additionalUnits = additionalUnits
	self.l10n = l10n

	self:registerControls(EditFillTypeUnitDialog.CONTROLS)

	return self
end

---Sets dialog data
---@param fillType table fillType object
---@param unitId integer unit id
---@param massFactor float fillType massFactor
function EditFillTypeUnitDialog:setData(fillType, unitId, massFactor)
	self.dialogTitleElement:setText(string.format(self.l10n:getText('ui_additionalUnits_editFillTypeUnit_title'), fillType.title))
	self.dialogIconElement:setImageFilename(fillType.hudOverlayFilename)

	self.fillTypeMassFactor.lastValidText = ''
	self.fillTypeMassFactor:setText(massFactor and tostring(math.ceil(massFactor * 1000)) or '')

	local unitsTable = {}

	for _, unit in pairs(self.additionalUnits.units) do
		table.insert(unitsTable, unit.name)
	end

	self.optionFillTypeUnit:setTexts(unitsTable)
	self.optionFillTypeUnit:setState(self.additionalUnits:getUnitIndexById(unitId), true)

	self.fillTypeName = fillType.name

	self:udpateButtons(true)
end

---Update buttons states
---@param disabled boolean disable buttons
function EditFillTypeUnitDialog:udpateButtons(disabled)
	self.yesButton:setDisabled(disabled)
end

---Callback on mass factor input text change
---@param element table text input element object
---@param text string text input element input
function EditFillTypeUnitDialog:onTextChangedMassFactor(element, text)
	if text ~= '' then
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
		element.lastValidText = ''
	end

	self:udpateButtons(false)
end

---Callback on click unit
function EditFillTypeUnitDialog:onClickUnit()
	self:udpateButtons(false)
end

---Send callback to caller
---@param fillType table fillType unit object
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

---Callback on click save
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

---Callback on click back
function EditFillTypeUnitDialog:onClickBack()
	self:close()
end