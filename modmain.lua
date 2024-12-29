local MermKingHungerBadge = require "widgets/mermking_hunger_badge"
local MermKingHealthBadge = require "widgets/mermking_health_badge"

local hungerbadge = nil
local healthbadge = nil
local king = nil
local player_inst = nil
local VISIBLEOPTION = GetModConfigData("VISIBLEOPTION")

Assets = {
    Asset("ANIM", "anim/mermking_hunger_meter.zip"),
    Asset("ANIM", "anim/mermking_health_meter.zip")
}

local CHECK_MODS = {
    ["workshop-376333686"] = "COMBINED_STATUS",
    ["CombinedStatus"] = "COMBINED_STATUS",
}

local HAS_MOD = {}
--If the mod is already loaded at this point
for mod_name, key in pairs(CHECK_MODS) do
    HAS_MOD[key] = HAS_MOD[key] or (GLOBAL.KnownModIndex:IsModEnabled(mod_name) and mod_name)
end
--If the mod hasn't loaded yet
for k, v in pairs(GLOBAL.KnownModIndex:GetModsToLoad()) do
    local mod_type = CHECK_MODS[v]
    if mod_type then
        HAS_MOD[mod_type] = v
    end
end

local function hungerIncrease()
    hungerbadge:PulseGreen()
    GLOBAL.TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/hunger_up")
end

local function healthDecrease()
    healthbadge:PulseRed()
    GLOBAL.TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/helath_down") 
end

AddClassPostConstruct("widgets/statusdisplays", function(self)
    if not self.owner then return end
    
	self.hungerbadge = self:AddChild(MermKingHungerBadge(self.owner, HAS_MOD.COMBINED_STATUS))
	self.hungerbadge:SetPosition(-120,20)
    
    self.healthbadge = self:AddChild(MermKingHealthBadge(self.owner, HAS_MOD.COMBINED_STATUS))
    self.healthbadge:SetPosition(-200,20)

    hungerbadge = self.hungerbadge;
    healthbadge = self.healthbadge;

    self.last_hunger = 0
    self.current_hunger = 0
    self.max_hunger = TUNING.MERM_KING_HUNGER

    self.last_health = 0
    self.current_health = 0
    
    local entity = GLOBAL.CreateEntity()
    entity:DoPeriodicTask(0, function()
        if GLOBAL.ThePlayer ~= nil then 
            self.current_hunger = GLOBAL.ThePlayer.player_classified.mermking_hunger_current
            self.max_hunger = GLOBAL.ThePlayer.player_classified.mermking_hunger_max
            self.current_health = GLOBAL.ThePlayer.player_classified.mermking_health_current
            
            print(GLOBAL.ThePlayer.player_classified.equipped_hat)
            if self.current_health > 0 and (not VISIBLEOPTION or GLOBAL.ThePlayer.prefab == "wurt" or GLOBAL.ThePlayer.player_classified.equipped_hat == "mermhat") then
                self.healthbadge:Show()
                self.hungerbadge:Show()

                self.hungerbadge:SetPercent(self.current_hunger, self.max_hunger)
                if self.last_hunger ~= nil and self.current_hunger ~= nil and self.current_hunger > self.last_hunger then
                    hungerIncrease()
                end


                self.healthbadge:SetPercent(self.current_health, TUNING.MERM_KING_HEALTH)
                if self.last_health ~= nil and self.current_health ~= nil and self.current_health < self.last_health then
                    healthDecrease()
                end

                if HAS_MOD.COMBINED_STATUS then
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

                    self.inst:DoTaskInTime(0, function(inst)
                        local _ShowStatusNumbers = self.ShowStatusNumbers
                        function self:ShowStatusNumbers()
                            _ShowStatusNumbers(self)
                            if self.hungerbadge ~= nil then
                                self.hungerbadge.rate:Show()
                                self.hungerbadge.num:Hide()
                            end

                            if self.healthbadge ~= nil then
                                self.healthbadge.rate:Show()
                                self.healthbadge.num:Hide()
                            end
                        end

                        local _HideStatusNumbers = self.HideStatusNumbers
                        function self:HideStatusNumbers()
                            _HideStatusNumbers(self)
                            if self.hungerbadge ~= nil then
                                self.hungerbadge.rate:Hide()
                                self.hungerbadge.num:Show()
                            end

                            if self.healthbadge ~= nil then
                                self.healthbadge.rate:Hide()
                                self.healthbadge.num:Show()
                            end
                        end
                    end)

                    -- 마우스 벗어남
                    local _OnLoseFocus = self.hungerbadge.OnLoseFocus
                    function self.hungerbadge:OnLoseFocus()
                        _OnLoseFocus(self)
                        self.rate:Hide()
                    end
                    
                    -- 마우스 들어옴
                    local _OnGainFocus = self.hungerbadge.OnGainFocus
                    function self.hungerbadge:OnGainFocus()
                        _OnGainFocus(self)
                        if self.active then
                            self.rate:Show()
                        end
                    end
                    
                    -- 배 위에 있을 때 뱃지 위치관련
                    -- function self.hungerbadge:OnHide()
                    --     if self.parent ~= nil and self.parent.boatmeter then
                    --         self.parent.boatmeter:SetPosition(-62, -52)
                    --     end
                    -- end

                    -- function self.hungerbadge:OnShow()
                    --     if self.parent ~= nil and self.parent.boatmeter then
                    --         self.parent.boatmeter:SetPosition(-62, -139)
                    --     end
                    -- end

                    -- if self.boatmeter then
                    --     self.boatmeter.inst:ListenForEvent("open_meter", function(inst)
                    --         if inst.widget.parent.hungerbadge.shown then
                    --             inst.widget:SetPosition(-62, -139)
                    --         else
                    --             inst.widget:SetPosition(-62, -52)
                    --         end
                    --     end)
                    -- end
                else
                    self.hungerbadge.num:SetSize(25)
                    self.hungerbadge.num:SetScale(1,.9,1)
                    self.hungerbadge.num:SetPosition(3, 3)

                    self.healthbadge.num:SetSize(25)
                    self.healthbadge.num:SetScale(1,.9,1)
                    self.healthbadge.num:SetPosition(3, 3)


                    local _ShowStatusNumbers = self.ShowStatusNumbers
                    function self:ShowStatusNumbers()
                        _ShowStatusNumbers(self)
                        if self.hungerbadge ~= nil then
                            self.hungerbadge.num:Show()
                        end

                        if self.healthbadge ~= nil then
                            self.healthbadge.num:Show()
                        end
                    end

                    local _HideStatusNumbers = self.HideStatusNumbers
                    function self:HideStatusNumbers()
                        _HideStatusNumbers(self)
                        if self.hungerbadge ~= nil then
                            self.hungerbadge.num:Hide()
                        end

                        
                        if self.healthbadge ~= nil then
                            self.healthbadge.num:Hide()
                        end
                    end
                end
                
                self.last_hunger = self.current_hunger
                self.last_health = self.current_health
            else 
                self.healthbadge:Hide()
                self.hungerbadge:Hide()
            end
        end
    end)
end)

AddPrefabPostInit("player_classified", function(inst)
    player_inst = inst
    
    if VISIBLEOPTION then
        inst.equipped_hat = ""
        inst.net_equipped_hat = GLOBAL.net_string(inst.GUID, "equipped_hat", "equipped_hat_dirty")

        inst:ListenForEvent("equipped_hat_dirty", function(inst)
            inst.equipped_hat = inst.net_equipped_hat:value()
        end)
    end 

    inst.mermking_hunger_current = 0
    inst.net_mermking_hunger_current = GLOBAL.net_int(inst.GUID, "mermking_hunger_current", "mermking_hunger_current_dirty")
    
    inst:ListenForEvent("mermking_hunger_current_dirty", function(inst)
        inst.mermking_hunger_current = inst.net_mermking_hunger_current:value()
    end)

    inst.mermking_hunger_max = TUNING.MERM_KING_HUNGER
    inst.net_mermking_hunger_max = GLOBAL.net_int(inst.GUID, "mermking_hunger_max", "mermking_hunger_max_dirty")

    inst:ListenForEvent("mermking_hunger_max_dirty", function(inst)
        inst.mermking_hunger_max = inst.net_mermking_hunger_max:value()
    end)
    
    inst.mermking_health_current = 0
    inst.net_mermking_health_current = GLOBAL.net_int(inst.GUID, "mermking_health_current", "mermking_health_current_dirty")
    
    inst:ListenForEvent("mermking_health_current_dirty", function(inst)
        inst.mermking_health_current = inst.net_mermking_health_current:value()
    end)

    inst:DoPeriodicTask(0, function()
        local mermkingmanager = GLOBAL.TheWorld.components.mermkingmanager
        if mermkingmanager ~= nil then
            if mermkingmanager:HasKingLocal() then
                king = mermkingmanager:GetKing()
                inst.net_mermking_hunger_current:set(king.components.hunger.current) 
                inst.net_mermking_hunger_max:set(king.components.hunger.max)
                inst.net_mermking_health_current:set(king.components.health.currenthealth)
            elseif mermkingmanager:HasKingAnywhere() then
                -- 반대쪽(동굴 or 지상)으로 시그널 전달
                SendModRPCToShard(GetShardModRPC(modname, "mermking_update"), nil, nil, nil, nil) 
            else
                inst.net_mermking_hunger_current:set(0) 
                inst.net_mermking_hunger_max:set(TUNING.MERM_KING_HUNGER)
                inst.net_mermking_health_current:set(0)
            end
        end
    end)
end)

AddPlayerPostInit(function(inst)
    if VISIBLEOPTION then
        GLOBAL.TheWorld:ListenForEvent("ms_playerjoined", function(self)
            local hat = inst.components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HEAD)
            if hat ~= nil then 
                inst.player_classified.net_equipped_hat:set(hat.prefab) 
            end
        end)

        inst:ListenForEvent("equip", function(owner, data)
            if data.item ~= nil then
                local equipslot = data.item.replica.equippable:EquipSlot()
                if equipslot == "head" then
                    owner.player_classified.net_equipped_hat:set(data.item.prefab)
                end
            end
        end)

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

AddShardModRPCHandler(modname, "mermking_update", function(shardId, hunger_current, hunger_max, health_current)
    if GLOBAL.TheShard:GetShardId() ~= tostring(shardId) then
        if hunger_current ~= nil and hunger_max ~= nil and health_current ~= nil then
            -- if player_inst.mermking_hunger_current < hunger_current then
                player_inst.net_mermking_hunger_current:set(hunger_current)
                player_inst.net_mermking_hunger_max:set(hunger_max)
                player_inst.net_mermking_health_current:set(health_current)
            -- end
        else
            local king = GLOBAL.TheWorld.components.mermkingmanager:GetKing()
            GLOBAL.TheWorld:DoTaskInTime(0, function()
                SendModRPCToShard(GetShardModRPC(modname, "mermking_update"), shardId, king.components.hunger.current, king.components.hunger.max, king.components.health.currenthealth)
            end) 
        end
    end
end)
