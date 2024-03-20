-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.0, 10|04|2023
-- @filename: ExpandSmoothListElement.lua

ExpandSmoothListElement = {}

local ExpandSmoothListElement_mt = Class(ExpandSmoothListElement, SmoothListElement)

function ExpandSmoothListElement.new(target)
  local self = SmoothListElement.new(target, ExpandSmoothListElement_mt)

  self.maxListHeight = 0
  self.layoutElement = nil
  self.layoutElementId = nil

  return self
end

function ExpandSmoothListElement:loadFromXML(xmlFile, key)
  ExpandSmoothListElement:superClass().loadFromXML(self, xmlFile, key)

  self.maxListHeight = unpack(GuiUtils.getNormalizedValues(getXMLString(xmlFile, key .. "#maxListHeight"), {
    self.outputSize[self.lengthAxis]
  }, {
    self.maxListHeight
  }))

  self.layoutElementId = getXMLString(xmlFile, key .. "#layoutElementId")
end

function ExpandSmoothListElement:copyAttributes(src)
  ExpandSmoothListElement:superClass().copyAttributes(self, src)

  self.maxListHeight = src.maxListHeight
  self.layoutElement = src.layoutElement
  self.layoutElementId = src.layoutElementId
end

function ExpandSmoothListElement:onGuiSetupFinished()
  ExpandSmoothListElement:superClass().onGuiSetupFinished(self)

  if self.layoutElementId ~= nil then
    if self.target[self.layoutElementId] ~= nil and self.target[self.layoutElementId].invalidateLayout ~= nil then
      self.layoutElement = self.target[self.layoutElementId]
    else
      print("Warning: DataElementId '" .. self.layoutElementId .. "' not found for '" .. self.target.name .. "'!")
    end
  elseif self.parent ~= nil and self.parent.invalidateLayout ~= nil then
    self.layoutElement = self.parent
  end
end

function ExpandSmoothListElement:buildSectionInfo()
  ExpandSmoothListElement:superClass().buildSectionInfo(self)

  local maxSize = self.contentSize

  if maxSize >= self.maxListHeight then
    maxSize = self.maxListHeight
  end

  if self.layoutElement ~= nil then
    self.absSize[self.lengthAxis] = maxSize

    self.layoutElement:invalidateLayout(false)

    self.absSize[self.lengthAxis] = maxSize
  end
end