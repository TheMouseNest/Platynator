---@class addonTablePlatynator
local addonTable = select(2, ...)

function addonTable.Utilities.GetAssetRect(asset, scale, anchor)
  local width = asset.width * scale
  local height = asset.height * scale
  local left, bottom
  if anchor[1] == "BOTTOMLEFT" then
    left = anchor[2] or 0
    bottom = anchor[3] or 0
  elseif anchor[1] == "BOTTOM" then
    left = anchor[2] and anchor[2] - width/2 or -width/2
    bottom = anchor[3] or 0
  elseif anchor[1] == "BOTTOMRIGHT" then
    left = anchor[2] and anchor[2] - width or -width
    bottom = anchor[3] or 0
  elseif anchor[1] == "TOPLEFT" then
    left = anchor[2] or 0
    bottom = anchor[3] and anchor[3] - height or -height
  elseif anchor[1] == "TOP" then
    left = anchor[2] and anchor[2] - width/2 or -width/2
    bottom = anchor[3] and anchor[3] - height or -height
  elseif anchor[1] == "TOPRIGHT" then
    left = anchor[2] and anchor[2] - width or -width
    bottom = anchor[3] and anchor[3] - height or -height
  elseif anchor[1] == "LEFT" then
    left = anchor[2] or 0
    bottom = anchor[3] and anchor[3] - height/2 or -height/2
  elseif anchor[1] == "RIGHT" then
    left = anchor[2] and anchor[2] - width or -width
    bottom = anchor[3] and anchor[3] - height/2 or -height/2
  else
    left = -width / 2
    bottom = -height / 2
  end
  return {left = left, bottom = bottom, width = width, height = height}
end

function addonTable.Core.GetDesignRects(design)
  local left, right, top, bottom = 0, 0, 0, 0

  local function CacheSize(rect)
    left = math.min(left, rect.left)
    bottom = math.min(bottom, rect.bottom)
    top = math.max(rect.bottom + rect.height, top)
    right = math.max(rect.left + rect.width, right)
  end

  for _, barDetails in ipairs(design.bars) do
    if barDetails.kind == "health" then
      local width, height = barDetails.border.width * addonTable.Assets.BarBordersSize.width, barDetails.border.height * addonTable.Assets.BarBordersSize.height
      local rect = addonTable.Utilities.GetAssetRect({width = width, height = height}, barDetails.scale, barDetails.anchor)
      CacheSize(rect)
    end
  end

  local clickRect = {left = left * design.scale, bottom = bottom * design.scale, width = (right ~= left and right - left or 125) * design.scale, height = (top ~= bottom and top - bottom or 10) * design.scale}

  for _, textDetails in ipairs(design.texts) do
    if textDetails.kind == "creatureName" then
      local rect = addonTable.Utilities.GetAssetRect({width = textDetails.maxWidth * addonTable.Assets.BarBordersSize.width, height = 10 * textDetails.scale}, 1, textDetails.anchor)
      CacheSize(rect)
    end
  end

  local stackRect = {left = left * design.scale, bottom = bottom * design.scale, width = (right ~= left and right - left or 125) * design.scale, height = (top ~= bottom and top - bottom or 10) * design.scale}

  return {click = clickRect, stack = stackRect}
end
