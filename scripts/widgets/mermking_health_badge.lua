local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"

Assets = {
    Asset("ANIM", "anim/mermking_health_meter.zip"),
}

local MermKingBadge = Class(Badge, function(self, owner, combined_status)
	self.owner = owner
	self.comined_status = combined_status or false
	self.val = 0
	self.max = 0

	Badge._ctor(self, nil, owner, {0.6, 0, 0.6, 1}, "mermking_health_meter", nil, nil, true)

	self.sanityarrow = self.underNumber:AddChild(UIAnim())
	self.sanityarrow:GetAnimState():SetBank("sanity_arrow")
	self.sanityarrow:GetAnimState():SetBuild("sanity_arrow")
	self.sanityarrow:GetAnimState():PlayAnimation("neutral")
	self.sanityarrow:GetAnimState():AnimateWhilePaused(false)
	self.sanityarrow:SetClickable(false)
end)

function MermKingBadge:SetPercent(val, max)
	if val == nil then return end
	self.val = val
	self.max = max

	Badge.SetPercent(self, val / max, max)
	self.num:SetString(string.format("%d", val))
end

return MermKingBadge
