local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"

-- 뱃지에 표시될 아이콘 애니메이션
Assets = {
    Asset("ANIM", "anim/mermking_hunger_meter.zip"),
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
	self.comined_status = combined_status or false 	-- combined_status 모드 적용체크
	self.val = 0									-- 현재 수치
	self.max = 0									-- 최대 수치

	-- Badge 초기화 (애니메이션 설정 및 뱃지 객체 생성)
	Badge._ctor(self, nil, owner, {0, 0.5, 0, 1}, "mermking_hunger_meter", nil, nil, true)

	self.hungerarrow = self.underNumber:AddChild(UIAnim())						-- 뱃지 내부의 수치증감으로 인한 화살표 표현
	self.hungerarrow:GetAnimState():SetBank("sanity_arrow")						-- 화살표 애니메이션의 표현을 위한 데이터 그룹
	self.hungerarrow:GetAnimState():SetBuild("sanity_arrow")					-- 화살표 애니메이션의 이미지 설정
	self.hungerarrow:GetAnimState():PlayAnimation("arrow_loop_decrease", true)	-- 화살표 애니메이션의 타입(방향) 설정
	self.hungerarrow:GetAnimState():AnimateWhilePaused(false)					-- 일시정지 상태에서 애니메이션의 출력여부
	self.hungerarrow:SetClickable(false)										-- 클릭 가능여부
end)

-- 뱃지 내부 화살표 방향전환을 위한 상태점검
-- 기본적으로 항상 감소하는 화살표를 출력하되, 허기수치가 0이되면 아무것도 출력하지 않음 
function MermKingBadge:ArrowUpdate()
	local anim = RATE_SCALE_ANIM[RATE_SCALE.DECREASE_LOW]
	
	if self.val == 0 then anim = "neutral" end

	if self.arrowdir ~= anim then
		self.arrowdir = anim
		self.hungerarrow:GetAnimState():PlayAnimation(anim, true)
	end
end

function MermKingBadge:SetPercent(val, max)
	if val == nil then return end
	self.val = val									-- 현재 수치 갱신
	self.max = max									-- 최대 수치 갱신

	Badge.SetPercent(self, val / max, max)			-- 뱃지에 게이지 관리를 위한 퍼센트 갱신
	self.num:SetString(string.format("%d", val))	-- 뱃지에 표기될 숫자(현재 수치) 갱신
end

return MermKingBadge
