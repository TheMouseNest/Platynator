---@class addonTablePlatynator
local addonTable = select(2, ...)

local print = print
function addonTable.Utilities.Message(text)
  print("|cff96742a" .. addonTable.Locales.PLATYNATOR .. "|r: " .. text)
end

function addonTable.Utilities.InitFrameWithMixin(parent, mixin)
  local f = CreateFrame("Frame", nil, parent)
  Mixin(f, mixin)
  f:OnLoad()
  return f
end

function addonTable.Utilities.PurgeKey(t, k)
  t[k] = nil
  local c = 42
  repeat
    if t[c] == nil then
      t[c] = nil
    end
    c = c + 1
  until issecurevariable(t, k)
end

do
  local callbacksPending = {}
  local frame = CreateFrame("Frame")
  frame:RegisterEvent("ADDON_LOADED")
  frame:SetScript("OnEvent", function(_, _, addonName)
    if callbacksPending[addonName] then
      for _, cb in ipairs(callbacksPending[addonName]) do
        xpcall(cb, CallErrorHandler)
      end
      callbacksPending[addonName] = nil
    end
  end)

  local AddOnLoaded = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded

  -- Necessary because cannot nest EventUtil.ContinueOnAddOnLoaded
  function addonTable.Utilities.OnAddonLoaded(addonName, callback)
    if select(2, AddOnLoaded(addonName)) then
      xpcall(callback, CallErrorHandler)
    else
      callbacksPending[addonName] = callbacksPending[addonName] or {}
      table.insert(callbacksPending[addonName], callback)
    end
  end
end
