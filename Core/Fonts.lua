---@class addonTablePlatynator
local addonTable = select(2, ...)

local LSM = LibStub("LibSharedMedia-3.0")

local fonts = {}

function addonTable.Core.GetFontByDesign(design)
  local id = design.font.asset
  local outline = design.font.outline and "OUTLINE" or ""
  local shadow = design.font.shadow and "SHADOW" or ""
  local slug = ""
  if addonTable.Constants.IsRetail and (outline ~= "" or shadow == "") then
    slug = design.font.slug and "SLUG" or ""
  end
  local key = id:lower() .. outline .. shadow .. slug
  if not fonts[key] then
    addonTable.Core.CreateFont(id, outline, shadow, slug, false)
    if not fonts[key] and not fonts[addonTable.Constants.DefaultFont:lower() .. outline .. shadow .. slug] then
      addonTable.Core.CreateFont(addonTable.Constants.DefaultFont, outline, shadow, slug, true)
    end
  end
  return fonts[key] or fonts[addonTable.Constants.DefaultFont:lower() .. outline .. shadow .. slug]
end

function addonTable.Core.GetFontByID(id)
  local outline = ""
  local shadow = ""
  local slug = ""
  local key = id:lower() .. outline .. shadow .. slug
  if not fonts[key] then
    addonTable.Core.CreateFont(id, outline, shadow, slug, false)
    if not fonts[key] and not fonts[addonTable.Constants.DefaultFont:lower() .. outline .. shadow .. slug] then
      addonTable.Core.CreateFont(addonTable.Constants.DefaultFont, outline, shadow, slug, true)
    end
  end
  return fonts[key] or fonts[addonTable.Constants.DefaultFont:lower() .. outline .. shadow .. slug]
end

local alphabet = addonTable.Constants.FontFamilies

local locale = GetLocale()
local overrideAlphabet = "roman"
if locale == "koKR" then
  overrideAlphabet = "korean"
elseif locale == "zhCN" then
  overrideAlphabet = "simplifiedchinese"
elseif locale == "zhTW" then
  overrideAlphabet = "traditionalchinese"
elseif locale == "ruRU" then
  overrideAlphabet = "russian"
end

local function GetMembers(overrideFile, outline)
  local members = {}
  local coreFont = GameFontNormal
  for _, a in ipairs(alphabet) do
    local forAlphabet = coreFont:GetFontObjectForAlphabet(a)
    local file, size, _ = forAlphabet:GetFont()
    if a == overrideAlphabet then
      table.insert(members, {
        alphabet = a,
        file = overrideFile,
        height = size,
        flags = outline,
      })
    else
      table.insert(members, {
        alphabet = a,
        file = file,
        height = size,
        flags = outline,
      })
    end
  end

  return members
end

function addonTable.Core.CreateFont(assetKey, outline, shadow, slug, useDefault)
  local key = assetKey:lower() .. outline .. shadow .. slug
  if fonts[key] then
    error("duplicate font creation " .. key)
  end
  local globalName = "PlatynatorFont" .. key

  if addonTable.Constants.OldFontMapping[assetKey] then
    assetKey = addonTable.Constants.OldFontMapping[assetKey]
  end

  local path = LSM:Fetch(LSM.MediaType.FONT, assetKey, not useDefault)
  if not path then
    return
  end

  local flags = outline .. slug
  if outline ~= "" and slug ~= "" then
    flags = outline .. " " .. slug
  end
  local font = CreateFontFamily(globalName, GetMembers(path, flags))
  font:SetTextColor(1, 1, 1)
  fonts[key] = globalName

  local fontFamily = _G[globalName]

  if shadow == "SHADOW" then
    for _, a in ipairs(alphabet) do
      local font = fontFamily:GetFontObjectForAlphabet(a)
      font:SetShadowOffset(1, -1)
      font:SetShadowColor(0, 0, 0, 1)
    end
  end
end
