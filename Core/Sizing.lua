---@class addonTablePlatynator
local addonTable = select(2, ...)

function addonTable.Utilities.GetRectFromRegion(region, scale, anchor, shouldScaleAnchor)
  local width = region.width * scale * addonTable.Assets.BarBordersSize.width
  local height = region.height * scale * addonTable.Assets.BarBordersSize.height
  local left, bottom
  if not shouldScaleAnchor then
    scale = 1
  end
  if anchor[1] == "BOTTOMLEFT" then
    left = anchor[2] and anchor[2] * scale or 0
    bottom = anchor[3] and anchor[3] * scale or 0
  elseif anchor[1] == "BOTTOM" then
    left = anchor[2] and anchor[2] * scale - width/2 or -width/2
    bottom = anchor[3] and anchor[3] * scale or 0
  elseif anchor[1] == "BOTTOMRIGHT" then
    left = anchor[2] and anchor[2] * scale - width or -width
    bottom = anchor[3] and anchor[3] * scale or 0
  elseif anchor[1] == "TOPLEFT" then
    left = anchor[2] and anchor[2] * scale or 0
    bottom = anchor[3] and anchor[3] * scale - height or -height
  elseif anchor[1] == "TOP" then
    left = anchor[2] and anchor[2] * scale - width/2 or -width/2
    bottom = anchor[3] and anchor[3] * scale - height or -height
  elseif anchor[1] == "TOPRIGHT" then
    left = anchor[2] and anchor[2] * scale - width or -width
    bottom = anchor[3] and anchor[3] * scale - height or -height
  elseif anchor[1] == "LEFT" then
    left = anchor[2] and anchor[2] * scale or 0
    bottom = anchor[3] and anchor[3] * scale - height/2 or -height/2
  elseif anchor[1] == "RIGHT" then
    left = anchor[2] and anchor[2] * scale - width or -width
    bottom = anchor[3] and anchor[3] * scale - height/2 or -height/2
  else
    left = -width / 2
    bottom = -height / 2
  end
  return {left = left, bottom = bottom, width = width, height = height}
end

function addonTable.Utilities.GenerateRects(design)
  local hit, stack
  local left, right, top, bottom

  local function CacheSize(rect)
    if left == nil then
      left = rect.left
      bottom = rect.bottom
      right = rect.left + rect.width
      top = rect.bottom + rect.height
    end
    left = math.min(left, rect.left)
    bottom = math.min(bottom, rect.bottom)
    top = math.max(rect.bottom + rect.height, top)
    right = math.max(rect.left + rect.width, right)
  end

  for _, barDetails in ipairs(design.bars) do
    if barDetails.kind == "health" or barDetails.kind == "cast" then
      local rect = addonTable.Utilities.GetRectFromRegion({width = barDetails.border.width, height = barDetails.border.height}, barDetails.scale, barDetails.anchor)
      CacheSize(rect)
    end
  end

  for _, specialBarDetails in ipairs(design.specialBars) do
    if specialBarDetails.kind == "healthFillText" then
      local rect = addonTable.Utilities.GetRectFromRegion({width = 0.7, height = 10/addonTable.Assets.BarBordersSize.height }, specialBarDetails.scale, specialBarDetails.anchor)
      CacheSize(rect)
    end
  end

  for _, textDetails in ipairs(design.texts) do
    if textDetails.kind == "creatureName" then
      local rect = addonTable.Utilities.GetRectFromRegion({width = textDetails.maxWidth, height = 11/addonTable.Assets.BarBordersSize.height * textDetails.scale}, 1, textDetails.anchor)
      CacheSize(rect)
    end
  end

  if left ~= nil then
    if left == right then
      right = addonTable.Assets.BarBordersSize.width / 2
      left = -right
    end
    if top == bottom then
      top = addonTable.Assets.BarBordersSize.height / 2
      bottom = -top
    end
    stack = {left = left, bottom = bottom, width = (right - left), height = (top - bottom)}
  else
    stack = {left = 0, bottom = 0, width = 0, height = 0}
  end
  hit = CopyTable(stack)

  return hit, stack
end

local function Round100(value)
  return Round(value * 100) / 100
end

function addonTable.Utilities.ConvertRectToWidget(rect)
  local width = Round100(rect.width / addonTable.Assets.BarBordersSize.width)
  local height = Round100(rect.height / addonTable.Assets.BarBordersSize.height)
  if Round100(-rect.left / addonTable.Assets.BarBordersSize.width * 2) == width and
    Round100(-rect.bottom / addonTable.Assets.BarBordersSize.height * 2) == height then
    return {
      width = width, height = height,
      anchor = {"CENTER"},
      autoSized = true,
    }
  else
    return {
      width = width, height = height,
      anchor = {"BOTTOMLEFT", rect.left, rect.bottom},
      autoSized = true,
    }
  end
end
