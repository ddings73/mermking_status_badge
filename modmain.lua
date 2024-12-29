local MermKingHungerBadge = require "widgets/mermking_hunger_badge"
local MermKingHealthBadge = require "widgets/mermking_health_badge"

local hungerbadge = nil
local healthbadge = nil
local player_inst = nil
local MERM_ONLY = GetModConfigData("MERM_ONLY") -- modinfo.lua의 옵션 값

-- 인게임 아이콘 표시를 위한 애니메이션 파일 추가
Assets = {
    Asset("ANIM", "anim/mermking_hunger_meter.zip"),
    Asset("ANIM", "anim/mermking_health_meter.zip")
}

-- 확인이 필요한 모드 목록
local CHECK_MODS = {
    ["workshop-376333686"] = "COMBINED_STATUS",
    ["CombinedStatus"] = "COMBINED_STATUS",
}

-- 플레이어가 활성화한 모드 리스트 확인
local HAS_MOD = {}
-- 로드된 모드 목록 확인
for mod_name, key in pairs(CHECK_MODS) do
    HAS_MOD[key] = HAS_MOD[key] or (GLOBAL.KnownModIndex:IsModEnabled(mod_name) and mod_name)
end
-- 로드되지 않은 모드 목록 확인
for k, v in pairs(GLOBAL.KnownModIndex:GetModsToLoad()) do
    local mod_type = CHECK_MODS[v]
    if mod_type then
        HAS_MOD[mod_type] = v
    end
end

-- 어인왕 허기 상승 효과
local function hungerIncrease()
    hungerbadge:PulseGreen()
    GLOBAL.TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/hunger_up")
end

-- 어인왕 체력 감소 효과
local function healthDecrease()
    healthbadge:PulseRed()
    GLOBAL.TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/helath_down") 
end

-- 플레이어 HUD 상태 표현 클래스 확장 
-- self는 출력 시, Status 객체로 표현됨
AddClassPostConstruct("widgets/statusdisplays", function(self)
    if not self.owner then return end
    
    -- 뱃지 객체 생성 및 위치설정
	self.hungerbadge = self:AddChild(MermKingHungerBadge(self.owner, HAS_MOD.COMBINED_STATUS))
	self.hungerbadge:SetPosition(-120,20)
    
    self.healthbadge = self:AddChild(MermKingHealthBadge(self.owner, HAS_MOD.COMBINED_STATUS))
    self.healthbadge:SetPosition(-200,20)

    -- 외부에서 badge 객체에 접근하기 위해 상위 scope에 저장
    -- 설정하지 않으면, 이후 시점에서 접근 불가 
    hungerbadge = self.hungerbadge;
    healthbadge = self.healthbadge;

    -- 내부에서 뱃지표현에 사용할 변수 생성
    self.max_hunger = TUNING.MERM_KING_HUNGER
    self.last_hunger = 0
    self.current_hunger = 0

    self.last_health = 0
    self.current_health = 0
    self.health_regen = false
    
    -- 매 프레임마다 반복하여 작업을 수행하는 entity 생성
    local entity = GLOBAL.CreateEntity()
    entity:DoPeriodicTask(0, function()
        if GLOBAL.ThePlayer ~= nil then 

            -- 현재 프레임의 상태 값 반영
            self.max_hunger = GLOBAL.ThePlayer.player_classified.mermking_hunger_max
            self.current_hunger = GLOBAL.ThePlayer.player_classified.mermking_hunger_current
            self.health_regen = GLOBAL.ThePlayer.player_classified.mermking_health_regen
            self.current_health = GLOBAL.ThePlayer.player_classified.mermking_health_current

            -- 뱃지 출력을 위한 조건 검증
            if self.current_health > 0 and (not MERM_ONLY or GLOBAL.ThePlayer.prefab == "wurt" or GLOBAL.ThePlayer.player_classified.equipped_hat == "mermhat") then
                self.healthbadge:Show()
                self.hungerbadge:Show()

                -- 뱃지 수치 갱신 및 효과 출력
                self.hungerbadge:SetPercent(self.current_hunger, self.max_hunger)
                self.hungerbadge:ArrowUpdate()
                if self.last_hunger ~= nil and self.current_hunger ~= nil and self.current_hunger > self.last_hunger then
                    hungerIncrease()
                end


                self.healthbadge:SetPercent(self.current_health, TUNING.MERM_KING_HEALTH)
                self.healthbadge:ArrowUpdate(self.current_hunger == 0, self.current_health < TUNING.MERM_KING_HEALTH and self.health_regen)
                if self.last_health ~= nil and self.current_health ~= nil and 
                    self.current_health < self.last_health and self.current_hunger > 0 then
                    healthDecrease()
                end

                -- combined status 모드에 따른 UI 수정
                if HAS_MOD.COMBINED_STATUS then
                    -- 뱃지 위치 및 크기 조정
                    local Text = require("widgets/text")
                    self.hungerbadge:SetPosition(-124, 35)
                    self.hungerbadge.rate = self.hungerbadge:AddChild(Text(GLOBAL.NUMBERFONT, 28))
                    self.hungerbadge.rate:SetPosition(2, -40.5, 0)
                    self.hungerbadge.rate:SetScale(1,.78,1)
                    self.hungerbadge.rate:Hide()

                    self.healthbadge:SetPosition(-186, 35)
                    self.healthbadge.rate = self.healthbadge:AddChild(Text(GLOBAL.NUMBERFONT, 28))
                    self.healthbadge.rate:SetPosition(2, -40.5, 0)
                    self.healthbadge.rate:SetScale(1,.78,1)
                    self.healthbadge.rate:Hide()
                else
                    -- 뱃지 내 수치표현에 사용되는 텍스트 설정 수정
                    self.hungerbadge.num:SetSize(25)
                    self.hungerbadge.num:SetScale(1,.9,1)
                    self.hungerbadge.num:SetPosition(3, 3)

                    self.healthbadge.num:SetSize(25)
                    self.healthbadge.num:SetScale(1,.9,1)
                    self.healthbadge.num:SetPosition(3, 3)
                end
                
                -- 다음 task에서 수치 증감을 확인하기 위해 현재 값 저장
                self.last_hunger = self.current_hunger
                self.last_health = self.current_health
            else 
                self.healthbadge:Hide()
                self.hungerbadge:Hide()
            end
        end
    end)
end)

-- player_classified prefab 확장
AddPrefabPostInit("player_classified", function(inst)
    player_inst = inst  -- shard간 RPC통신 시점에서 접근하기 위해 외부 scope에 inst 저장
    
    -- 어인왕의 현재 허기수치 관리를 위한 변수 및 네트워크 변수 추가
    if MERM_ONLY then
        inst.equipped_hat = ""
        inst.net_equipped_hat = GLOBAL.net_string(inst.GUID, "equipped_hat", "equipped_hat_dirty")

        inst:ListenForEvent("equipped_hat_dirty", function(inst)
            inst.equipped_hat = inst.net_equipped_hat:value()
        end)
    end 

    inst.mermking_hunger_max = TUNING.MERM_KING_HUNGER
    inst.net_mermking_hunger_max = GLOBAL.net_int(inst.GUID, "mermking_hunger_max", "mermking_hunger_max_dirty")
    inst:ListenForEvent("mermking_hunger_max_dirty", function(inst)
        inst.mermking_hunger_max = inst.net_mermking_hunger_max:value()
    end)

    inst.mermking_hunger_current = 0
    inst.net_mermking_hunger_current = GLOBAL.net_float(inst.GUID, "mermking_hunger_current", "mermking_hunger_current_dirty")
    inst:ListenForEvent("mermking_hunger_current_dirty", function(inst)
        inst.mermking_hunger_current = inst.net_mermking_hunger_current:value()
    end)

    inst.mermking_health_regen = false
    inst.net_mermking_health_regen = GLOBAL.net_bool(inst.GUID, "mermking_health_regen", "mermking_health_regen_dirty")
    inst:ListenForEvent("mermking_health_regen_dirty", function(inst)
        inst.mermking_health_regen = inst.net_mermking_health_regen:value()
    end)
    
    inst.mermking_health_current = 0
    inst.net_mermking_health_current = GLOBAL.net_float(inst.GUID, "mermking_health_current", "mermking_health_current_dirty")
    inst:ListenForEvent("mermking_health_current_dirty", function(inst)
        inst.mermking_health_current = inst.net_mermking_health_current:value()
    end)

    -- 프레임마다 mermkingmanager의 상태값으로 네트워크 변수를 갱신
    inst:DoPeriodicTask(0, function()
        local mermkingmanager = GLOBAL.TheWorld.components.mermkingmanager
        if mermkingmanager ~= nil then
            
            -- 현재 플레이어 Shard와 어인왕의 Shard가 동일한 위치인지 확인하여 분기
            if mermkingmanager:HasKingLocal() then
                local king = mermkingmanager:GetKing()
                inst.net_mermking_hunger_max:set(king.components.hunger.max)
                inst.net_mermking_hunger_current:set(king.components.hunger.current) 
                inst.net_mermking_health_regen:set(king.components.health.regen ~= nil)
                inst.net_mermking_health_current:set(king.components.health.currenthealth)
            elseif mermkingmanager:HasKingAnywhere() then
                -- 반대쪽 Shard(동굴 or 지상)로 시그널 전달
                -- 두번째 인자가 nil인 경우, 연결된 모든 Shard로 요청을 전송
                SendModRPCToShard(GetShardModRPC(modname, "mermking_update"), nil, nil, nil, nil, nil) 
            else
                -- 어인왕이 존재하지 않을 경우, 기본값으로 초기화
                inst.net_mermking_hunger_max:set(TUNING.MERM_KING_HUNGER)
                inst.net_mermking_hunger_current:set(0)
                inst.net_mermking_health_regen:set(false)
                inst.net_mermking_health_current:set(0)
            end
        end
    end)
end)

-- shard(동굴, 지상) 간 데이터 교환을 위한 원격 프로시저 핸들러
-- RPC 시그널을 생성한 Shard와 동일한지 확인하고, 상태값의 유무에 따라 수행할 동작 분기
-- shardId는 RPC 요청을 생성한 Shard를 의미
AddShardModRPCHandler(modname, "mermking_update", function(shardId, hunger_max, hunger_current, health_regen, health_current)
    if GLOBAL.TheShard:GetShardId() ~= tostring(shardId) then
        if hunger_max ~= nil and hunger_current ~= nil and health_regen ~= nil and health_current ~= nil then
            player_inst.net_mermking_hunger_max:set(hunger_max)
            player_inst.net_mermking_hunger_current:set(hunger_current)
            player_inst.net_mermking_health_regen:set(health_regen)
            player_inst.net_mermking_health_current:set(health_current)
        else
            local king = GLOBAL.TheWorld.components.mermkingmanager:GetKing()
            GLOBAL.TheWorld:DoTaskInTime(0, function()
                SendModRPCToShard(GetShardModRPC(modname, "mermking_update"), shardId, 
                    king.components.hunger.max, 
                    king.components.hunger.current, 
                    king.components.health.regen ~= nil, 
                    king.components.health.currenthealth
                )
            end) 
        end
    end
end)

-- 플레이어의 모자슬롯 아이템 확인을 위해 플레이어가 생성된 후에 수행할 작업 확장
AddPlayerPostInit(function(inst)
    if MERM_ONLY then
        -- 플레이어가 서버에 접속했을 경우
        GLOBAL.TheWorld:ListenForEvent("ms_playerjoined", function(self)
            local hat = inst.components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HEAD)
            if hat ~= nil then 
                inst.player_classified.net_equipped_hat:set(hat.prefab) 
            end
        end)

        -- 플레이어가 장비를 착용했을 경우
        inst:ListenForEvent("equip", function(owner, data)
            if data.item ~= nil then
                local equipslot = data.item.replica.equippable:EquipSlot()
                if equipslot == "head" then
                    owner.player_classified.net_equipped_hat:set(data.item.prefab)
                end
            end
        end)

        -- 플레이어가 장비를 해제했을 경우
        inst:ListenForEvent("unequip", function(owner, data)
            if data.item ~= nil then
                local equipslot = data.item.replica.equippable:EquipSlot()
                if equipslot == "head" then
                    owner.player_classified.net_equipped_hat:set("")
                end
            end
        end)
    end
end)