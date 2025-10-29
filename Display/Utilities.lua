---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.Utilities = {}

function addonTable.Display.Utilities.IsNeutralUnit(unit)
  if UnitSelectionType then
    return UnitSelectionType(unit) == 2
  else
    local r, g, b = UnitSelectionColor(unit)
    return r == 1 and g == 1 and b == 0
  end
end
