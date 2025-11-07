---@class addonTablePlatynator
local addonTable = select(2, ...)

local fonts = {}

function addonTable.Core.GetFontByDesign(design)
  local id = design.font.asset
  local outline = design.font.outline and "OUTLINE" or ""
  local shadow = design.font.shadow and "SHADOW" or ""
  local size = addonTable.Assets.Fonts[design.font.asset].size
  if not fonts[id .. outline .. shadow .. size] then
    addonTable.Core.CreateFont(id, size, outline, shadow)
  end
  return fonts[id .. outline .. shadow .. size]
end

function addonTable.Core.GetFontByID(id, size)
  local outline = ""
  local shadow = ""
  if not fonts[id .. outline .. shadow .. size] then
    addonTable.Core.CreateFont(id, size, outline, shadow)
  end
  return fonts[id .. outline .. shadow .. size]
end

local alphabet = {"roman", "korean", "simplifiedchinese", "traditionalchinese", "russian"}

local function GetDefaultMembers(size, outline)
  local members = {}
  local coreFont = ChatFontNormal
  for _, a in ipairs(alphabet) do
    local forAlphabet = coreFont:GetFontObjectForAlphabet(a)
    if forAlphabet then
      local file, _, flags = forAlphabet:GetFont()
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

function addonTable.Core.CreateFont(assetKey, size, outline, shadow)
  local key = assetKey .. outline .. shadow .. size
  if fonts[key] then
    error("duplicate font creation " .. key)
  end
  local globalName = "PlatynatorFont" .. key

  if addonTable.Constants.IsMidnight then
    outline = outline .. " SLUG"
  end

  local font = CreateFontFamily(globalName, GetDefaultMembers(size, outline))
  local path = addonTable.Assets.Fonts[assetKey].file
  font:SetFont(path, size, outline)
  font:SetTextColor(1, 1, 1)
  fonts[key] = globalName

  local fontFamily = _G[globalName]

  if shadow == "SHADOW" then
    for _, a in ipairs(alphabet) do
      local font = fontFamily:GetFontObjectForAlphabet(a)
      font:SetShadowOffset(1, -1)
      font:SetShadowColor(0, 0, 0, 0.8)
    end
  end
end
