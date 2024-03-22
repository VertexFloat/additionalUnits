-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.0, 05|04|2023
-- @filename: AdditionalUnitsGui.lua

AdditionalUnitsGui = {
  MOD_DIRECTORY = g_currentModDirectory
}

source(AdditionalUnitsGui.MOD_DIRECTORY .. "src/gui/AdditionalUnitsMenu.lua")
source(AdditionalUnitsGui.MOD_DIRECTORY .. "src/gui/dialogs/EditUnitDialog.lua")
source(AdditionalUnitsGui.MOD_DIRECTORY .. "src/gui/dialogs/EditFillTypeUnitDialog.lua")
source(AdditionalUnitsGui.MOD_DIRECTORY .. "src/gui/elements/ExpandSmoothListElement.lua")
source(AdditionalUnitsGui.MOD_DIRECTORY .. "src/gui/InGameMenuGeneralSettingsFrameUnitExtension.lua")

local AdditionalUnitsGui_mt = Class(AdditionalUnitsGui)

function AdditionalUnitsGui.new(customMt, additionalUnits, gui, l10n, fillTypeManager)
  local self = setmetatable({}, customMt or AdditionalUnitsGui_mt)

  self.gui = gui

  self.editUnitDialog = EditUnitDialog.new(nil, customMt, additionalUnits, l10n)
  self.editFillTypeUnitDialog = EditFillTypeUnitDialog.new(nil, customMt, additionalUnits, l10n)
  self.additionalUnitsMenu = AdditionalUnitsMenu.new(nil, customMt, additionalUnits, gui, l10n, fillTypeManager)
  self.inGameMenuGeneralSettingsFrameUnitExtension = InGameMenuGeneralSettingsFrameUnitExtension.new(customMt, additionalUnits, gui, l10n)

  return self
end

function AdditionalUnitsGui:initialize()
  self.gui:loadProfiles(AdditionalUnitsGui.MOD_DIRECTORY .. "data/gui/guiProfiles.xml")

  local mapping = Gui.CONFIGURATION_CLASS_MAPPING
  mapping.expandSmoothList = ExpandSmoothListElement

  self.inGameMenuGeneralSettingsFrameUnitExtension:initialize()
end

function AdditionalUnitsGui:loadMap()
  self.gui:loadGui(Utils.getFilename("data/gui/AdditionalUnitsMenu.xml", AdditionalUnitsGui.MOD_DIRECTORY), "AdditionalUnitsMenu", self.additionalUnitsMenu)
  self.gui:loadGui(Utils.getFilename("data/gui/dialogs/EditUnitDialog.xml", AdditionalUnitsGui.MOD_DIRECTORY), "EditUnitDialog", self.editUnitDialog)
  self.gui:loadGui(Utils.getFilename("data/gui/dialogs/EditFillTypeUnitDialog.xml", AdditionalUnitsGui.MOD_DIRECTORY), "EditFillTypeUnitDialog", self.editFillTypeUnitDialog)
end

function AdditionalUnitsGui:showEditUnitDialog(args)
  local dialog = self.gui:showDialog("EditUnitDialog")

  if dialog ~= nil and args ~= nil then
    dialog.target:setData(args.data)
    dialog.target:setCallback(args.callback, args.target, args.args)
  end
end

function AdditionalUnitsGui:showEditFillTypeUnitDialog(args)
  local dialog = self.gui:showDialog("EditFillTypeUnitDialog")

  if dialog ~= nil and args ~= nil then
    dialog.target:setData(args.data)
    dialog.target:setCallback(args.callback, args.target, args.args)
  end
end