---@class addonTablePlatynator
local addonTable = select(2, ...)

function addonTable.Utilities.Message(text)
  print("|cff96742a" .. addonTable.Locales.PLATYNATOR .. "|r: " .. text)
end

function addonTable.Utilities.InitFrameWithMixin(parent, mixin)
  local f = CreateFrame("Frame", nil, parent)
  Mixin(f, mixin)
  f:OnLoad()
  return f
end
