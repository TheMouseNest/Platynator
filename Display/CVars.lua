---@class addonTablePlatynator
local addonTable = select(2, ...)

local cvars = {
  ["nameplateGlobalScale"] = "1",
  ["NamePlateHorizontalScale"] = "1",
  ["NamePlateVerticalScale"] = "1",
  ["nameplateLargeBottomInset"] = "0.15",
  ["nameplateLargerScale"] = "1",
  ["nameplateMaxAlpha"] = "1",
  ["nameplateMaxAlphaDistance"] = "40",
  ["nameplateMinAlpha"] = "0.6",
  ["nameplateMinAlphaDistance"] = "-100000",
  ["nameplateMaxDistance"] = "60",
  ["nameplateMaxScale"] = "1",
  ["nameplateMinScale"] = "1",
  ["nameplateMotionSpeed"] = "0.025",
  ["nameplatePlayerLargerScale"] = "1",
  ["nameplateTargetBehindMaxDistance"] = "30",
  ["nameplateTargetRadialPosition"] = "1",
  ["clampTargetNameplateToScreen"] = "1",
}

if addonTable.Constants.IsRetail then
  cvars["nameplateOverlapH"] = "1"
  cvars["nameplateOverlapV"] = "1"
end

function addonTable.Display.SetCVars()
  if not addonTable.Config.Get(addonTable.Config.Options.APPLY_CVARS) then
    return
  end
  for name, value in pairs(cvars) do
    if C_CVar.GetCVarInfo(name) then
      C_CVar.SetCVar(name, value)
    end
  end
end
