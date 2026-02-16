---@class addonTablePlatynator
local addonTable = select(2, ...)
addonTable.Locales = CopyTable(PLATYNATOR_LOCALES.enUS)
for key, translation in pairs(PLATYNATOR_LOCALES[GetLocale()]) do
  addonTable.Locales[key] = translation
end
for key, translation in pairs(addonTable.Locales) do
  if key:match("^BINDING") then
    _G["BINDING_NAME_" .. key:match("BINDING_(.*)")] = translation
  end
end
