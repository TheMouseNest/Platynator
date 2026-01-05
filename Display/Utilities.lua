---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.Utilities = {}

function addonTable.Display.Utilities.IsNeutralUnit(unit)
  if UnitSelectionType then
    return UnitSelectionType(unit) == 2
  else
    return UnitReaction(unit, "player") == 4
  end
end

function addonTable.Display.Utilities.IsUnfriendlyUnit(unit)
  if UnitSelectionType then
    return UnitSelectionType(unit) == 1
  else
    return UnitReaction(unit, "player") == 3
  end
end

function addonTable.Display.Utilities.IsTappedUnit(unit)
  return not UnitPlayerControlled(unit) and UnitIsTapDenied(unit)
end

function addonTable.Display.Utilities.GetUnitDifficulty(unit)
  if addonTable.Constants.IsRetail then
    local rawDifficulty = C_PlayerInfo.GetContentDifficultyCreatureForPlayer(unit)
    if rawDifficulty == Enum.RelativeContentDifficulty.Trivial then
      return  "trivial"
    elseif rawDifficulty == Enum.RelativeContentDifficulty.Easy then
      return "standard"
    elseif rawDifficulty == Enum.RelativeContentDifficulty.Fair then
      return "difficult"
    elseif rawDifficulty == Enum.RelativeContentDifficulty.Difficult then
      return "verydifficult"
    elseif rawDifficulty == Enum.RelativeContentDifficulty.Impossible then
      return "impossible"
    else
      return "difficult"
    end
  else
    local levelDiff = UnitLevel(unit) - UnitEffectiveLevel("player");
    if levelDiff >= 5 then
      return "impossible"
    elseif levelDiff >= 3 then
      return "verydifficult"
    elseif levelDiff >= -2 then
      return "difficult"
    elseif -levelDiff <= GetQuestGreenRange() then
      return "standard"
    else
      return  "trivial"
    end
  end
end

function addonTable.Display.Utilities.ConvertColor(color)
  return CreateColor(color.r, color.g, color.b, color.a)
end

function addonTable.Display.Utilities.IsInRelevantInstance()
  if not IsInInstance() then
    return false
  end
  local _, instanceType = GetInstanceInfo()
  return instanceType == "raid" or instanceType == "party" or instanceType == "arenas"
end

function addonTable.Display.UpdateTextureFlip(texture, flipHorizontal, minU, maxU, minV, maxV)
  local ULx, ULy, LLx, LLy, URx, URy, LRx, LRy
  
  if minU then
    ULx, ULy = minU, minV
    LLx, LLy = minU, maxV
    URx, URy = maxU, minV
    LRx, LRy = maxU, maxV
  else
    ULx, ULy, LLx, LLy, URx, URy, LRx, LRy = texture:GetTexCoord()
  end
  
  local left = math.min(ULx, LLx, URx, LRx)
  local right = math.max(ULx, LLx, URx, LRx)
  if flipHorizontal then
     ULx, LLx = right, right
     URx, LRx = left, left
  else
     ULx, LLx = left, left
     URx, LRx = right, right
  end
  
  texture:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy)
end
