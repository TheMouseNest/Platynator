---@class addonTablePlatynator
local addonTable = select(2, ...)

local function GetPixelToUIUnitFactor()
  local physicalWidth, physicalHeight = GetPhysicalScreenSize()
  return 768.0 / physicalHeight
end

local uiUnitFactor = GetPixelToUIUnitFactor()

local monitor = CreateFrame("Frame")
monitor:RegisterEvent("DISPLAY_SIZE_CHANGED")
monitor:RegisterEvent("PLAYER_ENTERING_WORLD")
monitor:SetScript("OnEvent", function()
  uiUnitFactor = GetPixelToUIUnitFactor()
end)

local function GetNearestPixelSize(uiUnitSize, layoutScale)
  if uiUnitSize == 0 then
    return 0
  end

  local numPixels = Round((uiUnitSize * layoutScale) / uiUnitFactor)
  return numPixels * uiUnitFactor / layoutScale
end

function addonTable.PixelPerfect.ConvertPixelsToUIForRegion(desiredPixels, region)
  return GetNearestPixelSize(desiredPixels, region:GetEffectiveScale())
end

function addonTable.PixelPerfect.SetSize(region, width, height)
  local scale = region:GetEffectiveScale()
  region:SetSize(GetNearestPixelSize(width, scale), GetNearestPixelSize(height, scale))
end

function addonTable.PixelPerfect.SetPoint(region, point, relativeTo, relativePoint, offsetX, offsetY)
  local scale = region:GetEffectiveScale()
  region:SetPoint(point, relativeTo, relativePoint,
    GetNearestPixelSize(offsetX, scale),
    GetNearestPixelSize(offsetY, scale)
  )
end
