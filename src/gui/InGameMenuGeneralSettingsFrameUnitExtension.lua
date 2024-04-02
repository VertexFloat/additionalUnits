-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.0, 13|04|2023
-- @filename: InGameMenuGeneralSettingsFrameUnitExtension.lua

InGameMenuGeneralSettingsFrameUnitExtension = {
  BUTTON_PROFILE = "additionalUnitsOpenMenuButton"
}

local InGameMenuGeneralSettingsFrameUnitExtension_mt = Class(InGameMenuGeneralSettingsFrameUnitExtension)

function InGameMenuGeneralSettingsFrameUnitExtension.new(customMt, gui, i18n)
  local self = setmetatable({}, customMt or InGameMenuGeneralSettingsFrameUnitExtension_mt)

  self.gui = gui
  self.i18n = i18n

  self.isCreated = false

  return self
end

function InGameMenuGeneralSettingsFrameUnitExtension:initialize()
  local oldFunc = InGameMenuGeneralSettingsFrame.onFrameOpen
  local newFunc = function(superFunc, frame)
    superFunc(frame)

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

      buttonFrame.elements[1]:setText(self.i18n:getText("ui_additionalUnits_title"))
      buttonFrame.elements[2]:setText(self.i18n:getText("ui_additionalUnits_toolTip"))

      buttonFrame.elements[3]:setText(self.i18n:getText("input_MENU"))
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
  end

  InGameMenuGeneralSettingsFrame.onFrameOpen = function(...)
    return newFunc(oldFunc, ...)
  end
end