-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.0, 13|04|2023
-- @filename: InGameMenuGeneralSettingsFrameUnitExtension.lua

InGameMenuGeneralSettingsFrameUnitExtension = {
  BUTTON_PROFILE = "additionalUnitsOpenMenuButton"
}

local InGameMenuGeneralSettingsFrameUnitExtension_mt = Class(InGameMenuGeneralSettingsFrameUnitExtension)

---Creating InGameMenuGeneralSettingsFrameUnitExtension instance
---@param additionalUnits table additionalUnits object
---@param gui table gui object
---@param l10n table l10n object
---@return table instance instance of object
function InGameMenuGeneralSettingsFrameUnitExtension.new(customMt, additionalUnits, gui, l10n)
  local self = setmetatable({}, customMt or InGameMenuGeneralSettingsFrameUnitExtension_mt)

  self.additionalUnits = additionalUnits
  self.gui = gui
  self.l10n = l10n
  self.isCreated = false

  return self
end

---Initializing InGameMenuGeneralSettingsFrameUnitExtension
function InGameMenuGeneralSettingsFrameUnitExtension:initialize()
  self.additionalUnits:overwriteGameFunction(InGameMenuGeneralSettingsFrame, "onFrameOpen", function (superFunc, frame, element)
    superFunc(frame, element)

    if not self.isCreated then
      local pageSettingsGame = g_currentMission.inGameMenu.pageSettingsGame
      local button = pageSettingsGame.buttonPauseGame:clone(pageSettingsGame.boxLayout)

      button.onClickCallback = function (_, ...)
        self.gui:showGui("AdditionalUnitsMenu")
      end

      if button.parent ~= nil then
        button.parent:removeElement(button)
      end

      local buttonFrame = frame.checkUseEasyArmControl:clone(frame.boxLayout)

      buttonFrame:removeElement(buttonFrame.elements[1])
      buttonFrame:removeElement(buttonFrame.elements[1])
      buttonFrame:removeElement(buttonFrame.elements[1])
      buttonFrame:removeElement(buttonFrame.elements[2])

      buttonFrame:addElement(button)

      buttonFrame.elements[1]:setText(self.l10n:getText("ui_additionalUnits_title"))
      buttonFrame.elements[2]:setText(self.l10n:getText("toolTip_additionalUnits_menu"))

      buttonFrame.elements[3]:setText(self.l10n:getText("input_MENU"))
      buttonFrame.elements[3]:applyProfile(InGameMenuGeneralSettingsFrameUnitExtension.BUTTON_PROFILE)

      if buttonFrame.parent ~= nil then
        buttonFrame.parent:removeElement(buttonFrame)
      end

      local index = #frame.checkUseAcre.parent.elements + 1

      for i = 1, #frame.checkUseAcre.parent.elements do
        if frame.checkUseAcre.parent.elements[i] == frame.checkUseAcre then
          index = i + 1

          break
        end
      end

      table.insert(frame.checkUseAcre.parent.elements, index, buttonFrame)

      buttonFrame.parent = frame.checkUseAcre.parent

      frame.boxLayout:invalidateLayout()

      self.isCreated = true
    end
  end)
end