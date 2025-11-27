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
