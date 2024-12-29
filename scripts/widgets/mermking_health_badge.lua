local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"

-- 뱃지에 표시될 아이콘 애니메이션
Assets = {
    Asset("ANIM", "anim/mermking_health_meter.zip"),
}

-- 화살표 출력에 사용될 애니메이션 목록
local RATE_SCALE_ANIM =
{
    [RATE_SCALE.INCREASE_HIGH] = "arrow_loop_increase_most",
    [RATE_SCALE.INCREASE_MED] = "arrow_loop_increase_more",
    [RATE_SCALE.INCREASE_LOW] = "arrow_loop_increase",
    [RATE_SCALE.DECREASE_HIGH] = "arrow_loop_decrease_most",
    [RATE_SCALE.DECREASE_MED] = "arrow_loop_decrease_more",
    [RATE_SCALE.DECREASE_LOW] = "arrow_loop_decrease",
}

local MermKingBadge = Class(Badge, function(self, owner, combined_status)
	self.owner = owner
	self.comined_status = combined_status or false 	-- comined_status 모드 적용체크
	self.val = 0									-- 현재 수치
	self.max = 0									-- 최대 수치

	-- Badge 초기화 (애니메이션 설정 및 뱃지 객체 생성)
	Badge._ctor(self, nil, owner, {0.6, 0, 0.6, 1}, "mermking_health_meter", nil, nil, true)

	self.healtharrow = self.underNumber:AddChild(UIAnim())		-- 뱃지 내부의 수치증감으로 인한 화살표 표현
	self.healtharrow:GetAnimState():SetBank("sanity_arrow")		-- 화살표 애니메이션의 표현을 위한 데이터 그룹
	self.healtharrow:GetAnimState():SetBuild("sanity_arrow")	-- 화살표 애니메이션의 이미지 설정
	self.healtharrow:GetAnimState():PlayAnimation("neutral")	-- 화살표 애니메이션의 타입(방향) 설정
	self.healtharrow:GetAnimState():AnimateWhilePaused(false)	-- 일시정지 상태에서 애니메이션의 출력여부
	self.healtharrow:SetClickable(false)						-- 클릭 가능여부
end)

-- 뱃지 내부 화살표 방향전환을 위한 상태점검
function MermKingBadge:ArrowUpdate(starve, regen)
	local anim = "neutral"

	if starve then			-- 허기가 0인 경우, 아래로 향하는 화살표 출력
		anim = RATE_SCALE_ANIM[RATE_SCALE.DECREASE_MED]
	elseif regen then 		-- 허기가 0 이상이고, 체력이 감소된 경우, 위로 향하는 화살표 출력
		anim = RATE_SCALE_ANIM[RATE_SCALE.INCREASE_MED]
	end

	if self.arrowdir ~= anim then
		self.arrowdir = anim
		self.healtharrow:GetAnimState():PlayAnimation(anim, true)
	end
end

-- 뱃지의 게이지 표현을 위한 Percent 변경
function MermKingBadge:SetPercent(val, max)
	if val == nil then return end
	self.val = val
	self.max = max

	Badge.SetPercent(self, val / max, max)			-- 뱃지에 게이지 관리를 위한 퍼센트 갱신
	self.num:SetString(string.format("%d", val))	-- 뱃지에 표기될 숫자(현재 수치) 갱신
end

return MermKingBadge
