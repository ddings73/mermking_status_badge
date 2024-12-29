local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"

-- 뱃지에 표시될 아이콘 애니메이션
Assets = {
    Asset("ANIM", "anim/mermking_health_meter.zip"),
}

local MermKingBadge = Class(Badge, function(self, owner, combined_status)
	self.owner = owner
	self.comined_status = combined_status or false 	-- comined_status 모드 적용체크
	self.val = 0									-- 현재 수치
	self.max = 0									-- 최대 수치

	-- Badge 초기화 (애니메이션 설정 및 뱃지 객체 생성)
	Badge._ctor(self, nil, owner, {0.6, 0, 0.6, 1}, "mermking_health_meter", nil, nil, true)

	self.sanityarrow = self.underNumber:AddChild(UIAnim())		-- 뱃지 내부의 수치증감으로 인한 화살표 표현
	self.sanityarrow:GetAnimState():SetBank("sanity_arrow")		-- 화살표 애니메이션의 표현을 위한 데이터 그룹
	self.sanityarrow:GetAnimState():SetBuild("sanity_arrow")	-- 화살표 애니메이션의 이미지 설정
	self.sanityarrow:GetAnimState():PlayAnimation("neutral")	-- 화살표 애니메이션의 타입(방향) 설정
	self.sanityarrow:GetAnimState():AnimateWhilePaused(false)	-- 일시정지 상태에서 애니메이션의 출력여부
	self.sanityarrow:SetClickable(false)						-- 클릭 가능여부
end)

-- 뱃지의 게이지 표현을 위한 Percent 변경
function MermKingBadge:SetPercent(val, max)
	if val == nil then return end
	self.val = val
	self.max = max

	Badge.SetPercent(self, val / max, max)			-- 뱃지에 게이지 관리를 위한 퍼센트 갱신
	self.num:SetString(string.format("%d", val))	-- 뱃지에 표기될 숫자(현재 수치) 갱신
end

return MermKingBadge
