-- WORLD PROGRESSION v1.2 CREATED BY C̶a̶m̶p̶e̶r☻ --
-- if you enjoy this addon or came for some inspiration, please drop a like! --
-- Planned Features: NPC Blacklist/Whitelist, NPC leveling from kills

AddCSLuaFile("autorun/client/cl_worldprog.lua")

local worldL = 1
local worldXP = 250 --default 250
local comboTime = 25
local wXPLoss = -50
local wXPTotal = 0
local worldP = 0
local prestigeSystem = true
local npcShare = false
local PVPMode = false
local plyShare = false
local comboSystem = true
local diffi = 2 -- 1=easy, 2=med/normal, 3 = hard
local allParty = {}
local PVPtop = {"ply1","ply2","ply3","ply4","ply5"}
local ply = FindMetaTable("Player")
local host


--Npc related
local NPCHelp = true

if(SERVER) then
    util.AddNetworkString("DrawCombo")
    util.AddNetworkString("DrawTime")
    util.AddNetworkString("WLVL")
    util.AddNetworkString("Kills")
    util.AddNetworkString("SendXP")
    util.AddNetworkString("WPRESTIGE")
    util.AddNetworkString("CT_Update")
    util.AddNetworkString("HUDClear")
    util.AddNetworkString("SSet")
    util.AddNetworkString("PParty")
    util.AddNetworkString("PartyUI")
    util.AddNetworkString("PartyCName")
    util.AddNetworkString("WLVL")
    util.AddNetworkString("XPTotal")
    util.AddNetworkString("PartyInfo")
    util.AddNetworkString("killTotal")
    util.AddNetworkString("uiSend")
    util.AddNetworkString("DefWrld")
    util.AddNetworkString("Allparties")
    util.AddNetworkString("Allmembers")
    util.AddNetworkString("Sendmem")
    util.AddNetworkString("refreshWUI")
    util.AddNetworkString("refreshLWUI")
    util.AddNetworkString("refreshPUI")
    util.AddNetworkString("PresTok")
    util.AddNetworkString("PSkill")
    util.AddNetworkString("PresSkillSet")
    util.AddNetworkString("PresSkillGet")
    util.AddNetworkString("DrawNPClvl")
    util.AddNetworkString("GetPSSkills")
    util.AddNetworkString("DrawPlyCT")
    util.AddNetworkString("MiniPan")
    util.AddNetworkString("PresSys")
    util.AddNetworkString("ResetPly")
    util.AddNetworkString("npcHelp")
    util.AddNetworkString("sentTok")
    util.AddNetworkString("pvpSetting")
    util.AddNetworkString("plyCSettings")
    util.AddNetworkString("PlySettings")
    util.AddNetworkString("SendTop5")

    --Player Settings
    util.AddNetworkString("WorldDiff")
    util.AddNetworkString("DebugS")
    util.AddNetworkString("PartyS")
    util.AddNetworkString("LockedS")
    util.AddNetworkString("wpbind")
    util.AddNetworkString("SaveWrld")
    util.AddNetworkString("LoadWrld")
    util.AddNetworkString("resetSkills")
end

function ArrayContains(array, value)
    local length = #(array)
    local truth = false

    for i = 0, length do
        if(array[i] == value)then
            truth = true
        end
    end

    return truth
end

--Prev Settings Startup
hook.Add("Initalize", "WorldStart", function()
    for i, ply in ipairs(player.GetAll()) do
        if(ply:IsUserGroup("host")) then
         --Load prev world settings
          diffi = tonumber(ply:GetVar("pwrlddiffi"))
          ply:PrintMessage(HUD_PRINTCENTER,"World Settings Loaded.")
          host = ply
        end
    end
end)

hook.Add("ShutDown", "WorldShutdown", function()
    for i, ply in ipairs(player.GetAll()) do
        if(ply:IsUserGroup("host")) then
            --Save prev world settings
         end
    end
end)

hook.Add("PlayerInitialSpawn", "WorldProg/Load", function(ply)
 ply:SendHint("[WORLD PROG] Help & settings in utilities menu.", 65)
    if(ply:GetXP() != nil)then 
        ply:SetVar("XPS", 0)
    end
    if(ply:GetParty() == nil) then
        ply:SaveParty("No Party")
    end
        
    ply:SetVar("pshC", false)
    ply:SetVar("HSK",0)
    ply:SetVar("Kills",0)
    ply:SetVar("HSKills", 0)
    ply:SetCombo(0)
    ply:SetKills(0)
    if(worldP > 0)then
        ply:SaveTokens(worldP)
    end
    ply:PrintMessage(HUD_PRINTCENTER,"World Progression Activated.")
    updateWrldProg()
    SendPlyInfo(ply:GetCombo(), ply)
    sendWrldData()
end)

hook.Add("PlayerDisconnected", "PlayerLeave", function(ply)
    updateWrldProg()
    prestigeCal()
    sendWrldData()
end)

hook.Add("Think", "UpdateAllHud", function()
        for i, ply in ipairs(player.GetAll()) do
            if(timer.Exists("ComboChain" .. ply:UserID())) then
                local time = timer.TimeLeft("ComboChain" .. ply:UserID())
                SendPlyInfo(ply:GetCombo(), ply)
                UpdatePlyHud(time,ply)
            end
            if(ply:GetEyeTrace().Entity:IsNextBot() and ply:GetEyeTrace().Entity:IsValid()) then
                local cNPC = ply:GetEyeTrace().Entity
                ply:PrintMessage(3,"HP: " .. cNPC:GetMaxHealth() .. "/" .. cNPC:Health())
            elseif(ply:GetEyeTrace().Entity:IsNPC() and ply:GetEyeTrace().Entity:IsValid()) then
                local cNPC = ply:GetEyeTrace().Entity
                local npcTable = cNPC:GetTable()
                if(npcTable == nil) then
                    
                end
                timer.Simple(0.4,function()
                    local npcLvl = npcTable["npcLVL"]
                    local npcHealth = npcTable["npcHP"]
                    
                    if(ply:GetDBSetting() == true and ply:Crouching()) then
                        ply:PrintMessage(3,"LVL: " .. npcLvl .. ", HP: " .. npcHealth .. "/" .. cNPC:Health())
                    end
                    SendnpcLvl(npcLvl,ply)
                end)
            elseif(ply:GetEyeTrace().Entity:IsPlayer() and ply:GetEyeTrace().Entity:IsValid()) then
                local cPly = ply:GetEyeTrace().Entity
                if(timer.Exists("ComboChain" .. cPly:UserID())) then
                    local sk = cPly:GetKills()
                    local sc = cPly:GetCombo()
                    local stime = timer.TimeLeft("ComboChain" .. cPly:UserID())
                    SendComboInfo(sk,stime,sc,ply)
                end
            else
                --
            end
            SendPlyXP(ply:GetXP(), ply)
        end
    
end)

function NPCInit(ent)
    if(IsValid(ent)) then
        local maxLvl = worldL + 5 --Max NPC Level
        local entLvl = 1 -- NPC Level
        local hmulti = 1 -- entLVL health multip
            local max = ent:GetMaxHealth()
            if(worldP > 0) then --Prestige Multiplier
               entLvl = 5 * worldP
               maxLvl = entLvl + 5
            end
             --NPC Level Gen
             if(worldL== 1) then --New/Reset World Cap
                  if(diffi == 2)then
                      entLvl = math.random(entLvl, maxLvl-3)
                  elseif(diffi == 3)then
                      entLvl = math.random(entLvl+1, maxLvl-1)
                  else
                      entLvl = math.random(worldL, maxLvl - 4) -- easy
                  end
             elseif(worldL > 2) then 
                  if(diffi == 2) then
                      entLvl = math.random(entLvl-1, maxLvl-1)
                  elseif(diffi == 3)then
                      entLvl = math.random(entLvl+1, maxLvl+2)
                  else
                      entLvl = math.random(worldL-2, maxLvl -2)
                  end
             end
             --Backup Level if the generation has a issue
             if(entLvl <= 0 or entLvl == nil) then
                  entLvl = 1
             end
              --NPC Health Gen
              if(entLvl >= maxLvl) then
                  hmulti = math.random(entLvl, entLvl+2)
              elseif(entLvl > worldL and entLvl < maxLvl) then
                  hmulti = math.random(entLvl, entLvl+1)
              else
                  hmulti = math.random(entLvl, entLvl-1)
              end
              --Difficulty Multiplier
              if(diffi == 1)then
                  hmulti = hmulti * entLvl
              elseif(diffi == 2)then
                  local nh = entLvl * 4
                  hmulti = hmulti * nh
              elseif(diffi == 3) then
                  local nh = entLvl * 6
                  hmulti = hmulti * nh
              end
              hmulti = max + hmulti
                ent:SetVar("npcLVL", entLvl)
                ent:SetVar("npcHP", hmulti)
                ent:SetVar("npcKills", 0)
                ent:SetMaxHealth(hmulti)
                ent:SetHealth(hmulti)
    end
end

function NextbotInit(ent)
    if(IsValid(ent)) then
        local maxLvl = worldL + 5 --Max NPC Level
        local entLvl = 1 -- NPC Level
        local hmulti = 1 -- entLVL health multip
            local max = ent:GetMaxHealth()
            if(worldP > 0) then --Prestige Multiplier
               entLvl = 5 * worldP
               maxLvl = entLvl + 5
            end
             --NPC Level Gen
             if(worldL== 1) then --New/Reset World Cap
                  if(diffi == 2)then
                      entLvl = math.random(entLvl, maxLvl-3)
                  elseif(diffi == 3)then
                      entLvl = math.random(entLvl+1, maxLvl-1)
                  else
                      entLvl = math.random(worldL, maxLvl - 4) -- easy
                  end
             elseif(worldL > 2) then 
                  if(diffi == 2) then
                      entLvl = math.random(entLvl-1, maxLvl-1)
                  elseif(diffi == 3)then
                      entLvl = math.random(entLvl+1, maxLvl+2)
                  else
                      entLvl = math.random(worldL-2, maxLvl -2)
                  end
             end
             --Backup Level if the generation has a issue
             if(entLvl <= 0 or entLvl == nil) then
                  entLvl = 1
             end
              --NPC Health Gen
              if(entLvl >= maxLvl) then
                  hmulti = math.random(entLvl, entLvl+2)
              elseif(entLvl > worldL and entLvl < maxLvl) then
                  hmulti = math.random(entLvl, entLvl+1)
              else
                  hmulti = math.random(entLvl, entLvl-1)
              end
              --Difficulty Multiplier
              if(diffi == 1)then
                  hmulti = hmulti * entLvl
              elseif(diffi == 2)then
                  local nh = entLvl * 4
                  hmulti = hmulti * nh
              elseif(diffi == 3) then
                  local nh = entLvl * 6
                  hmulti = hmulti * nh
              end
              hmulti = max + hmulti
              ent.SpawnHealth = 50
    end
end

-- ON NPC SPAWN
hook.Add( "OnEntityCreated", "NPCInitial",  function(ent)
    timer.Simple(0.3,function()
        if(IsValid(ent) and !ent:IsPlayer()) then
            if(ent:IsNextBot()) then
                --NextbotInit(ent)
            elseif (ent:IsNPC() and !ent:IsPlayer()) then
                NPCInit(ent)
            else
                return;
            end
        end
    end)
end)

--Player Death
hook.Add("PlayerDeath", "Combostop", function( victim, inflictor, attacker)
    if(victim:IsValid())then
        if(timer.Exists("ComboChain" .. victim:UserID()))then
            timer.Remove("ComboChain" .. victim:UserID())
            XpCal(victim)
            victim:ChatPrint("-" .. wXPLoss .. "xp, Combo Has Ended!")
            victim:SetXP(wXPLoss)
            local xp = tonumber(victim:GetVar("XPS"))
            if(xp < 0) then
                victim:SetVar("XPS",0)
            end
        else
            victim:ChatPrint("-" .. wXPLoss .. "xp!")
            victim:SetXP(wXPLoss)
            local xp = tonumber(victim:GetVar("XPS"))
            if(xp < 0) then
                victim:SetVar("XPS",0)
            end
        end
    end

    if(attacker:IsNPC() and attacker:IsValid())then
        local npcTable = attacker:GetTable()
        local nkills = npcTable["npcKills"]
        local kLvl = npcTable["npcLVL"]
        if(nkills == nil)then
            nkills = 2
        else
            nkills = nkills + 2
        end
        attacker:SetVar("npcKills", nkills)
        if(nkills > kLvl) then
            kLvl = kLvl + 1
            npcTable["npcLVL"] = kLvl
            attacker:SetVar("npcLvl", kLvl)
            attacker:SetVar("npcKills", 0)
            local hmulti = 1
            if(kLvl >= worldL+5) then
                hmulti = math.random(kLvl, kLvl+2)
            elseif(kLvl > worldL and kLvl < worldL+5) then
                hmulti = math.random(kLvl, kLvl+1)
            else
                hmulti = math.random(kLvl, kLvl-1)
            end
            attacker:SetMaxHealth(hmulti)
            PrintMessage(HUD_PRINTTALK, attacker:GetName() .. " is now LVL " .. attacker:GetVar("npcLvl") .. "!")
        end
    end

    updateWrldProg()
    sendWrldData()
    SendPlyInfo(0.0, victim)

end)
 
--Player Damage from NPC & Or Player With Combo Active
hook.Add("PlayerHurt", "ComboCut", function(victim, attacker)
    local skillt = victim:GetSkills()
        if(skillt != nil and table.HasValue(skillt,"hfc")) then
            if(victim:GetHFTC() == 0)then

            else
             victim:SetHFTC(0)
             victim:ChatPrint("HFC Reset!")
            end
        end

    if(attacker:IsNPC() and attacker:IsValid()) then
        if(timer.Exists("ComboChain" .. victim:UserID())) then
            local skillt = victim:GetSkills()
            if(skillt != nil and table.HasValue(skillt,"CS") and victim:shCCheck() == true) then
                victim:ChatPrint("Substitution Used!")
                victim:shCSet(false)
            else
                local time = timer.TimeLeft("ComboChain" .. victim:UserID())
                local plyC = victim:GetCombo()
                if(tonumber(victim:GetCombo()) <= 4) then
                    if(skillt != nil and table.HasValue(skillt,"CS") and victim:shCCheck() == false) then
                        UpdatePlyTimer(time - 0.50, victim)
                        timer.Adjust("ComboChain" .. victim:UserID(), time - 0.50)
                        UpdatePlyHud(timer.TimeLeft("ComboChain" .. victim:UserID()), victim)
                        UpdatePlyTimer(timer.TimeLeft("ComboChain" .. victim:UserID()),victim)
                        victim:EmitSound("buttons/combine_button_locked.wav")
                    else
                        UpdatePlyTimer(time - 1.50, victim)
                        timer.Adjust("ComboChain" .. victim:UserID(), time - 1.50)
                        UpdatePlyHud(timer.TimeLeft("ComboChain" .. victim:UserID()), victim)
                        UpdatePlyTimer(timer.TimeLeft("ComboChain" .. victim:UserID()),victim)
                        victim:EmitSound("buttons/combine_button_locked.wav")
                    end
                else
                    if(skillt != nil and table.HasValue(skillt,"CS") and victim:shCCheck() == false) then
                        local qtime ="-" .. tostring(time / 1.5)
                        timer.Adjust("ComboChain" .. victim:UserID(), time / 1.5)
                        UpdatePlyHud(timer.TimeLeft("ComboChain" .. victim:UserID()), victim)
                        UpdatePlyTimer(timer.TimeLeft("ComboChain" .. victim:UserID()),victim)
                        victim:EmitSound("buttons/combine_button_locked.wav")
                    else
                        local qtime ="-" .. tostring(time / 2)
                        timer.Adjust("ComboChain" .. victim:UserID(), time / 2)
                        UpdatePlyHud(timer.TimeLeft("ComboChain" .. victim:UserID()), victim)
                        UpdatePlyTimer(timer.TimeLeft("ComboChain" .. victim:UserID()),victim)
                        victim:EmitSound("buttons/combine_button_locked.wav")
                    end
                end
            end
        end
    end
end)

-- XP system. If player kills npc, check radius for additonal players & friendly npc.
function NPCchecker (victim, killer, weapon)
    if(!comboSystem and killer:IsPlayer()) then
        local nXP = 15
        local skillt = killer:GetSkills()
        if(victim:GetVar("npcLVL") >= worldL+5) then
            nXP = 50
            killer:PrintMessage(HUD_PRINTTALK, "+50xp")
        elseif(victim:GetVar("npcLVL") > worldL && (victim:GetVar("npcLVL") < worldL +5)) then
            nXP = 25
            killer:PrintMessage(HUD_PRINTTALK, "+25xp")
        else
            nXP = 10
            killer:PrintMessage(HUD_PRINTTALK, "+10xp")
        end
        if(skillt != nil and table.HasValue(skillt,"2x")) then
            nXP = nXP * 2.0
            killer:PrintMessage(HUD_PRINTTALK, "2x XP Active! Total: +" .. nXP .. "xp")
        end
        if(worldP > 0)then
            nXP = nXP + 0.5 * worldP
        end
        killer:SetXP(nXP)
        local nk = tonumber(killer:GetKills()) + 1
        killer:SetKills(nk)
        killer:UpdateHSKills()
        local totalxp = getplysXP()
        TotalXpRefresh(totalxp)
        SendKills(nk, killer)
        updateWrldProg()
        sendWrldData()
    else
        if(killer:IsVehicle())then
            killer = killer:GetDriver()
        end
        plyComboCheck(victim, killer, weapon)
    end
end
hook.Add("OnNPCKilled", "xpCheck", NPCchecker)

function plyComboCheck(victim, killer, weapon)
    local victimLevel = 1;
    if(victim:GetVar("npcLVL") == nil) then
        
    else
        victimLevel = victim:GetVar("npcLVL");
    end
    if (killer:IsPlayer()) then -- if timer is active then kills will continue it.
        if(timer.Exists("ComboChain" .. killer:UserID())) then
            local time = timer.TimeLeft("ComboChain" .. killer:UserID())
            local nChain = 0;
            killer:SetKills(killer:GetKills()+1)
            killer:UpdateHSKills()
            if(killer:GetKills() >= 2)then
                nChain = ComboKillCheck(killer:GetKills(), killer)
                killer:SetCombo(nChain)
            end
            if(time > 60.00)then
                timer.Adjust("ComboChain" .. killer:UserID(), time + 1)
            else
                timer.Adjust("ComboChain" .. killer:UserID(), time + 1.5)
            end
            if(victim:GetVar("npcLVL") >= worldL+5) then
                timer.Adjust("ComboChain" .. killer:UserID(), time + 3.5)
            elseif(victim:GetVar("npcLVL") > worldL && (victim:GetVar("npcLVL") < worldL +5)) then
                timer.Adjust("ComboChain" .. killer:UserID(), time + 2)
            end
            SendKills(killer:GetKills(), killer)
            SendPlyInfo(killer:GetCombo(), killer)
            UpdatePlyHud(time, killer)
        else
            --Make our Combo timer
            killer:SetKills(1)
            timer.Create("ComboChain" .. killer:UserID(), comboTime+1.5, 1, function() XpCal(killer) end)
            if(victim:GetVar("npcLVL") >= worldL+5) then
                timer.Create("ComboChain" .. killer:UserID(), comboTime+3.5, 1, function() XpCal(killer) end)
            elseif(victim:GetVar("npcLVL") > worldL && (victim:GetVar("npcLVL") < worldL +5)) then
                timer.Create("ComboChain" .. killer:UserID(), comboTime+2, 1, function() XpCal(killer) end)
            else
                timer.Create("ComboChain" .. killer:UserID(), comboTime+1.5, 1, function() XpCal(killer) end)
            end
            killer:UpdateHSKills()
            SendKills(killer:GetKills(), killer)
            SendPlyInfo(killer:GetCombo(), killer)
            UpdatePlyHud(comboTime, killer)
        end
        local skillt = killer:GetSkills()
        if(skillt != nil and table.HasValue(skillt,"hfc")) then
            if(killer:GetCombo() >= 1.5)then
                local xChain = killer:GetHFTC()
                xChain = xChain + 0.1
                killer:SetHFTC(xChain)
                killer:ChatPrint("HFT Chain: " .. xChain)
            end
        end

        if(killer:MPGet() == true) then
            RefreshLockedPanel(killer)
        end

        -- Party Radius Check
        local entT = ents.FindInSphere(killer:GetPos(), 900)
        for i = 1, #entT do
            if(entT[i]:IsPlayer() and entT[i] != killer) then
                if(entT[i]:GetPPSetting() == true) then
                    if(entT[i]:GetParty() == killer:GetParty())then 
                        if(timer.Exists("ComboChain" .. entT[i]:UserID())) then
                            local partyTime = timer.TimeLeft("ComboChain" .. entT[i]:UserID())
                            if(partyTime > 60) then
                                timer.Adjust("ComboChain" .. entT[i]:UserID(), partyTime + 0.5)
                            else
                                timer.Adjust("ComboChain" .. entT[i]:UserID(), partyTime + 1)
                            end
                        else
                            if(entT[i]:GetDBSetting() == true) then
                                entT[i]:ChatPrint("DEBUG:CT started from party.")
                            end
                            --Make our Combo timer
                            timer.Create("ComboChain" .. entT[i]:UserID(), comboTime, 1, function() XpCal(entT[i]) end)
                            UpdatePlyHud(comboTime, entT[i])
                        end
                            SendPlyInfo(entT[i]:GetCombo(), entT[i])
                            UpdatePlyHud(timer.TimeLeft("ComboChain"),entT[i])
                        if(entT[i]:GetDBSetting() == true) then
                            entT[i]:ChatPrint("DEBUG: CT+ from party.")
                        end
                    end
                end
            end
        end
    else
        if(killer:IsNPC() and victim:IsValid() and victim:IsNPC())then
            local npcTable = killer:GetTable()
            local nkills = npcTable["npcKills"]
            local kLvl = npcTable["npcLVL"]
            local nLVL = victim:GetVar("npcLVL")
            if(nkills == nil)then
                nkills = 1
            elseif(nLVL >= worldL + 5) then
                nkills = nkills +2
            else
                nkills = nkills +1
            end
            killer:SetVar("npcKills", nkills)
            if(nkills > kLvl) then
                kLvl = kLvl + 1
                npcTable["npcLVL"] = kLvl
                killer:SetVar("npcLvl", kLvl)
                killer:SetVar("npcKills", 0)
                local hmulti = 1
                if(kLvl >= worldL+5) then
                    hmulti = math.random(kLvl, kLvl+2)
                elseif(kLvl > worldL and kLvl < worldL+5) then
                    hmulti = math.random(kLvl, kLvl+1)
                else
                    hmulti = math.random(kLvl, kLvl-1)
                end
                killer:SetMaxHealth(hmulti)
                PrintMessage(HUD_PRINTTALK, killer:GetName() .. " is now LVL " .. killer:GetVar("npcLvl") .. "!")
            end
        end
    end
end

--For Prestige Skill Specifics
hook.Add("ScaleNPCDamage", "DetailedCheck", function(npc, hitgroup, dmginfo)
    local plys = dmginfo:GetAttacker()
    if(plys:IsPlayer())then
        local skillt = plys:GetSkills()
        if(skillt != nil and table.HasValue(skillt,"coh")) then
            if(hitgroup == HITGROUP_HEAD && npc:GetNPCState() == NPC_STATE_PRONE) then
                if(plys:GetDBSetting() == true) then
                    plys:ChatPrint("DEBUG:       +4.5s(C.O.H.)")
                end
                if(timer.Exists("ComboChain" .. plys:UserID())) then
                    timer.Adjust("ComboChain" .. killer:UserID(), time + 4.5)
                    UpdatePlyHud(timer.TimeLeft("ComboChain"), plys) 
                end

            elseif(hitgroup == HITGROUP_HEAD) then
                if(plys:GetDBSetting() == true) then
                    plys:ChatPrint("DEBUG:       +0.8s(C.O.H.)")
                end
                if(timer.Exists("ComboChain" .. plys:UserID())) then
                    timer.Adjust("ComboChain" .. killer:UserID(), time + 0.8)
                    UpdatePlyHud(timer.TimeLeft("ComboChain"), plys)
                end
            end
        end

        if(skillt != nil and table.HasValue(skillt,"vamp")) then
            if(hitgroup == HITGROUP_HEAD) then
                local shealth = npc:GetMaxHealth()
                if(plys:Health() >= plys:GetMaxHealth()) then

                else
                    local nhealth = plys:Health()
                    shealth = shealth / 80
                    nhealth = nhealth + shealth
                    plys:SetHealth(nhealth)
                    plys:ChatPrint("+" .. tostring(shealth) .. "hp! (Vamp)")
                end
            else
                if(plys:Health() >= plys:GetMaxHealth()) then
 
                else
                    local shealth = npc:GetMaxHealth()
                    local nhealth = plys:Health()
                    shealth = shealth / 120
                    nhealth = nhealth + shealth
                    plys:SetHealth(nhealth)
                    plys:ChatPrint("+" .. tostring(shealth) .. "hp (Vamp)")
                end       
            end
        end
    end
end)

--NPC Hurt during combo check
hook.Add("EntityTakeDamage", "ComboAddCheck", function(target, dmginfo)
    if(!comboSystem) then
        
    else
        local attacker = dmginfo:GetAttacker()
        if(target:IsNPC())then
            if(attacker:IsNPC())then --NPC vs NPC
                if(NPCHelp == true)then
                    NPCPartyScan(attacker,dmginfo)
                end
            elseif(attacker:IsPlayer()) then
                attackerScan(attacker,target,dmginfo)
                local entE = ents.FindInSphere(target:GetPos(), 1000)
                for i =1, #entE do
                    if(entE[i]:IsPlayer() and entE[i]:GetPPSetting() == true and entE[i] != attacker)then
                        PartyScan(entE[i], attacker)
                    end
                end
            end
        end
    end
end)

function attackerScan(entT,target,dmginfo)
    if(IsValid(entT) and entT:IsPlayer()) then
        if(timer.Exists("ComboChain" .. entT:UserID())) then
            local time = timer.TimeLeft("ComboChain" .. entT:UserID())
            if(time > 60.00)then
                timer.Adjust("ComboChain" .. entT:UserID(), time + 0.2)
                UpdatePlyHud(time+0.2,entT)
            else
                timer.Adjust("ComboChain" .. entT:UserID(), time + 0.3)
                UpdatePlyHud(time+0.3,entT)
            end
            if(target:GetVar("npcLVL") != nil) then
                if(target:GetVar("npcLVL") >= worldL+5) then
                    timer.Adjust("ComboChain" .. entT:UserID(), time + 0.5)
                    UpdatePlyHud(time+0.5,entT)
                end
            end
            local skillt = entT:GetSkills()
            if(skillt != nil and table.HasValue(skillt,"tBt")) then
                local cspeed = entT:GetMaxSpeed()
                cspeed = cspeed + 20.0
                entT:SetMaxSpeed(cspeed)
                    entT:ChatPrint("+2.0% Speed")
            end
        end
    end
end

function PartyScan(entT, ply)
    if(entT:IsPlayer() and entT:GetParty() == ply:GetParty() and entT:GetParty() != "No party" and ply:GetParty() != "No party")then
        if(timer.Exists("ComboChain" .. entT:UserID())) then
            if(entT:GetDBSetting() == true) then
                entT:ChatPrint("DEBUG: +0.2s from party.")
            end
            local time = timer.TimeLeft("ComboChain" .. entT:UserID())
            if(time > 60.00)then
                timer.Adjust("ComboChain" .. entT:UserID(), time + 0.1)
                UpdatePlyHud(time+0.1,entT)
            else
                timer.Adjust("ComboChain" .. entT:UserID(), time + 0.2)
                UpdatePlyHud(time+0.2,entT)
            end
            local skillt = entT:GetSkills()
            if(skillt != nil and table.HasValue(skillt,"tBt")) then
                local cspeed = entT:GetMaxSpeed()
                cspeed = cspeed + 10.0
                entT:SetMaxSpeed(cspeed)
                if(entT:GetDBSetting() == true) then
                    entT:ChatPrint("Cranked Boots Active! +1.0% speed (party)")
                end 
            end
        end
    end
end

function NPCPartyScan(entT, dmginfo)
    if(entT:IsNPC() and entT:GetNPCState() != NPC_STATE_DEAD) then
        local entC = ents.FindInSphere(entT:GetPos(), 450)
        for i =1, #entC do
            if(IsValid(entC[i]) and entC[i]:IsPlayer()) then
                local plyT = entC[i]
                if(entT:HasEnemyMemory(plyT) != true and plyT:GetPPSetting() == true) then
                    if(timer.Exists("ComboChain" .. plyT:UserID())) then
                        local time = timer.TimeLeft("ComboChain" .. plyT:UserID())
                        timer.Adjust("ComboChain" .. plyT:UserID(), time + 0.2)
                        UpdatePlyHud(time+0.1,plyT)
                        if(plyT:GetDBSetting() == true) then
                            plyT:ChatPrint("DEBUG: +0.1s from NPC")
                        end
                        local skillt = plyT:GetSkills()
                        if(skillt != nil and table.HasValue(skillt,"tlS")) then
                            if(plyT:GetDBSetting() == true) then
                                plyT:ChatPrint("Battle Sense Active! +0.3s from NPC")
                            end 
                            local x = timer.TimeLeft("ComboChain" .. plyT:UserID())
                            local time = timer.TimeLeft("ComboChain" .. plyT:UserID())
                            timer.Adjust("ComboChain" .. plyT:UserID(), time + 0.3)
                            UpdatePlyHud(time+0.3,plyT)
                        end
                    else
                        if(plyT:GetDBSetting() == true) then
                            plyT:ChatPrint("DEBUG: (NPC Party) No Active Combo.")
                        end
                    end
                end
            end
        end
    end
end

--XP Calc
function XpCal(ply)
        --Chain multiplier
    local chainM = 0 -- Chain multiply
    local comboXP = 1
    local killM = ply:GetKills()
    local pChain = ply:GetCombo()
    local hct = 0
    local nFincomboXP = 0
    local partyXPskill = false
    if(worldP > 0)then
        comboXP = comboXP + 0.5 * worldP
    end

    --Difficulty Scale
    if(diffi == 1)then
        comboXP = 10.5 * killM
    elseif(diffi == 2)then
        comboXP = 20.0 * killM
    elseif(diffi == 3)then
        local HkillM = killM * 1.5
        comboXP = 30.0 * HkillM
    end
    chainM = ComboMultiplySet(pChain)
    --Party Check
    if(ply:GetPPSetting() == true) then
        local entT2 = ents.FindInSphere(ply:GetPos(), 900)
        local pKills = 0
        local tkills = 0
        if(ply:GetDBSetting() == true) then
            ply:ChatPrint("DEBUG XP:Searching for party kills..")
        end

        for i = 1, #entT2 do
            if(entT2[i]:IsPlayer() and entT2[i]:GetPPSetting()) then
                if(entT2[i]:GetParty() == ply:GetParty() and ply:GetParty() != "No party" and entT2[i]:GetParty() != "No party") then
                    if(entT2[i]:UserID() != ply:UserID()) then
                        if(entT2[i]:GetKills() > 0 and timer.Exists("ComboChain" .. entT2[i]:UserID())) then -- Active Combo!
                            tkills = entT2[i]:GetKills()
                            if(ply:GetDBSetting() == true) then
                                ply:ChatPrint("DEBUG:Party Member " .. entT2[i]:GetName() .. " has: ".. entT2[i]:GetKills() .. " kills.")
                            end
                            pKills = pKills + tkills
                            tkills = 0
                        elseif(entT2[i]:GetKills() > 0 and !timer.Exists("ComboChain" .. entT2[i]:UserID()))then --Dead Combo!
                            tkills = entT2[i]:GetKills()
                            tKill2 = pKills + tkills / 2
                                if(ply:GetDBSetting() == true) then
                                    ply:ChatPrint("DEBUG:Party Member " .. entT2[i]:GetName() .. " had: ".. tkills .. " kills halved for non-active Combo. K: " .. tKill2)
                                end
                            pKills = pKills + tKill2
                            tkills = 0
                        end
                        local skillp = entT2[i]:GetSkills()
                        if(skillp != nil and table.HasValue(skillp,"2x")) then
                            partyXPskill = true
                            if(ply:GetDBSetting() == true) then
                                ply:ChatPrint("2x XP from party active!")
                            end 
                        end
                    end
                end
            end
        end

        local pkTotal = pKills + killM
        if(pkTotal < 10) then
            --do nothing
        else
            if(pKills > 0)then
                killM = pkTotal / 2
                if(ply:GetDBSetting() == true)then
                    ply:ChatPrint("DEBUG:Your Party Combo Kill Total: " .. pKills)
                    local ntxt = "(" .. pkTotal .. ")"
                    ply:ChatPrint("DEBUG:Final Combo Kill Total 10+ " ..  ntxt .. " Total Halved: " .. killM)
                end
            end
        end
    end
   
    local FincomboXP = comboXP * chainM
    local total = math.Round(FincomboXP, 0)
    local skillt = ply:GetSkills()
    --PRESTIGE SKILLS CHECK / RESET
    if(skillt != nil and table.HasValue(skillt,"hfc")) then
        hct = ply:GetHFTC()
        nFincomboXP = total * hct
        total = nFincomboXP
    end
    if(skillt != nil and table.HasValue(skillt,"2x")) then
        total = total * 2.0
        if(ply:GetDBSetting() == true) then
         ply:ChatPrint("2x XP Active! XP total: " .. total .. "xp")
        end 
    end
    if(skillt != nil and table.HasValue(skillt,"CS") and ply:shCCheck() == false) then
        ply:ChatPrint("Substitution Ready!")
        ply:shCSet(true)
    end
    if(skillt != nil and table.HasValue(skillt,"shC")) then
        local arm = ply:Armor()
        if(arm == 0) then
            local narm = 2 * worldP
            local carm = pChain * 2
            local tarm = carm + narm
            ply:SetArmor(tarm)
            if(ply:GetDBSetting() == true) then
                ply:ChatPrint("Combo Shield Created: " .. tarm .. " armour.")
            end 
        else
            local narm = 2 * worldP
            local carm = pChain * 2
            local tarm = carm + narm
            tarm = tarm + arm
            ply:SetArmor(tarm)
            if(ply:GetDBSetting() == true) then
                ply:ChatPrint("Combo Shield Created: " .. tarm .. " armour.")
            end 
        end
    end
    if(skillt != nil and table.HasValue(skillt,"tBt")) then
        local og = ply:GetOGSpeed()
        ply:SetMaxSpeed(og)
        if(ply:GetDBSetting() == true) then
            ply:ChatPrint("Speed Reset.")
        end 
    end
    if(skillt == nil) then
        if(ply:GetDBSetting() == true) then
            ply:ChatPrint("skilltree not loaded!")
       end
    end
    if(partyXPskill == true)then
        total = total * 1.5
    end
    
    ply:SetXP(tonumber(total))
    if(ply:MPGet() == true) then
        RefreshLockedPanel(ply)
    end
    updateWrldProg()
    local txt = "+" .. total .. "xp earned."
    ply:PrintMessage(HUD_PRINTTALK,txt)
    ply:EmitSound("concrete_impact_bullet2.wav")
    timer.Remove("ComboChain" .. ply:UserID())
    ply:SetCombo(0)
    ply:SetKills(0)
    --ply:SendKills(0,ply)
    local totalxp = getplysXP()
    SendPlyXP(ply:GetXP(), ply)
    SendPlyInfo(ply:GetCombo(),ply)
    TotalXpRefresh(totalxp)
    sendWrldData()
end

function ComboMultiplySet(combo)
    local chainM = 0.5
    if(chainM <= 1) then
        chainM = 1.0
    elseif(chainM == 2) then
     chainM = 1.5
    elseif(chainM == 3) then
        chainM = 2.0
    elseif(chainM == 4) then
        chainM = 2.5
    elseif(chainM == 5) then
        chainM = 3.0
    elseif(chainM == 6) then
     chainM = 3.5
    elseif(chainM == 7) then
        chainM = 4.0
    elseif(chainM == 8) then
        chainM = 4.5
    elseif(chainM == 9) then
        chainM = 5.0
    end
    return chainM
    --create switch case function in the future
end

--Player Prestige
function prestigeCal()
    if(prestigeSystem == true)then
        worldP = worldP + 1
        worldL = 1
        if(worldL != 1)then
            worldL=1
        end
        local totalxp = getplysXP()
        --inital
        local txt = "The World has changed abnormally... " .. "Prestige Level Has Increased To: " .. worldP
        for i, ply in ipairs(player.GetAll()) do
            --add tokens
            local oplyPT = 0
            if(ply:GetTokens() == nil or ply:GetTokens() < 0) then
                if(ply:GetDBSetting() == true) then
                    ply:ChatPrint("Prestige token error, they have been reset!")
                end
                oplyPT = 0
            else
                oplyPT = ply:GetTokens()
            end
            local nplyPT = oplyPT + 1
            ply:ChatPrint("+1 Prestige Token. " .. "Total: " .. nplyPT)
            ply:ChatPrint(txt)
            ply:SaveTokens(nplyPT)
            SendPTokens(nplyPT,ply)
            if(ply:MPGet() == true) then
                RefreshLockedPanel(ply)
            end
        end
        ResetAllXP()
        updateWrldProg()
        sendWrldData()
    else
    end
end

--CHAT COMMANDS
hook.Add("PlayerSay", "LvlCheck", function(ply, strText, team)
    if(strText == "/wp") then
        local set = tobool(ply:GetDBSetting())
        local set2 = tobool(ply:GetPPSetting())
        local xpparty = tostring(ply:GetParty())
        local pxp = tonumber(ply:GetVar("XPS"))
        local pt = 0
        pt = ply:GetTokens()
        Sendallparty(ply)
        SendParty(xpparty,ply)
        if(set == nil) then
            set = false
            ply:SaveDBSetting(set)
        end
        if(set2 == nil) then
            set2 = false
            ply:SavePPSetting(set2)
        end
        SendPlyXP(pxp, ply)
        SendDSettings(set, ply)
        SendPSettings(set2, ply)
        SendPTokens(pt,ply)
        openParty(ply)
    end
end)

function updateWrldProg()
    --Player XP Check for Increase
    local total = getplysXP()
    if(total < 0) then
        total = 0
    end
    if(total >= worldXP) then
        local nT = total - worldXP
        wXPTotal = wXPTotal + total
        if(diffi == 1)then
            comboTime = comboTime + 1.5
            wXPLoss = wXPLoss - 30
        elseif(diffi == 2)then
            comboTime = comboTime + 1.0
            wXPLoss = wXPLoss - 35
        elseif(diffi == 3)then
            comboTime = comboTime + 0.5
            wXPLoss = wXPLoss - 50
        elseif(diffi == 0) then
            --Leave custom values
            comboTime = comboTime + 0.5
        end
        worldL= worldL+ 1
        if(worldL>= 6)then
            if(prestigeSystem == true) then
                prestigeCal()
            end
        end

        for i, ply in ipairs(player.GetAll()) do
         ply:ChatPrint("The world has grown stronger...")
         ply:ChatPrint("Combo start time has increased to " .. comboTime .. "s.")
         ply:EmitSound("buttons/blip1.wav")
            if(ply:MPGet() == true) then
                RefreshLockedPanel(ply)
            end
        end

        local nXP = 0
        if(diffi == 1)then
            nXP = worldL * 120
        elseif(diffi == 2)then
            nXP = worldL * 240
        elseif(diffi == 3)then
            nXP = worldL * 300
        end

        local p = 0
        if(worldP > 0) then
            p = nXP * worldP * 1.5
            worldXP = p
        else
            worldXP = nXP
        end

        if(nT > worldXP) then
            updateWrldProg()
        else
             if(nT > 0 && nT < worldXP)then
                ResetAllXP()
                 for i, ply in ipairs(player.GetAll()) do
                     ply:SetVar("XPS",nT)
                 end
             end
        end
    end

    sendWrldData()
    if(PVPMode == true)then
        refreshtop5()
    end
end

--Player Checks
function getplysXP()
    local total = 0
    for i, ply in ipairs(player.GetAll()) do
        local pxp = 0
        pxp = ply:GetVar("XPS")
        if(pxp == nil) then
            pxp = 0
        end
        total = total + pxp
    end
    return tonumber(total)
end

function ResetAllXP()
    for i, ply in ipairs(player.GetAll()) do
        ply:SetVar("XPS",0)
        ply:SetXP(0)
        ply:SendHint("(WORLD PROG) XP Reset!", 1)
    end
    if(PVPMode == true)then
        refreshtop5()
    end
    sendWrldData()
end

function refreshtop5()
    local score = 0
    local score2 = 0
    local score3 = 0
    local score4 = 0
    local score5 = 0
    PVPtop = {"N/A","N/A","N/A","N/A","N/A"}

    for i, ply in ipairs(player.GetAll()) do
        local pxp = 0
        pxp = ply:GetVar("HSXP")
        if(pxp == nil) then
            pxp = 0
        end

        if(score == 0)then
            PVPtop[0] = ply:GetName()
        elseif(score2 == 0) then
            PVPtop[1] = ply:GetName()
        elseif(score3 == 0) then
            PVPtop[2] = ply:GetName()
        elseif(score4 == 0)then
            PVPtop[3] = ply:GetName()
        elseif(score5 == 0)then
            PVPtop[4] = ply:GetName()
        end

        if(pxp > score)then
            if(ply:GetName() != PVPtop[0])then
                ply:ChatPrint(ply:GetName() .. " has passed " .. PVPtop[0])
            end
            score = pxp
            PVPtop[0] = ply:GetName()
        elseif(pxp > score2)then
            if(ArrayContains(PVPtop,ply:GetName()) && pxp <= score2) then
                -- do nothing since they up alr we not
            else
                if(ply:GetName() != PVPtop[1])then
                    ply:ChatPrint(ply:GetName() .. " has passed " .. PVPtop[1])
                end
                score2 = pxp
                PVPtop[1] = ply:GetName()
            end
        elseif(pxp > score3)then
            if(ArrayContains(PVPtop,ply:GetName()) && pxp <= score3) then

            else
                if(ply:GetName() != PVPtop[2])then
                    ply:ChatPrint(ply:GetName() .. " has passed " .. PVPtop[2])
                end
                score3 = pxp
                PVPtop[2] = ply:GetName()
            end
            
        elseif(pxp > score4)then
            if(ArrayContains(PVPtop,ply:GetName()) && pxp <= score4) then

            else
                if(ply:GetName() != PVPtop[3])then
                    ply:ChatPrint(ply:GetName() .. " has passed " .. PVPtop[3])
                end
                score4 = pxp
                PVPtop[3] = ply:GetName()
            end

        elseif(pxp > score5)then
            if(ArrayContains(PVPtop,ply:GetName()) && pxp <= score5) then

            else
                if(ply:GetName() != PVPtop[4])then
                    ply:ChatPrint(ply:GetName() .. " has passed " .. PVPtop[4])
                end
                score5 = pxp
                PVPtop[4] = ply:GetName()
            end
        end
    end

    net.Start("SendTop5")
    net.WriteString(PVPtop[0] .. " - " .. score .. "xp")
    net.WriteString(PVPtop[1] .. " - " .. score2 .. "xp")
    net.WriteString(PVPtop[2] .. " - " .. score3 .. "xp")
    net.WriteString(PVPtop[3] .. " - " .. score4 .. "xp")
    net.WriteString(PVPtop[4] .. " - " .. score5 .. "xp")
    net.Broadcast()
end

function ComboKillCheck(kills, ply)
    local nChain = 0
    if(kills <= 2) then
        nChain = 1
    end
    if(kills > 2) then
        nChain = 1.5
    end
    if(kills > 4) then
        nChain = 2
    end
    if(kills > 6) then
        nChain = 2.5
    end
    if(kills >= 10)then
        nChain = 3
    end
    if(kills >= 14)then
        nChain = 4
    end
    if(kills >= 22)then
        nChain = 5
    end
    if(kills >= 30)then
        nChain = 6
    end
    if(kills >= 50)then
        nChain = 7
    end
    if(kills >= 75)then
        nChain = 8
    end
    if(kills >= 120)then
        nChain = 9
    end
    if(kills > 200)then
        nChain = 10
    end
    if(kills > 500)then
        nChain = 15
    end
    return nChain
end

function sendWrldData()
    local total = getplysXP()
    TotalXpRefresh(total)
    net.Start("WLVL")
    net.WriteInt(worldL,32)
    net.WriteInt(worldXP,32)
    net.WriteInt(diffi,32)
    net.WriteBool(PVPMode)
    net.Broadcast()

    if(worldP >= 0 ) then
        net.Start("WPRESTIGE")
        net.WriteInt(worldP,32)
        net.Broadcast()
    end
end

function SendPlyInfo(chain, ply)
    net.Start("DrawCombo")
    net.WriteFloat(chain, 32)
    net.WriteEntity(ply)
    net.Send(ply)
end

function SendPlyXP(xp, ply)
    xp = tonumber(xp)
    net.Start("SendXP")
    net.WriteInt(xp,32)
    local hsx = tonumber(ply:GetVar("HSXP"))
    if (hsx == nil) then
        hsx =0
    end
    net.WriteInt(hsx,32)
    net.Send(ply)
end

function SendPlySSetting(bool, ply)
    net.Start("SSet")
    net.WriteBool(bool)
    net.Send(ply)
end

function UpdatePlyHud(time, ply)
    net.Start("DrawTime")
    net.WriteFloat(time)
    net.WriteEntity(ply)
    net.Send(ply)
end

function SendnpcLvl(lvl,ply)
    net.Start("DrawNPClvl")
    net.WriteInt(lvl, 32)
    net.WriteEntity(ply)
    net.Send(ply)
end

function SendComboInfo(kills,time,chain,ply)
    net.Start("DrawPlyCT")
    net.WriteInt(kills, 32)
    net.WriteInt(time, 32)
    net.WriteInt(chain, 32)
    net.WriteEntity(ply)
    net.Send(ply)
end

function TotalXpRefresh(xp)
    net.Start("XPTotal")
    net.WriteInt(xp, 32)
    net.WriteInt(tonumber(wXPTotal), 32)
    net.Broadcast()
end

function HudClear()
    net.Start("HUDClear")
    net.Broadcast()
end

function UpdatePlyTimer(x,ply)
    net.Start("CT_Update")
    net.WriteFloat(x)
    net.Send(ply)
end

function openParty(ply)
    net.Start("PartyUI")
    net.Send(ply)
end

function SendParty(party,ply)
    net.Start("PartyInfo")
    net.WriteString(party)
    net.Send(ply)
end

function SendKills(kills, ply)
    local hs = tonumber(ply:GetVar("HSKills"))
    net.Start("killTotal")
    net.WriteInt(kills,32)
    net.WriteInt(hs,32)
    net.Send(ply)
end

function SendDSettings(debugS, ply)
    net.Start("DebugS")
    net.WriteBool(debugS)
    net.Send(ply)
end

function SendPSettings(partyS, ply)
    net.Start("PartyS")
    net.WriteBool(partyS)
    net.Send(ply)
end

function SendPTokens(tokens, ply)
    net.Start("PresTok")
    net.WriteInt(tokens,32)
    net.Send(ply)
end

function SendPSkills(ply)
    local stree = ply:GetSkills()
    if (stree == nil) then
        local skilltree = {
            [1] = nil,
            [2] = nil,
            [3] = nil,
            [4] = nil,
        }
        stree = skilltree
    end

    net.Start("PresSkillGet")
    net.WriteTable(stree)
    net.Send(ply)
end

function Sendallparty(ply)
    local PartyTable = {}
    for i, plyx in ipairs(player.GetAll()) do
         if(plyx:GetParty() != "" or plyx:GetParty() != nil) then
            local x = tostring(plyx:GetParty())
            if(table.HasValue(PartyTable,x) == true)then
                -- Dont add dupe party!
            else
                table.insert(PartyTable,tostring(x))
            end
         end
    end

    net.Start("Allparties")
    net.WriteTable(PartyTable)
    net.Send(ply)
end

function Sendpartyply(party, ply)
    local MemberTable = {}
    local MXPTable = {}
    local MKillTable = {}
    for i, plyx in ipairs(player.GetAll()) do
        if(plyx:GetParty() == party) then
            if(table.HasValue(MemberTable,plyx) == false) then
                local pname = plyx:GetName()
                if(pname == nil) then
                    pname = "Member#".. tostring(i)
                end
                table.insert(MemberTable,pname)
                table.insert(MXPTable,plyx:GetXP())
                table.insert(MKillTable,plyx:GetVar("HSKills"))
            end
        end
    end

    net.Start("Allmembers")
    net.WriteTable(MemberTable)
    net.WriteTable(MXPTable)
    net.WriteTable(MKillTable)
    net.Send(ply)
end

function RefreshLockedPanel(ply)
    SendPlyXP(ply:GetXP(), ply)
    SendKills(ply:GetKills(),ply)
    if(PVPMode == true)then
        refreshtop5()
    end

    net.Start("MiniPan")
    net.Send(ply)
end

--Stores world and player functions and etc
function ply:SetKills(n)
    self:SetVar("Kills", n)
end
function ply:GetKills()
    if (self:GetVar("Kills") == nil) then
        self:SetKills(0)
        if(self:GetVar("HSKills") == nil)then
            self:SetVar("HSKills", 0)
        end
    end
    return self:GetVar("Kills")
end

function ply:UpdateHSKills() --Highscore Kills
    local newh = 0
    local hs = self:GetVar("HSKills")
    if(hs == nil or hs < 0)then
        hs = 0
    end
    newh = hs + 1
    self:SetVar("HSKills", newh)
end

function ply:GetHFT()
    return self:GetNWString("HFT")
end
function ply:SetHFT(n)
    self:SetNWString("HFT", n)
end

function ply:GetHFTC()
    return self:GetNWFloat("HFTC")
end
function ply:SetHFTC(n)
    self:SetNWFloat("HFTC", n)
end

function ply:SetCombo(n)
    self:SetPData("Combo", n)
end
function ply:GetCombo()
    if (self:GetPData("Combo") == nil) then
        self:SetPData("Combo", 0)
        self:SetNWFloat("Combo", 0)
    end
    return self:GetPData("Combo")
end

function ply:SavePWSetting(n)
    self:SetPData("SSet", n)
end
function ply:GetSavePWSetting()
    if (self:GetPData("SSet") == nil) then
        self:SetPData("SSet", false)
        self:SetNWBool("SSet", false)
    end
    return self:GetPData("SSet")
end

function ply:SaveDBSetting(setting)
    self:SetPData("DebugSettings", setting)
    self:SetNWBool("DebugSettings", setting)
end
function ply:GetDBSetting()
    if (self:GetPData("DebugSettings") == nil) then
        self:SetPData("DebugSettings", false)
        self:SetNWBool("DebugSettings", false)
    end

    return tobool(self:GetPData("DebugSettings"))
end

function ply:SavePPSetting(setting)
    self:SetPData("PartySettings", setting)
    self:SetNWBool("PartySettings", setting)
end
function ply:GetPPSetting()
    if (self:GetPData("PartySettings") == nil) then
        self:SetPData("PartySettings", false)
        self:SetNWBool("PartySettings", false)
    end

    return tobool(self:GetPData("PartySettings"))
end

function ply:SaveParty(n)
    self:SetPData("PParty", n)
    self:SetNWString("PParty", n)
end
function ply:GetParty()
    if (self:GetPData("PParty") == nil) then
        self:SetPData("PParty", "")
        self:SetNWString("PParty", "")
    end
    return tostring(self:GetPData("PParty"))
end

function ply:SaveTokens(n)
    self:SetVar("perT", n)
end
function ply:GetTokens()
    if (self:GetVar("perT") == nil) then
        self:SetVar("perT", 0)
    end

    return self:GetVar("perT")
end

function ply:SetOGSpeed(n)
    self:SetVar("ogSpeed", n)
end
function ply:GetOGSpeed()
    return self:GetVar("ogSpeed")
end

function ply:SaveSkills(n)
    self:SetVar("pSkills", n)
end
function ply:GetSkills()
    local tTree = self:GetVar("pSkills")
    if (tTree == nil) then
       local skilltree = {
            [1] = nil,
            [2] = nil,
            [3] = nil,
            [4] = nil,
        }
        self:SaveSkills(skilltree)
        tTree = skilltree
    end
    return self:GetVar("pSkills")
end

function ply:shCCheck()
    return self:GetVar("pshC")
end
function ply:shCSet(b)
    self:SetVar("pshC", b)
end

function ply:MPGet()
    return self:GetVar("MPS")
end
function ply:MPSet(b)
    self:SetVar("MPS", b)
end

function ply:SetXP(n)
    local x = self:GetVar("HSXP")
    local y = self:GetVar("XPS")
    if (x == nil) then
        x = 0
    end
    x = n + x
    y = y + n
    self:SetVar("HSXP", x)
    self:SetVar("XPS",y)
end
function ply:GetXP()
    if (self:GetVar("XPS") == nil) then
        self:SetVar("XPS",0.0)
    end
    return self:GetVar("XPS")
end

function ply:WrldSave()
    self:SetVar("pwrlddiffi", diffi)
end

function ply:WrldLevel()
    local worldL = net.Receive("WLVL", function() 
     return worldL
    end)
end

net.Receive("PartyCName", function()
    local pname = net.ReadString()
    local ply = net.ReadEntity()
    if(pname == nil or pname == "") then
        pname = "No party."
        ply:SaveParty(pname)
        local htxt = "(WORLD PROG) Now in ".. tostring(pname)
        ply:SendHint(htxt, 0)
    else
        ply:SaveParty(pname)
        local htxt = "(WORLD PROG) Now in party: ".. tostring(pname)
        ply:SendHint(htxt, 0)
    end
end)

net.Receive("DebugS", function()
    local setting = net.ReadBool()
    local plyx = net.ReadEntity()
    if(IsValid(plyx)) then
        if(setting == true)then
            plyx:SaveDBSetting(true)
            plyx:PrintMessage(3,"Debug Mode enabled.")
        else
            plyx:SaveDBSetting(false)
            plyx:PrintMessage(3,"Debug Mode disabled.")
        end
    end
end)

net.Receive("PartyS", function()
    local setting = net.ReadBool()
    local plyx = net.ReadEntity()
    if(IsValid(plyx)) then
        if(setting == true)then
            plyx:SavePPSetting(true)
            plyx:PrintMessage(3,"Party Mode enabled.")
        else
            plyx:SavePPSetting(false)
            plyx:PrintMessage(3,"Party Mode disabled.")
        end
    end
end)

net.Receive("ResetPly", function()
    local admin = net.ReadEntity()
    if(admin:IsAdmin()) then
        ResetAllXP()
        for i, ply in ipairs(player.GetAll()) do
            local text = admin:GetName() .. " has reset all players!"
            ply:ChatPrint("(WORLD PROG) " .. text)
        end
    else
        admin:ChatPrint("(WORLD PROG): you cannot reset player stats unless you're a admin.")
    end
end)

net.Receive("resetSkills", function()
    local plyx = net.ReadEntity()
    local tTree = plyx:GetVar("pSkills")
    local total = 0
    local nskilltree = {}
    if (tTree == nil) then
        nskilltree = {
            [0] = nil,
            [1] = nil,
            [2] = nil,
            [3] = nil,
            [4] = nil,
        }
    else
        if(ArrayContains(tTree,"vamp"))then
            total = total+3
        elseif(ArrayContains(tTree,"coh")) then
            total = total+2
        elseif(ArrayContains(tTree,"2x")) then
            total = total+2
        elseif(ArrayContains(tTree,"shC"))then 
            total = total+2
        else
            total = total+1
        end
        nskilltree = {
            [0] = nil,
            [1] = nil,
            [2] = nil,
            [3] = nil,
            [4] = nil,
        }
    end
    plyx:SaveSkills(nskilltree)
    plyx:SetVar("XPS",0)

    local xt = plyx:GetTokens()
    local t = xt + total
    plyx:SaveTokens(t-1)
    SendPTokens(t-1,plyx)
    SendPSkills(plyx)
    plyx:ChatPrint("(WORLD PROG): Prestige Skills Have Been Reset.")
end)


net.Receive("npcHelp", function()
    local n = net.ReadBool()
    local admin = net.ReadEntity()
    NPCHelp = n
    if(admin:IsAdmin()) then
        for i, ply in ipairs(player.GetAll()) do
            local text = "NPC Timer Assist set to " .. tostring(n)
            ply:ChatPrint(text)
        end
    else
        admin:ChatPrint("you cannot change NPC status unless you're a admin.")
    end
end)

net.Receive("SaveWrld", function()
    local admin = net.ReadEntity()
    if(admin:IsAdmin()) then
        admin:WrldSave()
        admin:ChatPrint("World Data saved.")
    else
        admin:ChatPrint("you cannot save this world unless you're a admin.")
    end
end)

net.Receive("LoadWrld", function()
    local admin = net.ReadEntity()
    if(admin:IsAdmin()) then
        local x = tonumber(admin:GetVar("pwrldLvl", worldL))
        worldL = x
        local x1 = tonumber(admin:GetVar("pwrldXP",worldXP))
        worldXP = x1
        local x2 = tonumber(admin:GetVar("pwrldXPT",wXPTotal))
        wXPTotal = x2
        local x3 = tonumber(admin:GetVar("pwrldXPL",wXPLoss))
        wXPLoss = x3
        local x4 = tonumber(admin:GetVar("pwrldCTime",comboTime))
        comboTime = x4
        local x5 = admin:GetVar("pwrlddiffi",diffi)
        diffi = x5
        local x6 = tonumber(admin:GetVar("pwrldp",worldP))
        worldP = x6

        for i, ply in ipairs(player.GetAll()) do
            local text = admin:GetName() .. " has loaded thier world save."
            ply:ChatPrint(text)
        end
        updateWrldProg()
        sendWrldData()
    else
        admin:ChatPrint("you cannot load a world unless you're a admin.")
    end
end)

net.Receive("DefWrld", function()
    local admin = net.ReadEntity()
    if(admin:IsAdmin()) then
        comboTime = 30
        wXPLoss = -50
        diffi = 2
        if(worldL > 1)then
            local multi = worldL
            multi = multi * 0.5
            comboTime = comboTime + multi
        end
        admin:ChatPrint(admin:GetName() .. " has restored default settings.")
    else
        admin:ChatPrint("you cannot default this world unless you're a admin.")
    end
end)

net.Receive("uiSend", function()
    local ply = net.ReadEntity()
    local xpparty = tostring(ply:GetParty())
    local pxp = tonumber(ply:GetVar("XPS"))
    local set = tobool(ply:GetDBSetting())
    local set2 = tobool(ply:GetPPSetting())
    Sendallparty(ply)
    SendParty(xpparty,ply)
    SendPlyXP(pxp, ply)
    SendDSettings(set, ply)
    SendPSettings(set2, ply)
    openParty(ply)
end)

net.Receive("plyCSettings", function()
    local plyx = net.ReadEntity()
    net.Start("PlySettings")
    net.WriteBool(plyx:GetDBSetting())
    net.WriteBool(plyx:GetPPSetting())
    net.WriteEntity(plyx)
    net.Send(plyx)
end)

net.Receive("refreshWUI", function()
    local ply = net.ReadEntity()
    local xpparty = tostring(ply:GetParty())
    local pxp = tonumber(ply:GetVar("XPS"))
    local set = tobool(ply:GetDBSetting())
    local set2 = tobool(ply:GetPPSetting())
    Sendallparty(ply)
    SendParty(xpparty,ply)
    SendPlyXP(pxp, ply)
    SendDSettings(set, ply)
    SendPSettings(set2, ply)
    openParty(ply)
end)

net.Receive("refreshLWUI", function()
    local ply = net.ReadEntity()
    local xpparty = tostring(ply:GetParty())
    local pxp = tonumber(ply:GetVar("XPS"))
    local set = tobool(ply:GetDBSetting())
    local set2 = tobool(ply:GetPPSetting())
    Sendallparty(ply)
    SendParty(xpparty,ply)
    SendPlyXP(pxp, ply)
    SendDSettings(set, ply)
    SendPSettings(set2, ply)
end)

net.Receive("refreshPUI", function()
    local ply = net.ReadEntity()
    local skilltree = ply:GetSkills()
    local ptk = tonumber(ply:GetTokens())
    SendPTokens(ptk,ply)
    SendPSkills(ply)
end)

net.Receive("Sendmem", function()
    local pname = net.ReadString()
    local ply = net.ReadEntity()
    Sendpartyply(pname, ply)
end)

net.Receive("WorldDiff", function()
    local ply = net.ReadEntity()
    local sentdif = net.ReadString()

    if(ply:IsAdmin())then
        if(sentdif == "Easy") then
            diffi = 1
            ply:SetVar("pwrlddiffi",diffi)
            for i, plyx in ipairs(player.GetAll()) do
                local text = "World Difficulty Has Been Changed To Easy."
                plyx:PrintMessage(3,text)
            end
            worldXP = worldL * 120
        elseif(sentdif == "Norm" or sentdif == "norm") then
            diffi = 2
            ply:SetVar("pwrlddiffi",diffi)
            for i, plyx in ipairs(player.GetAll()) do
                local text = "World Difficulty Has Been Changed To Normal."
                plyx:PrintMessage(3,text)
            end
            worldXP = worldL * 250
        elseif(sentdif == "Hard") then
            diffi = 3
            ply:SetVar("pwrlddiffi",diffi)
            for i, plyx in ipairs(player.GetAll()) do
                local text = "World Difficulty Has Been Changed To Hard."
                plyx:PrintMessage(3,text)
            end
            worldXP = worldL * 300
        else
            local text = "World Difficulty Failed To Update."
            plyx:PrintMessage(3,text)
        end
    else
        ply:ChatPrint("You Must Be A Admin To Change Difficulty.")
    end
    updateWrldProg()
    sendWrldData()
end)

net.Receive("GetPSSkills", function()
    local ply = net.ReadEntity()
    SendPSkills(ply)
end)

net.Receive("PresTok", function()
    local tokens = net.ReadInt()
    local ply = net.ReadEntity()
    ply:SaveTokens(tokens)
    local tok = ply:GetTokens()
    SendPTokens(tok,ply)
end)

net.Receive("LockedS", function()
    local setting = net.ReadBool()
    local ply = net.ReadEntity()
    ply:MPSet(setting)
end)

net.Receive("PresSys", function()
    local setting = net.ReadBool()
    local ply = net.ReadEntity()
    if(ply:IsAdmin()) then
        prestigeSystem = setting
        if(prestigeSystem == true) then
            for i, plyx in ipairs(player.GetAll()) do
                local text = ply:GetName() .. " has set worldP mode to " .. tostring(prestigeSystem)
                plyx:PrintMessage(3,text)
            end
            updateWrldProg()
        else
            for i, plyx in ipairs(player.GetAll()) do
                local text = ply:GetName() .. " has set worldP mode to " .. tostring(prestigeSystem)
                plyx:PrintMessage(3,text)
            end
        end
    else
        ply:ChatPrint("you cannot default this world unless you're a admin.")
    end
end)

net.Receive("PresSkillSet", function()
    local skill = net.ReadString()
    local ply = net.ReadEntity()
    local skilltree = {}
    skilltree = ply:GetSkills()
    table.insert(skilltree,skill)
    ply:SaveSkills(skilltree)
    if(skill == "shC") then
        ply:shCSet(true)
    elseif(skill == "tBt") then
      ply:SetOGSpeed(ply:GetMaxSpeed())
    end
end)

net.Receive("sentTok", function()
    local ntok = net.ReadInt(32)
    local ply = net.ReadEntity()
    ply:SaveTokens(ntok)
end)

net.Receive("pvpSetting", function()
    local setting = net.ReadBool()
    local ply = net.ReadEntity()
    if(ply:IsAdmin())then
        PVPMode = setting
        if(PVPMode == true) then
            for i, plyx in ipairs(player.GetAll()) do
                local text = ply:GetName() .. " has set PVP mode to " .. tostring(PVPMode)
                local text2 = "While Vs Mode is active, Vs Mini panel is available from WorldProg Panel."
                plyx:PrintMessage(3,text)
                plyx:PrintMessage(3,text2)
            end
            updateWrldProg()
        else
            for i, plyx in ipairs(player.GetAll()) do
                local text = ply:GetName() .. " has set PVP mode to " .. tostring(PVPMode)
                plyx:PrintMessage(3,text)
            end
        end
    else
        ply:ChatPrint("you cannot change this unless you're a admin.")
    end
end)

net.Receive("wpbind", function()
    local ply = net.ReadEntity()
    local set = tobool(ply:GetDBSetting())
    local set2 = tobool(ply:GetPPSetting())
    local xpparty = tostring(ply:GetParty())
    local pxp = tonumber(ply:GetVar("XPS"))
    local pt = ply:GetTokens()
    Sendallparty(ply)
    SendParty(xpparty,ply)
    if(set == nil) then
        set = false
        ply:SaveDBSetting(set)
    end
    if(set2 == nil) then
        set2 = false
        ply:SavePPSetting(set2)
    end
    SendPlyXP(pxp, ply)
    SendDSettings(set, ply)
    SendPSettings(set2, ply)
    SendPTokens(pt,ply)
    openParty(ply)
end)

--CONSOLE COMMANDS
concommand.Add("wp_reset", function (ply)
    local admin = ply
    if(admin:IsAdmin()) then
        for i, plyx in ipairs(player.GetAll()) do
            local text = "Resetting World. Prev Level Was " .. worldL .. ". Prestige: " .. worldP
            plyx:PrintMessage(3,text)
        end
        worldL= 1
        worldXP = 150
        wXPTotal = 0
        worldP = 0
        updateWrldProg()
        sendWrldData()
        HudClear()
        ResetAllXP()
        if(worldP != 0)then
            worldP = 0
        end
    else
        admin:PrintMessage(2,"you cannot reset this world unless you're a admin.")
    end
end)

concommand.Add("wp_token+", function (ply)
    if(ply:IsAdmin()) then
        for i, plyx in ipairs(player.GetAll()) do
            local oplyPT = 0
            if(plyx:GetTokens() != nil) then
                oplyPT = tonumber(plyx:GetTokens())
            end
            local nplyPT = oplyPT + 1
            plyx:SaveTokens(nplyPT)
            plyx:PrintMessage(3,"+1 Prestige Token. " .. "Total: " .. tonumber(plyx:GetTokens()))
            SendPTokens(plyx:GetTokens(),plyx)
        end
    else
        ply:ChatPrint("Must be admin to use this command.")
    end
end)

concommand.Add("wp_token-", function (ply)
    if(ply:IsAdmin()) then
        for i, plyx in ipairs(player.GetAll()) do
            local oplyPT = 0
            if(plyx:GetTokens() != nil) then
                oplyPT = tonumber(plyx:GetTokens())
                local nplyPT = oplyPT - 1
                plyx:SaveTokens(nplyPT)
                plyx:PrintMessage(3,"-1 Prestige Token. " .. "Total: " .. tonumber(plyx:GetTokens()))
                SendPTokens(plyx:GetTokens(),plyx)
            else

            end
        end
    else
        ply:ChatPrint("Must be admin to use this command.")
    end
end)

concommand.Add("wp_world+", function (ply)
    if(ply:IsAdmin()) then
        worldL = worldL + 1
        if(diffi == 1)then
            nXP = worldL * 120
        elseif(diffi == 2)then
            nXP = worldL * 240
        elseif(diffi == 3)then
            nXP = worldL * 300
        end
        worldXP = nXP
        updateWrldProg()
        sendWrldData()
        for i, plyx in ipairs(player.GetAll()) do
            local txt2 = "World level has increased to: " .. worldL
            plyx:PrintMessage(3,txt2)
        end
    else
        local txt2 = "You must be Admin to use this command."
        return ply:PrintMessage(2,txt2)
    end
end)

concommand.Add("wp_world-", function (ply)
    if(ply:IsAdmin()) then
        if(worldL> 1) then
            worldL= worldL- 1
            if(diffi == 1)then
                nXP = worldL* 120
            elseif(diffi == 2)then
                nXP = worldL* 240
            elseif(diffi == 3)then
                nXP = worldL* 300
            end
            worldXP = nXP
            updateWrldProg()
            sendWrldData()
            for i, plyx in ipairs(player.GetAll()) do
                local txt2 = "World level has decreased to: " .. worldL
                plyx:PrintMessage(2,txt2)
            end
        else
            local txt2 = "World level is too low to change"
            ply:PrintMessage(3,txt2)
        end
    else
        local txt2 = "You must be Admin to use this command."
        return ply:PrintMessage(2,txt2)
    end
end)

concommand.Add("wp_prestige+", function (ply)
    if(ply:IsAdmin()) then
        prestigeCal()
    else
        local txt2 = "You must be Admin to use this command."
        return ply:PrintMessage(3,txt2)
    end
end)

concommand.Add("wp_prestige-", function (ply)
    if(ply:IsAdmin()) then
       if(worldP > 0) then
         worldP = worldP - 1
            for i, plyx in ipairs(player.GetAll()) do
                local txt2 = "Prestige level has decreased to: " .. worldP
                plyx:PrintMessage(3,txt2)
            end
         updateWrldProg()
         sendWrldData()
       else
        local txt2 = "Prestige level is already 0."
        ply:PrintMessage(3,txt2)
       end
    else
        local txt2 = "You must be Admin to use this command."
        return ply:PrintMessage(3,txt2)
    end
end)

concommand.Add("wp_stop", function (ply)
    if(timer.Exists("ComboChain" .. ply:UserID()))then
        timer.Remove("ComboChain")
        XpCal(ply)
        updateWrldProg()
        UpdatePlyTimer(0,ply)
        HudClear()
        ply:PrintMessage(2,"Combo Time has been stopped.")
    else
        ply:PrintMessage(2,"No active combo timer!")
    end
end)

concommand.Add("wp_debug", function (ply)
    if(ply:GetDBSetting() == false)then
        ply:SaveDBSetting(true)
        ply:PrintMessage(2,"Debug Mode enabled.")
    else
        ply:SaveDBSetting(false)
        ply:PrintMessage(2,"Debug Mode disabled.")
    end
end)

concommand.Add("wp_party", function (ply)
    if(ply:GetPPSetting() == false)then
        ply:SavePPSetting(true)
        ply:PrintMessage(2,"Party Mode enabled.")
    else
        ply:SavePPSetting(false)
        ply:PrintMessage(2,"Party Mode disabled.")
    end
end)

concommand.Add("wp_combo", function (ply)
    if(ply:IsAdmin()) then
        if(comboSystem)then
            comboSystem = false
        else
            comboSystem = true
        end
     else
         local txt2 = "You must be Admin to use this command."
         return ply:PrintMessage(3,txt2)
     end
end)

concommand.Add("wp_vs", function (ply)
    if(ply:IsAdmin())then
        if(PVPMode != true)then
            PVPMode = true
            ply:PrintMessage(2,"Vs Mode true")
            for i, plyx in ipairs(player.GetAll()) do
                local text = "While Vs Mode is active, Vs Mini panel is available from WorldProg Panel."
                plyx:PrintMessage(3,text)
            end
        else
            PVPMode = false
            ply:PrintMessage(2,"Vs Mode false")
        end
    else
        ply:PrintMessage(2,"You Must Be Admin.")
    end
end)

concommand.Add("wp_combosys", function(ply)
    if(comboSystem) then
        comboSystem = false
        for i, plyx in ipairs(player.GetAll()) do
            local txt2 = "Combo System Disabled"
            plyx:PrintMessage(3,txt2)
        end
    else
        comboSystem = true
        for i, plyx in ipairs(player.GetAll()) do
            local txt2 = "Combo System Enabled"
            plyx:PrintMessage(3,txt2)
        end
    end
end)

concommand.Add("wp_ssave", function(ply)
    ply:WrldSave()
end)

