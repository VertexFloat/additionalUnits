-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.0, 07|04|2023
-- @filename: EditUnitDialog.lua

EditUnitDialog = {
	CONTROLS = {
		'textUnitName',
		'textUnitShortName',
		'checkedUnitVolume',
		'optionUnitPrecision',
		'textUnitFactor'
	}
}

EditUnitDialog.MAX_PRECISION = 6

local EditUnitDialog_mt = Class(EditUnitDialog, YesNoDialog)

---Creating EditUnitDialog instance
---@param additionalUnits table additionalUnits object
---@param l10n table l10n object
---@return table instance instance of object
function EditUnitDialog.new(target, customMt, additionalUnits, l10n)
	local self = YesNoDialog.new(target, customMt or EditUnitDialog_mt)

	self.additionalUnits = additionalUnits
	self.l10n = l10n
	self.precisionMapping = {}

	self:registerControls(EditUnitDialog.CONTROLS)

	return self
end

---Sets dialog data
---@param data table unit object
function EditUnitDialog:setData(data)
	local text = data and string.format(self.l10n:getText('ui_additionalUnits_editUnit_title'), data.name) or self.l10n:getText('ui_additionalUnits_editUnit_title_new')

	self.dialogTitleElement:setText(text)

	if data == nil then
		data = EditUnitDialog.NEW_UNIT_TEMPLATE
	end

	self.id = data.id or self.additionalUnits:getUnitLastId() + 1

	self.textUnitName:setText(data.name)
	self.textUnitShortName:setText(data.unitShort)
	self.checkedUnitVolume:setState(data.isVolume and 2 or 1)

	self.textUnitFactor.lastValidText = ''
	self.textUnitFactor:setText(tostring(MathUtil.round(data.factor, 7)))

	local precisions = {}

	for i = 0, EditUnitDialog.MAX_PRECISION do
		table.insert(precisions, tostring(i))
		table.insert(self.precisionMapping, i)
	end

	self.optionUnitPrecision:setTexts(precisions)
	self.optionUnitPrecision:setState(data.precision + 1, true)

	self.isDefault = data.isDefault or false

	self.textUnitName:setDisabled(self.isDefault)
	self.textUnitShortName:setDisabled(self.isDefault)
	self.checkedUnitVolume:setDisabled(self.isDefault)
	self.textUnitFactor:setDisabled(self.isDefault)
	self.yesButton:setDisabled(true)
end

---Update buttons states
function EditUnitDialog:udpateButtons()
	local disabled = false

	if self.textUnitName.text == '' or self.textUnitShortName.text == '' then
		disabled = true
	end

	if self.textUnitFactor.text == '' then
		disabled = true
	end

	self.yesButton:setDisabled(disabled)
end

---Callback on name input text change
function EditUnitDialog:onTextChangedName()
	self:udpateButtons()
end

---Callback on short name input text change
function EditUnitDialog:onTextChangedShortName()
	self:udpateButtons()
end

---Callback on click volume
function EditUnitDialog:onClickVolume()
	self:udpateButtons()
end

---Callback on click precision
function EditUnitDialog:onClickPrecision()
	self:udpateButtons()
end

---Callback on factor input text change
---@param element table text input element object
---@param text string text input element input
function EditUnitDialog:onTextChangedFactor(element, text)
	if text ~= '' then
		if tonumber(text) ~= nil then
			element.lastValidText = text
		else
			element:setText(element.lastValidText)
		end
	else
		element.lastValidText = ''
	end

	self:udpateButtons()
end

---Send callback to caller
---@param unit table unit object
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

---Callback on click save
function EditUnitDialog:onClickSave()
	local unit = {
		id = self.id,
		name = self.textUnitName.text,
		unitShort = self.textUnitShortName.text,
		precision = self.precisionMapping[self.optionUnitPrecision.state],
		factor = tonumber(self.textUnitFactor.text),
		isVolume = self.checkedUnitVolume.state == 2 and true or false,
		isDefault = self.isDefault and true or nil
	}

	self:sendCallback(unit)
end

---Callback on click back
function EditUnitDialog:onClickBack()
	self:close()
end

---Callback on dialog close
function EditUnitDialog:onClose()
	EditUnitDialog:superClass().onClose(self)

	self.precisionMapping = {}
end

EditUnitDialog.NEW_UNIT_TEMPLATE = {
	name = '',
	unitShort = '',
	precision = 1,
	factor = 1,
	isVolume = true
}