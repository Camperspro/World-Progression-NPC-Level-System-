-- CREATED BY C̶a̶m̶p̶e̶r☻ --
-- if you enjoy this addon or came for some inspiration, please drop a like! --

AddCSLuaFile("autorun/server/sv_worldprog.lua")

local wXP = 0.0
local lvl = 1
local pXP = 0.0
local wPr = 0
local chain = 0.0
local total = 0
local scrw = ScrW()
local scrh = ScrH()
local pparty = ""
local chainHS = 0
local xpHS = 0.0
local killHS = 0
local timeHS = 0.0
local wXPHS = 0
local pTok = 0
local plyDM = false
local plyPM = false
local deb = ""
local deb2 = ""
local additHUD = false -- for extra HUD info under prestige
local allParty = {}
local lockedUI = nil
local lockedpUI = nil
local miniUI = nil
local skillList = {}
local isAdmin = false -- For settings and more
local pos = nil
local ppos = nil
local wrldinfoUI = true
local TCUI = true
local NPCinfoUI = true
local plyinfoUI = true
local plyHint = false
local pvpmode = false
local npcmode = true
local presmode = true
local worldD = 2
local PVPtop = {}
local curKills = 0
local comboSetting = true

net.Receive("PresTok", function()
  local tokens = net.ReadInt(32)
  pTok = tonumber(tokens)
end)

net.Receive("HUDClear", function()
  RemoveCHud()
end)

net.Receive("SendTop5", function()
  PVPtop[0] = net.ReadString()
  PVPtop[1] = net.ReadString()
  PVPtop[2] = net.ReadString()
  PVPtop[3] = net.ReadString()
  PVPtop[4] = net.ReadString()
end)

net.Receive("openP", function()
  PrestigePanel()
end)

net.Receive("Allparties", function()
  allParty = net.ReadTable()
end)

net.Receive("killTotal", function()
  local x = net.ReadInt(32)
  local y = net.ReadInt(32)
  curKills = x
  killHS = y
end)

net.Receive("XPTotal", function()
  total = net.ReadInt(32)
  wXPHS = net.ReadInt(32)
end)

net.Receive("WLVL", function()
  lvl = net.ReadInt(32)
  wXP = tonumber(net.ReadInt(32))
  worldD = net.ReadInt(32)
  pvpmode = net.ReadBool()
end)

net.Receive("SendXP", function()
  pXP = net.ReadInt(32)
  xpHS = net.ReadInt(32)
end)

net.Receive("WPRESTIGE", function()
  wPr = net.ReadInt(32)
  WHudRefresh()
end)

net.Receive("PartyInfo", function()
  pparty = net.ReadString()
end)

net.Receive("DebugS", function()
  plyDM = net.ReadBool()
  if(plyDM == nil) then
    deb = "Lost/Null Debug Setting Data"
    plyDM = false
  end
end)

net.Receive("PartyS", function()
  plyPM = net.ReadBool()
  if(plyPM == nil) then
    deb2 = "Lost/Null Party Setting Data"
    plyPM = false
  end
end)

hook.Add("OnScreenSizeChanged", "ReUpdate", function (oldWidth, oldHeight)
  if(oldHeight != ScrH() and oldWidth != ScrW()) then
    if(ScrH() >= 2560 and ScrW() >= 1440)then
      --MY RESO
      draw.DrawText("World Level: " .. lvl, "ChatFont", ScrW() / 2 - 80, ScrH() / 2 + 560, Color(255,255,255))
      draw.DrawText(total .. "/" .. wXP .. "xp", "HudHintTextLarge", ScrW() / 2 - 38, ScrH() / 2 + 580, Color(255,255,255))
      if(wPr > 0) then
        draw.DrawText("Prestige: " .. wPr, "ChatFont", ScrW() / 2 - 45, ScrH() / 2 + 595, Color(255,166,12,177))
      end
    elseif(ScrH() <= 1920 and ScrW() <= 1280) then
      --Normal RESO
      draw.DrawText("World Level: " .. lvl, "ChatFont", ScrW() / 2 - 80, ScrH() / 2 + 360, Color(255,255,255))
      draw.DrawText(total .. "/" .. wXP .. "xp", "HudHintTextLarge", ScrW() / 2 - 38, ScrH() / 2 + 380, Color(255,242,104))
      if(wPr > 0) then
        draw.DrawText("Prestige: " .. wPr, "ChatFont", ScrW() / 2 - 45, ScrH() / 2 + 395, Color(255,166,12,177))
      end
    else
       --BOI RESO
       draw.DrawText("World Level: " .. lvl, "ChatFont", ScrW() / 2 - 80, ScrH() / 2 + 560, Color(255,255,255))
       draw.DrawText(total .. "/" .. wXP .. "xp", "HudHintTextLarge", ScrW() / 2 - 38, ScrH() / 2 + 580, Color(255,242,104))
       if(wPr > 0) then
         draw.DrawText("Prestige: " .. wPr, "ChatFont", ScrW() / 2 - 45, ScrH() / 2 + 595, Color(255,166,12,177))
       end
    end
  end
end)

--WORLD INFO HUD
hook.Add("HUDPaint", "HUDPaint_XP", function ()
  if(wrldinfoUI == true) then
    if(ScrH() >= 2560 and ScrW() >= 1440)then
      --Up Next RESO
      draw.RoundedBox(0, ScrW() / 2 - 80, ScrH() / 2 + 585,146,20,Color(11,11,11,172))
      draw.RoundedBox(0, ScrW() / 2 - 80, ScrH() / 2 + 585,146 * (total / wXP) ,20,Color(37,181,56,207))
      draw.DrawText("World Level: " .. lvl, "ChatFont", ScrW() / 2 - 80, ScrH() / 2 + 560, Color(255,255,255))
      draw.DrawText(total .. "/" .. wXP .. "xp", "HudHintTextLarge", ScrW() / 2 - 38, ScrH() / 2 + 586, Color(254,254,121))

      if(wPr > 0) then
        draw.DrawText("Prestige: " .. wPr, "ChatFont", ScrW() / 2 - 58, ScrH() / 2 + 615, Color(0,0,0))
        draw.DrawText("Prestige: " .. wPr, "ChatFont", ScrW() / 2 - 58, ScrH() / 2 + 615, Color(253,57,8,177))
      end
    elseif(ScrH() <= 1920 and ScrW() <= 1280) then
      --Normal RESO
      draw.RoundedBox(0, ScrW() / 2 - 80, ScrH() / 2 + 385,146,20,Color(11,11,11,172))
      draw.RoundedBox(0, ScrW() / 2 - 80, ScrH() / 2 + 385,146 * (total / wXP) ,20,Color(37,181,56,207))
      draw.DrawText("World Level: " .. lvl, "ChatFont", ScrW() / 2 - 80, ScrH() / 2 + 360, Color(255,255,255))
      draw.DrawText(total .. "/" .. wXP .. "xp", "HudHintTextLarge", ScrW() / 2 - 38, ScrH() / 2 + 386, Color(254,254,121))

      if(wPr > 0) then
        draw.DrawText("Prestige: " .. wPr, "ChatFont", ScrW() / 2 - 58, ScrH() / 2 + 615, Color(0,0,0))
        draw.DrawText("Prestige: " .. wPr, "ChatFont", ScrW() / 2 - 58, ScrH() / 2 + 615, Color(253,57,8,177))
      end
    else
       --BOI RESO
       draw.RoundedBox(0, ScrW() / 2 - 80, ScrH() / 2 + 585,146,20,Color(11,11,11,172))
       draw.RoundedBox(0, ScrW() / 2 - 80, ScrH() / 2 + 585,146 * (total / wXP) ,20,Color(37,181,56,207))
       draw.DrawText("World Level: " .. lvl, "ChatFont", ScrW() / 2 - 80, ScrH() / 2 + 560, Color(255,255,255))
       draw.DrawText(total .. "/" .. wXP .. "xp", "HudHintTextLarge", ScrW() / 2 - 38, ScrH() / 2 + 586, Color(254,254,121))

       if(wPr > 0) then
        draw.DrawText("Prestige: " .. wPr, "ChatFont", ScrW() / 2 - 58, ScrH() / 2 + 615, Color(0,0,0))
        draw.DrawText("Prestige: " .. wPr, "ChatFont", ScrW() / 2 - 58, ScrH() / 2 + 615, Color(253,57,8,177))
       end
    end
  end
end)

net.Receive("DrawNPClvl", function()
  local nlvl = net.ReadInt(32)

  if(NPCinfoUI == true) then

    if(wPr == 0) then //no prestige
      if(nlvl <= lvl) then
        hook.Add("HUDPaint", "HUDPaint_NPClvl", function ()
          draw.RoundedBox(0, ScrW() / 2 - 25, 90,65,18,Color(0,0,0,177))
          draw.DrawText("Level: " .. nlvl, "HudHintTextLarge",ScrW() / 2 -20,90,Color(0,255,98)) --ScrW() / 2 -52
        end)
    
      elseif(nlvl > lvl and nlvl < lvl+5) then
        hook.Add("HUDPaint", "HUDPaint_NPClvl", function ()
          draw.RoundedBox(0, ScrW() / 2 - 35, 90,70,18,Color(0,0,0,177))
          draw.DrawText("Level: " .. nlvl, "HudHintTextLarge",ScrW() / 2 -30,90,Color(255,247,0))
        end)
    
      elseif(nlvl >= lvl+5) then
        hook.Add("HUDPaint", "HUDPaint_NPClvl", function ()
          draw.RoundedBox(0, ScrW() / 2 - 35, 90,70,18,Color(0,0,0,177))
          draw.DrawText("Level: ??", "HudHintTextLarge",ScrW() / 2 -30,90,Color(255,0,0))
        end)
      
      end
    else
      local plvl = 5 * wPr
      if(nlvl <= plvl) then
        hook.Add("HUDPaint", "HUDPaint_NPClvl", function ()
          draw.RoundedBox(0, ScrW() / 2 - 25, 90,65,18,Color(0,0,0,177))
          draw.DrawText("Level: " .. nlvl, "HudHintTextLarge",ScrW() / 2 -20,90,Color(0,255,98)) --ScrW() / 2 -52
        end)
    
      elseif(nlvl > plvl and nlvl < plvl+5) then
        hook.Add("HUDPaint", "HUDPaint_NPClvl", function ()
          draw.RoundedBox(0, ScrW() / 2 - 35, 90,70,18,Color(0,0,0,177))
          draw.DrawText("Level: " .. nlvl, "HudHintTextLarge",ScrW() / 2 -30,90,Color(255,247,0))
        end)
    
      elseif(nlvl >= plvl+5) then
        hook.Add("HUDPaint", "HUDPaint_NPClvl", function ()
          draw.RoundedBox(0, ScrW() / 2 - 35, 90,70,18,Color(0,0,0,177))
          draw.DrawText("Level: ??", "HudHintTextLarge",ScrW() / 2 -30,90,Color(255,0,0))
        end)
      
      end
    end
    
    timer.Create("Hud_npcLTime", 0.2, 1, function()
      hook.Remove("HUDPaint", "HUDPaint_NPClvl")
    end)
  end
  
end)

net.Receive("DrawPlyCT", function()
  local kills = net.ReadInt(32)
  local time = net.ReadInt(32)
  local chain = net.ReadInt(32)

  if(plyinfoUI == true) then
    if(time > 15) then
      hook.Add("HUDPaint", "HUDPaint_PlyCT", function ()
        --draw.RoundedBox(0, ScrW() / 2 - 100, ScrH() / 2 - 50,120,18,Color(0,0,0,122))
        draw.DrawText("CT: " .. time .. "s." .. "\n Kills: " .. kills .. "\n CC: " .. chain .. "x", "HudHintTextLarge",ScrW() / 2 -100,ScrH() / 2 - 50,Color(77,255,0))
      end)
    end
  
    if(time < 15 and time > 5) then
      hook.Add("HUDPaint", "HUDPaint_PlyCT", function ()
        --draw.RoundedBox(0, ScrW() / 2 - 100, 91,90,18,Color(0,0,0,177))
        draw.DrawText("CT: " .. time .. "s!" .. "\n Kills: " .. kills .. "\n CC: " .. chain .. "x", "HudHintTextLarge",ScrW() / 2 -100,ScrH() / 2 - 50,Color(246,255,76))
      end)
    end
    if(time <= 5) then
      hook.Add("HUDPaint", "HUDPaint_PlyCT", function ()
        --draw.RoundedBox(0, ScrW() / 2 - 100, 91,90,18,Color(0,0,0,177))
        draw.DrawText("CT: " .. time .. "s!!" .. "\n Kills: " .. kills .. "\n CC: " .. chain .. "x", "HudHintTextLarge",ScrW() / 2 -100,ScrH() / 2 - 50,Color(255,0,0))
      end)
    end
  
  
    timer.Create("Hud_PlyCT", 0.2, 1, function()
      hook.Remove("HUDPaint", "HUDPaint_PlyCT")
    end)  
  end

end)

--Combo Multip HUD
net.Receive("DrawCombo", function()
  chain = 0
  chain = tonumber(net.ReadFloat(10))

  if(chain > chainHS) then
    chainHS = chain
  end

  if(TCUI == true)then
    if(chain <= 0) then
        hook.Remove("HUDPaint", "HUDPaint_COMBO")
        RemoveCHud()
    end
    if(chain == 1.5)then
      hook.Add("HUDPaint","HUDPaint_COMBO", function()
      draw.RoundedBox(5,scrw / 2 - 72, 48,52,22,Color(0,0,0,111))
      draw.DrawText(chain .. "x","TargetID", scrw / 2 - 68, 49, Color(95,95,95))
      end)
    end
    if(chain == 2)then
          hook.Add("HUDPaint","HUDPaint_COMBO", function()
          draw.RoundedBox(5,scrw / 2 - 60, 48,31,22,Color(0,0,0,84))
          draw.DrawText(chain .. "x","TargetID", scrw / 2 - 60, 48, Color(159,159,159))
        end)
    end
    if(chain == 2.5) then
          hook.Add("HUDPaint","HUDPaint_COMBO", function()
          draw.RoundedBox(5,scrw / 2 - 72, 48,52,22,Color(0,0,0,111))
          draw.DrawText(chain .. "x","TargetID", scrw / 2 - 68, 49, Color(214,214,214))
          end)
    end
    if(chain >= 3)then
          hook.Add("HUDPaint","HUDPaint_COMBO", function()
          draw.RoundedBox(5,scrw / 2 - 60, 48,31,22,Color(0,0,0,84))
          draw.DrawText(chain .. "x","TargetID", scrw / 2 - 60, 48, Color(255,255,255))
        end)
    end
    if(chain >= 4) then
      hook.Add("HUDPaint","HUDPaint_COMBO", function()
        draw.RoundedBox(6,scrw / 2 - 60, 48,31,22,Color(0,0,0,84))
        draw.DrawText(chain .. "x","TargetID", scrw / 2 - 60, 48, Color(255,225,0))
        draw.DrawText(chain .. "x","TargetID", scrw / 2 - 58, 49, Color(136,255,0,245))
      end)
    end
    if(chain >= 6) then
        hook.Add("HUDPaint","HUDPaint_COMBO", function()
          draw.RoundedBox(8,scrw / 2 - 58, 50,35,22,Color(0,0,0,84))
          draw.DrawText(chain .. "x","TargetID", scrw / 2 - 60, 48, Color(211,33,95))
          draw.DrawText(chain .. "x","TargetID", scrw / 2 - 58, 49, Color(147,0,196,245))
          draw.DrawText("DECIMATION!","TargetIDSmall", scrw / 2 - 45, 15, Color(255,255,255))
        end)
    end
    if(chain >= 8) then
      hook.Add("HUDPaint","HUDPaint_COMBO", function()
        draw.RoundedBox(10,scrw / 2 - 58, 50,35,22,Color(0,0,0,84))
        draw.DrawText(chain .. "x","TargetID", scrw / 2 - 60, 48, Color(242,3,3))
        draw.DrawText(chain .. "x","TargetID", scrw / 2 - 58, 49, Color(16,56,216,245))
        draw.DrawText("ARMAGEDDON!","TargetIDSmall", scrw / 2 - 45, 15, Color(255,255,255))
      end)
    end
  end
end)

net.Receive("DrawTime", function()
  local b = net.ReadFloat()
  if(tonumber(b) > tonumber(timeHS)) then
    timeHS = b
  end

  if (b == 0) then
    hook.Remove("HUDPaint", "HUDPaint_CTIME")
    hook.Remove("HUDPaint", "HUDPaint_COMBO")
    chain = 0
  end

  if(TCUI == true)then
   --Check Passed Time
    if(b > 0) then
      b = string.format("%2.1f", b)
      local time = b
      timer.Create("Hud_Time", 1, time, function()
        time = time - 1
      end)
      if(tonumber(time) > 15) then
          hook.Add("HUDPaint", "HUDPaint_CTIME", function()
            --Chain Time 15s+
            draw.RoundedBox(0, scrw / 2 - 18, 52,40,18, Color(0,0,0,177))
            draw.DrawText(time .. "s","TargetIDSmall", scrw / 2 - 18, 50, Color(98,255,0,236))
            draw.DrawText("Combo Active","TargetIDSmall", scrw / 2 - 45, 75, Color(255,255,255))
          end)
        elseif(tonumber(time) > 60)then
          hook.Add("HUDPaint", "HUDPaint_CTIME", function()
            --Chain Time 60s+
            draw.RoundedBox(0, scrw / 2 - 18, 52,40,18, Color(0,0,0,177))
            draw.DrawText(time .. "s","TargetIDSmall", scrw / 2 - 18, 50, Color(99,240,11,236))
            draw.DrawText(time .. "s","TargetIDSmall", scrw / 2 - 20, 47, Color(0,81,255))
            draw.DrawText("Combo Bustling!","TargetIDSmall", scrw / 2 - 46, 76, Color(129,28,252))
            draw.DrawText("Combo Bustling","TargetIDSmall", scrw / 2 - 45, 75, Color(255,255,255))
          end)
        elseif(tonumber(time) < 15 and tonumber(time) > 5) then
          hook.Add("HUDPaint", "HUDPaint_CTIME", function()
            --Chain Time
            draw.RoundedBox(0, scrw / 2 - 18, 52,40,18,Color(0,0,0,177))
            draw.DrawText(time .. "s!","TargetIDSmall", scrw / 2 - 18, 50, Color(255,247,0))
            draw.DrawText("Combo Falling!","TargetIDSmall", scrw / 2 - 45, 75, Color(255,255,255))
          end)
        elseif(tonumber(time) <= 5)then
          hook.Add("HUDPaint", "HUDPaint_CTIME", function()
            --Chain Time
            draw.RoundedBox(0, scrw / 2 - 18, 50,38,18,Color(0,0,0,177))
            draw.DrawText(time .. "s!!","TargetIDSmall", scrw / 2 - 18, 50, Color(255,0,0))
            draw.DrawText("Combo Fading!","TargetIDSmall", scrw / 2 - 46, 76, Color(255,3,3,180))
            draw.DrawText("Combo Fading!","TargetIDSmall", scrw / 2 - 45, 75, Color(255,255,255))
          end)
        end
    end
  end
end)

function RemoveCHud()
  chain = 0
  hook.Remove("HUDPaint", "HUDPaint_CTIME")
  hook.Remove("HUDPaint", "HUDPaint_COMBO")
end

function WHudRefresh()
  if(ScrH() >= 2560 and ScrW() >= 1440)then
    --MY RESO
    draw.DrawText("World Level: " .. lvl, "ChatFont", ScrW() / 2 - 80, ScrH() / 2 + 560, Color(255,255,255))
    draw.DrawText(total .. "/" .. wXP .. "xp", "HudHintTextLarge", ScrW() / 2 - 36, ScrH() / 2 + 580, Color(255,242,104))
    if(wPr > 0) then
      draw.DrawText("Prestige: " .. wPr, "ChatFont", ScrW() / 2 - 86, ScrH() / 2 + 595, Color(255,166,12,177))
    end
  elseif(ScrH() <= 1920 and ScrW() <= 1280) then
    --Normal RESO
    draw.DrawText("World Level: " .. lvl, "ChatFont", ScrW() / 2 - 80, ScrH() / 2 + 360, Color(255,255,255))
    draw.DrawText(total .. "/" .. wXP .. "xp", "HudHintTextLarge", ScrW() / 2 - 36, ScrH() / 2 + 380, Color(255,242,104))
    if(wPr > 0) then
      draw.DrawText("Prestige: " .. wPr, "ChatFont", ScrW() / 2 - 80, ScrH() / 2 + 395, Color(255,166,12,177))
    end
  else
     --BOI RESO
     draw.DrawText("World Level: " .. lvl, "ChatFont", ScrW() / 2 - 80, ScrH() / 2 + 560, Color(255,255,255))
     draw.DrawText(total .. "/" .. wXP .. "xp", "HudHintTextLarge", ScrW() / 2 - 36, ScrH() / 2 + 580, Color(255,242,104))
     if(wPr > 0) then
       draw.DrawText("Prestige: " .. wPr, "ChatFont", ScrW() / 2 - 86, ScrH() / 2 + 595, Color(255,166,12,177))
     end
  end
end

net.Receive("PartyUI", function()
   PartyUIPanel()
end)


function SendPN(name,ply)
  net.Start("PartyCName")
  net.WriteString(name)
  net.WriteEntity(ply)
  net.SendToServer()
end

function SendTokens(tokens,ply)
  net.Start("sentTok")
  net.WriteInt(tokens,32)
  net.WriteEntity(ply)
  net.SendToServer()
end

function SendPDS(setting, ply)
  net.Start("DebugS")
  net.WriteBool(setting)
  net.WriteEntity(ply)
  net.SendToServer()
end

function SendPresys(setting, ply)
  net.Start("PresSys")
  net.WriteBool(setting)
  net.WriteEntity(ply)
  net.SendToServer()
end

function SendNPCHelp(setting, ply)
  net.Start("npcHelp")
  net.WriteBool(setting)
  net.WriteEntity(ply)
  net.SendToServer()
end

function SendPVPS(setting, ply)
  net.Start("pvpSetting")
  net.WriteBool(setting)
  net.WriteEntity(ply)
  net.SendToServer()
end

function SendPPS(setting, ply)
  net.Start("PartyS")
  net.WriteBool(setting)
  net.WriteEntity(ply)
  net.SendToServer()
end

function RefreshUI(ply)
  net.Start("refreshWUI")
  net.WriteEntity(ply)
  net.SendToServer()
end

function RefreshLUI(ply)
  net.Start("refreshLWUI")
  net.WriteEntity(ply)
  net.SendToServer()
end

function RefreshPUI(ply)
  net.Start("refreshPUI")
  net.WriteEntity(ply)
  net.SendToServer()
  PrestigePanel()
end

function PartyUIPanel()
  if(CLIENT) then
    if(lockedUI != nil)then
  
    end

    local Partyname = nil
    local x = LocalPlayer()
    local txpHS = 0
    local twXPHS = 0
    --MAIN FRAME
    local PFrame = vgui.Create("DFrame")
    PFrame:SetPos(scrw / 2 - 60,10)
    PFrame:SetSize(390,500)
    PFrame:SetTitle("World Prog. Panel (v1.0b)")
    PFrame:SetVisible(true)
    PFrame:SetDraggable(true)
    PFrame:ShowCloseButton(true)
    PFrame:MakePopup()

    local PartyLabel = vgui.Create("DLabel",PFrame)
    PartyLabel:SetPos(30,15)
    PartyLabel:SetSize(400,50)
    PartyLabel:SetTextColor(Color(255,255,255))
    if(pparty == "" or pparty == nil)then
      PartyLabel:SetText("Current Party: None")
    else
      PartyLabel:SetText("Current Party: " .. tostring(pparty))
    end

    local miniB = vgui.Create("DButton", PFrame)
    miniB:SetText("Mini Panel")
    miniB:SetTextColor(Color(255,255,255))
    miniB:SetPos(30,51)
    miniB:SetSize(100,20)
    miniB.Paint = function(self, w, h)
      draw.RoundedBox(0,0,0,w,h, Color(0,0,0))
    end
    miniB.DoClick = function()
      if(lockedUI != nil)then
        LocalPlayer():ChatPrint("Please close active mini panel.")
      else
        MiniPartyUIPanel()
        PFrame:Close()
      end
      
    end

    if(pvpmode == true)then
      local minipvp = vgui.Create("DButton", PFrame)
      minipvp:SetText("Vs")
      minipvp:SetTextColor(Color(255,38,0))
      minipvp:SetPos(140,51)
      minipvp:SetSize(33,20)
      minipvp.DoClick = function()
        if(pvpmode == true)then
          if(lockedpUI != nil)then
            LocalPlayer():ChatPrint("Please close pvp mini panel.")
          else
            PFrame:Close()
            MPvpPanel()
          end
        else
          LocalPlayer():ChatPrint("PVP / Vs Mode is disabled!")
        end
    end

    end
    --HELP Button
    local HelpB = vgui.Create("DButton", PFrame)
    HelpB:SetText("ⓘ Help")
    HelpB:SetTextColor(Color(255,255,255))
    HelpB:SetPos(30,80)
    HelpB:SetSize(100,30)
    HelpB.Paint = function(self, w, h)
      draw.RoundedBox(0,0,0,w,h, Color(84,84,84))
       end
     HelpB.DoClick = function()
        Helppanel()
    end

    local refreshB = vgui.Create("DButton", PFrame)
    refreshB:SetText("⥁ Refresh ⥀ ")
    refreshB:SetTextColor(Color(255,255,255))
    refreshB:SetPos(30,120)
    refreshB:SetSize(100,30)
    refreshB.Paint = function(self, w, h)
      draw.RoundedBox(0,0,0,w,h, Color(212,215,118))
    end
    refreshB.DoClick = function()
      PFrame:Close()
      RefreshUI(x)
    end

    local prestigeShopB = vgui.Create("DButton", PFrame)
    prestigeShopB:SetText("Prestige Shop")
    prestigeShopB:SetTextColor(Color(255,255,255))
    prestigeShopB:SetPos(30,160)
    prestigeShopB:SetSize(100,30)
    prestigeShopB.Paint = function(self, w, h)
      draw.RoundedBox(0,0,0,w,h, Color(93,183,231))
    end
    prestigeShopB.DoClick = function()
      x:ChatPrint("Prestige Shop and Skills may have issues/strange balancing as things are in development.")
      PrestigePanel()
    end

    local PXPLabel = vgui.Create("DLabel",PFrame)
    PXPLabel:SetPos(30,190)
    PXPLabel:SetText("XP Total Earned: " .. tonumber(xpHS) .. "xp.")
    PXPLabel:SetSize(180,45)
    PXPLabel:SetTextColor(Color(255,255,255))

    local PKLabel = vgui.Create("DLabel",PFrame)
    PKLabel:SetPos(30,210)
    PKLabel:SetText("Current Kills: " .. curKills .. " | Total: " .. killHS)
    PKLabel:SetSize(180,45)
    PKLabel:SetTextColor(Color(255,255,255))

    local PCLabel = vgui.Create("DLabel",PFrame)
    PCLabel:SetPos(30,230)
    PCLabel:SetText("Highest Combo: " .. chainHS .. "x")
    PCLabel:SetSize(180,45)
    PCLabel:SetTextColor(Color(255,255,255))

    local PTLabel = vgui.Create("DLabel",PFrame)
    timeHS = string.format("%2.1f", timeHS)
    PTLabel:SetPos(30,250)
    PTLabel:SetText("Highest Combo Time: " .. timeHS .. "s.")
    PTLabel:SetSize(180,45)
    PTLabel:SetTextColor(Color(255,255,255))

    local WrldLabel = vgui.Create("DLabel",PFrame)
    WrldLabel:SetPos(30,270)
    WrldLabel:SetText("World Level: " .. lvl .. ".  Prestige: " .. wPr)
    WrldLabel:SetSize(250,45)
    WrldLabel:SetTextColor(Color(255,255,255))

    local WrldXPLabel = vgui.Create("DLabel",PFrame)
    WrldXPLabel:SetPos(30,290)
    WrldXPLabel:SetText("World XP Total Earned: " .. wXPHS .. "xp")
    WrldXPLabel:SetSize(250,45)
    WrldXPLabel:SetTextColor(Color(255,255,255))

    --PARTY LIST
    local allPartyList = vgui.Create("DCollapsibleCategory", PFrame)
    allPartyList:SetLabel("Party List")
    allPartyList:SetPos(220,50)
    allPartyList:SetSize(150,480)
    allPartyList:SetExpanded(false)
  
    local apList = vgui.Create("DPanelList", DermaPanel)
    apList:SetSpacing(6)
    apList:EnableHorizontal(false)
    apList:EnableVerticalScrollbar(true)
    allPartyList:SetContents( apList )

    if next(allParty) == nil then
      local pln = vgui.Create("DLabel")
      pln:SetText("Currently no parties.")
      apList:AddItem(pln)
    else
      PrintTable(allParty)
      for i, pn in pairs(allParty) do
        local pln = vgui.Create("DButton")
        if(pn != nil) then
          pln:SetText(pn)
        elseif(pn == "No party") then
          pln:SetText(pn)
        else
          pln:SetText("(Error) Party #" .. i)
        end
        apList:AddItem(pln)
        pln.DoClick = function ()
          if(pn == "No party") then
            --do nothing or something else
            LocalPlayer():ChatPrint("You have gathered " .. pXP .."xp.")
          else

            net.Start("Sendmem")
            net.WriteString(pn)
            net.WriteEntity(LocalPlayer())
            net.SendToServer()

            net.Receive("Allmembers", function()
              local mem = net.ReadTable()
              local mxp = net.ReadTable()
              local mkills = net.ReadTable()
              LocalPlayer():ChatPrint("Members:")
              for z=1, #mem do
                if(LocalPlayer():GetName() == mem[z])then
                  --do nothing
                  LocalPlayer():ChatPrint("You have gathered " .. tostring(mxp[z]) .."xp. Total kills: " .. tostring(mkills[z]) .. ".")
                else
                  LocalPlayer():ChatPrint(tostring(mem[z]) .. " has gathered, " .. tostring(mxp[z]) .. "xp. Total kills: " .. tostring(mkills[z]))
                end
              end
            end)

          end
        
        end
      end
    end

    allPartyList:InvalidateLayout(true)

    local NameLabel = vgui.Create("DLabel",PFrame)
    NameLabel:SetPos(30,310)
    NameLabel:SetText("Create/Join A Party Below")
    NameLabel:SetSize(155,45)

    PFrame.Paint = function(self, w, h)
      draw.RoundedBox(0,0,0,w,h, Color(12,31,41,241))
    end
      --PARTY NAME ENTRY
      local NameEntry = vgui.Create("DTextEntry", PFrame)
      NameEntry:SetPos(30,350)
      NameEntry:SetSize(150,45)
      if(pparty == nil or pparty == "No party") then
        NameEntry:SetPlaceholderText("Party Name Here")
      else
        NameEntry:SetPlaceholderText(pparty)
      end
      NameEntry.OnEnter = function(self)
        if(plyPM == false)then
          x:ChatPrint("Turn on party system to start (try wp_party concommand or from Client settings).")
        else
          Partyname = NameEntry:GetValue()
          if(Partyname == nil) then
           x:ChatPrint("Invalid Party Name")
           SendPN("No party",x)
          else
            SendPN(tostring(Partyname),x)
          end
        end
      end
      NameEntry.OnClickLine = function(self)
        if(plyPM == false)then
          x:ChatPrint("Turn on party system to start (try wp_party concommand or from Client settings).")
        else

        end
      end

    local CreateB = vgui.Create("DButton", PFrame)
    CreateB:SetText("Create/Join Party")
    CreateB:SetTextColor(Color(255,255,255))
    CreateB:SetPos(30,400)
    CreateB:SetSize(100,30)
    CreateB.Paint = function(self, w, h)
      draw.RoundedBox(0,0,0,w,h, Color(67,213,45))
    end
    CreateB.DoClick = function()
      if(plyPM == false)then
        x:ChatPrint("Turn on party system to start (try wp_party concommand or from Client settings).")
      else
        Partyname = NameEntry:GetValue()
      if(Partyname == nil) then
        x:ChatPrint("Invalid Party Name")
      else
        SendPN(tostring(Partyname),x)
        PFrame:Close()
        RefreshUI(x)
      end
    end
    end

    local Disband = vgui.Create("DButton", PFrame)
    Disband:SetText("Disband/Leave Party")
    Disband:SetTextColor(Color(255,255,255))
    Disband:SetPos(30,435)
    Disband:SetSize(100,30)
    Disband.Paint = function(self, w, h)
      draw.RoundedBox(0,0,0,w,h, Color(193,4,4))
    end
    Disband.DoClick = function()
      SendPN("",x)
      PFrame:Close()
      RefreshUI(x)
    end
  end
end

--PVP MODE MINI PANEL

function MPvpPanel()
  if(CLIENT) then

    local Partyname = nil
    local x = LocalPlayer()
    local txpHS = 0
    local twXPHS = 0
    --MAIN FRAME
    local MPFrame = vgui.Create("DFrame")
    MPFrame:SetPos(scrw / 2 - 25,100)
    MPFrame:SetSize(150,125)
    MPFrame:SetTitle("W.P.P")
    MPFrame:SetVisible(true)
    MPFrame:SetDraggable(true)
    MPFrame:ShowCloseButton(true)
    MPFrame:MakePopup()
    MPFrame.OnClose = function()
      if(lockedpUI != nil)then
        lockedpUI = nil
      end
    end

    MPFrame.Paint = function(self, w, h)
      draw.RoundedBox(0,0,0,w,h, Color(2,12,18,243))
    end
      
      --HELP
      local LockB = vgui.Create("DButton", MPFrame)
      LockB:SetText("Lock Panel")
      LockB:SetTextColor(Color(255,255,255))
      LockB:SetPos(5,90)
      LockB:SetSize(100,30)
      LockB.Paint = function(self, w, h)
        draw.RoundedBox(0,0,0,w,h, Color(14,14,14))
      end
      LockB.DoClick = function()
        if(lockedpUI == nil)then
          MPFrame:SetKeyboardInputEnabled(false)
          MPFrame:SetMouseInputEnabled(false)
          x:PrintMessage(3,"ⓘ type 'wp_mc' in console to close the Mini Panel(s).")
          ppos = MPFrame:LocalToScreen()
          lockedpUI = MPFrame
          LockB:SetText("ⓘ !wp_mc to close.")
          LockB:SetTextColor(Color(255,255,255))
        else
          LocalPlayer():ChatPrint("ⓘ Panel already locked.")
        end
      end

      local PXPLabelm = vgui.Create("DLabel",MPFrame)
      PXPLabelm:SetPos(4,10)
      PXPLabelm:SetText("1. " .. PVPtop[0])
      PXPLabelm:SetSize(180,45)
      PXPLabelm:SetTextColor(Color(255,255,255))
  
      local PKLabelm = vgui.Create("DLabel",MPFrame)
      PKLabelm:SetPos(4,20)
      PKLabelm:SetText("2. " .. PVPtop[1])
      PKLabelm:SetSize(180,45)
      PKLabelm:SetTextColor(Color(255,255,255))
  
      local PCLabelm = vgui.Create("DLabel",MPFrame)
      PCLabelm:SetPos(4,30)
      PCLabelm:SetText("3. " .. PVPtop[2])
      PCLabelm:SetSize(180,45)
      PCLabelm:SetTextColor(Color(255,255,255))
  
      local PTLabelm = vgui.Create("DLabel",MPFrame)
      timeHS = string.format("%2.1f", timeHS)
      PTLabelm:SetPos(4,40)
      PTLabelm:SetText("4. " .. PVPtop[3])
      PTLabelm:SetSize(180,45)
      PTLabelm:SetTextColor(Color(255,255,255))
  
      local WrldLabelm = vgui.Create("DLabel",MPFrame)
      WrldLabelm:SetPos(4,50)
      WrldLabelm:SetText("5. " .. PVPtop[4])
      WrldLabelm:SetSize(250,45)
      WrldLabelm:SetTextColor(Color(255,255,255))
  
      local WrldXPLabelm = vgui.Create("DLabel",MPFrame)
      WrldXPLabelm:SetPos(4,60)
      WrldXPLabelm:SetText("Top 5 Players (XP)")
      WrldXPLabelm:SetSize(250,45)
      WrldXPLabelm:SetTextColor(Color(255,255,255))
  end
end

function MiniPartyUIPanel()
  if(CLIENT) then
   

    local Partyname = nil
    local x = LocalPlayer()
    local txpHS = 0
    local twXPHS = 0
    --MAIN FRAME
    local MFrame = vgui.Create("DFrame")
    MFrame:SetPos(scrw / 2 - 25,100)
    MFrame:SetSize(150,125)
    MFrame:SetTitle("W.P.M v1.1b")
    MFrame:SetVisible(true)
    MFrame:SetDraggable(true)
    MFrame:ShowCloseButton(true)
    MFrame:MakePopup()
    MFrame.OnClose = function()
      if(lockedUI != nil)then
        lockedUI = nil
      end
    end

    MFrame.Paint = function(self, w, h)
      draw.RoundedBox(0,0,0,w,h, Color(2,12,18,243))
    end
      
      --HELP
      local LockB = vgui.Create("DButton", MFrame)
      LockB:SetText("Lock Panel")
      LockB:SetTextColor(Color(255,255,255))
      LockB:SetPos(5,90)
      LockB:SetSize(100,30)
      LockB.Paint = function(self, w, h)
        draw.RoundedBox(0,0,0,w,h, Color(14,14,14))
      end
      LockB.DoClick = function()
        if(lockedUI == nil)then
          MFrame:SetKeyboardInputEnabled(false)
          MFrame:SetMouseInputEnabled(false)
          x:ChatPrint("ⓘ Type 'wp_mc' in console to unlock the Mini Panel.")
          lockedUI = MFrame
          pos = MFrame:LocalToScreen()
          if(lockedUI == nil)then
            lockedUI = MFrame
          end

          LockB:SetText("ⓘ Close in Utilities.")
          LockB:SetTextColor(Color(255,255,255))
          net.Start("LockedS")
          net.WriteBool(true)
          net.WriteEntity(x)
          net.SendToServer()
        else
          x:ChatPrint("ⓘ Panel already locked.")
        end
      end

      --NORMAL PANEL MODE
    local PXPLabelm = vgui.Create("DLabel",MFrame)
    PXPLabelm:SetPos(4,40)
    PXPLabelm:SetText("Total XP Earned: " .. tonumber(xpHS) .. "xp.")
    PXPLabelm:SetSize(180,45)
    PXPLabelm:SetTextColor(Color(255,255,255))

    local PKLabelm = vgui.Create("DLabel",MFrame)
    PKLabelm:SetPos(4,30)
    PKLabelm:SetText("Kills: " .. curKills)
    PKLabelm:SetSize(180,45)
    PKLabelm:SetTextColor(Color(255,255,255))

    local PCLabelm = vgui.Create("DLabel",MFrame)
    PCLabelm:SetPos(4,20)
    PCLabelm:SetText("Kill Total: " .. killHS)
    PCLabelm:SetSize(180,45)
    PCLabelm:SetTextColor(Color(255,255,255))

    local PTLabelm = vgui.Create("DLabel",MFrame)
    timeHS = string.format("%2.1f", timeHS)
    PTLabelm:SetPos(4,10)
    PTLabelm:SetText("Highest Combo: " .. chainHS .. "x")
    PTLabelm:SetSize(180,45)
    PTLabelm:SetTextColor(Color(255,255,255))

    local WrldLabelm = vgui.Create("DLabel",MFrame)
    WrldLabelm:SetPos(4,60)
    WrldLabelm:SetText("Highest Time: " .. timeHS .. "s.")
    WrldLabelm:SetSize(250,45)
    WrldLabelm:SetTextColor(Color(255,255,255))

    local WrldXPLabelm = vgui.Create("DLabel",MFrame)
    WrldXPLabelm:SetPos(4,50)
    WrldXPLabelm:SetText("World Level: " .. lvl .. ".  Prestige: " .. wPr)
    WrldXPLabelm:SetSize(250,45)
    WrldXPLabelm:SetTextColor(Color(255,255,255))
  end
end

function MiniPartyUIPanelRefresh(posx, posy)
  if(CLIENT) then
     if(lockedUI != nil) then
       lockedUI:Close()
       lockedUI = nil
     end

    local Partyname = nil
    local x = LocalPlayer()
    local txpHS = 0
    local twXPHS = 0
    --MAIN FRAME
    local MFrame = vgui.Create("DFrame")
    MFrame:SetX(posx)
    MFrame:SetY(posy)
    --MFrame:SetPos(pos)
    MFrame:SetSize(150,120)
    MFrame:SetTitle("W.P.M v1.2b")
    MFrame:SetVisible(true)
    MFrame:ShowCloseButton(true)
    MFrame.OnClose = function()
      if(lockedUI != nil)then
        lockedUI = nil
      end
    end
    MFrame.Paint = function(self, w, h)
      draw.RoundedBox(0,0,0,w,h, Color(2,12,18,243))
    end
      
      --HELP
      local LockB = vgui.Create("DButton", MFrame)
      LockB:SetText("ⓘ 'wp_mc' to close.")
      LockB:SetTextColor(Color(255,255,255))
      LockB:SetPos(5,90)
      LockB:SetSize(100,30)
      LockB.Paint = function(self, w, h)
        draw.RoundedBox(0,0,0,w,h, Color(14,14,14))
      end
      LockB.DoClick = function()
        MFrame:Close()
        lockedUI = nil
      end

      --NORMAL PANEL MODE

      local PXPLabelm = vgui.Create("DLabel",MFrame)
      PXPLabelm:SetPos(4,40)
      PXPLabelm:SetText("Total XP Earned: " .. tonumber(xpHS) .. "xp.")
      PXPLabelm:SetSize(180,45)
      PXPLabelm:SetTextColor(Color(255,255,255))
  
      local PKLabelm = vgui.Create("DLabel",MFrame)
      PKLabelm:SetPos(4,30)
      PKLabelm:SetText("Kills: " .. curKills)
      PKLabelm:SetSize(180,45)
      PKLabelm:SetTextColor(Color(255,255,255))
  
      local PCLabelm = vgui.Create("DLabel",MFrame)
      PCLabelm:SetPos(4,20)
      PCLabelm:SetText("Kill Total: " .. killHS)
      PCLabelm:SetSize(180,45)
      PCLabelm:SetTextColor(Color(255,255,255))
  
      local PTLabelm = vgui.Create("DLabel",MFrame)
      timeHS = string.format("%2.1f", timeHS)
      PTLabelm:SetPos(4,10)
      PTLabelm:SetText("Highest Combo: " .. chainHS .. "x")
      PTLabelm:SetSize(180,45)
      PTLabelm:SetTextColor(Color(255,255,255))
  
      local WrldLabelm = vgui.Create("DLabel",MFrame)
      WrldLabelm:SetPos(4,60)
      WrldLabelm:SetText("Highest Time: " .. timeHS .. "s.")
      WrldLabelm:SetSize(250,45)
      WrldLabelm:SetTextColor(Color(255,255,255))
  
      local WrldXPLabelm = vgui.Create("DLabel",MFrame)
      WrldXPLabelm:SetPos(4,50)
      WrldXPLabelm:SetText("World Level: " .. lvl .. ".  Prestige: " .. wPr)
      WrldXPLabelm:SetSize(250,45)
      WrldXPLabelm:SetTextColor(Color(255,255,255))

      lockedUI = MFrame
  end
end

function MPvpPanell(posx, posy)
  if(CLIENT) then
    if(lockedpUI != nil)then
      lockedpUI:Close()
       lockedpUI = nil
      
    end

    local Partyname = nil
    local x = LocalPlayer()
    local txpHS = 0
    local twXPHS = 0
    --MAIN FRAME
    local MPFrame = vgui.Create("DFrame")
    MPFrame:SetX(posx)
    MPFrame:SetY(posy)
    MPFrame:SetSize(150,125)
    MPFrame:SetTitle("W.P.P")
    MPFrame:SetVisible(true)
    MPFrame:ShowCloseButton(true)
    MPFrame.OnClose = function()
      if(lockedpUI != nil)then
        lockedpUI = nil
      end
    end

    MPFrame.Paint = function(self, w, h)
      draw.RoundedBox(0,0,0,w,h, Color(2,12,18,243))
    end
      
      --HELP
      local LockB = vgui.Create("DButton", MPFrame)
      LockB:SetText("ⓘ 'wp_mc' to close.")
      LockB:SetTextColor(Color(255,255,255))
      LockB:SetPos(5,90)
      LockB:SetSize(100,30)
      LockB.Paint = function(self, w, h)
        draw.RoundedBox(0,0,0,w,h, Color(14,14,14))
      end
      LockB.DoClick = function()
        MPFrame:Close()
        lockedUI = nil
      end
      if(lockedpUI == nil)then
          LockB:SetText("ⓘ 'wp_mc' to close.")
          LockB:SetTextColor(Color(255,255,255))
      else
          LocalPlayer():ChatPrint("ⓘ Panel already locked.")
      end

      local PXPLabelm = vgui.Create("DLabel",MPFrame)
      PXPLabelm:SetPos(4,10)
      PXPLabelm:SetText("1. " .. PVPtop[0])
      PXPLabelm:SetSize(180,45)
      PXPLabelm:SetTextColor(Color(255,255,255))
  
      local PKLabelm = vgui.Create("DLabel",MPFrame)
      PKLabelm:SetPos(4,20)
      PKLabelm:SetText("2. " .. PVPtop[1])
      PKLabelm:SetSize(180,45)
      PKLabelm:SetTextColor(Color(255,255,255))
  
      local PCLabelm = vgui.Create("DLabel",MPFrame)
      PCLabelm:SetPos(4,30)
      PCLabelm:SetText("3. " .. PVPtop[2])
      PCLabelm:SetSize(180,45)
      PCLabelm:SetTextColor(Color(255,255,255))
  
      local PTLabelm = vgui.Create("DLabel",MPFrame)
      timeHS = string.format("%2.1f", timeHS)
      PTLabelm:SetPos(4,40)
      PTLabelm:SetText("4. " .. PVPtop[3])
      PTLabelm:SetSize(180,45)
      PTLabelm:SetTextColor(Color(255,255,255))
  
      local WrldLabelm = vgui.Create("DLabel",MPFrame)
      WrldLabelm:SetPos(4,50)
      WrldLabelm:SetText("5. " .. PVPtop[4])
      WrldLabelm:SetSize(250,45)
      WrldLabelm:SetTextColor(Color(255,255,255))
  
      local WrldXPLabelm = vgui.Create("DLabel",MPFrame)
      WrldXPLabelm:SetPos(4,60)
      WrldXPLabelm:SetText("Top 5 Players (XP)")
      WrldXPLabelm:SetSize(250,45)
      WrldXPLabelm:SetTextColor(Color(255,255,255))

    lockedpUI = MPFrame
  end
end

net.Receive("MiniPan", function()
  local posx = 0
  local posy = 0
  if(lockedUI == nil)then
    LocalPlayer():PrintMessage(3,"Locked panel position was been reset due to an issue.")
     posx = scrw / 2 - 25
     posy = 100
  else
     posx = lockedUI:GetX()
     posy = lockedUI:GetY()
  end

  local Pposx = scrw / 2 - 25
  local Pposy = 100
  if(pvpmode == true and lockedpUI != nil)then
    Pposx = lockedpUI:GetX()
    Pposy = lockedpUI:GetY()
  elseif(pvpmode == true and lockedpUI == nil) then
    --LocalPlayer():PrintMessage(3,"Failed to update Vs panel due to other panel activity. (Will update next XP calc.)")
  end
  --local pos = nil
  if(lockedUI != nil) then
    MiniPartyUIPanelRefresh(posx, posy)
    if(pvpmode == true and lockedpUI != nil)then
      MPvpPanell(Pposx, Pposy)
    end
  else
    LocalPlayer():PrintMessage(3,"Failed to update mini panel due to other panel activity.")
  end
  
end)

function Helppanel()
  local HFrame = vgui.Create("DFrame")
  HFrame:SetPos(800,800)
  HFrame:SetSize(600,400)
  HFrame:SetTitle("Help Page")
  HFrame:SetVisible(true)
  HFrame:SetDraggable(true)
  HFrame:ShowCloseButton(true)
  HFrame:MakePopup()
  HFrame:SetKeyboardInputEnabled(false)
  HFrame.Paint = function(self, w, h)
    draw.RoundedBox(0,0,0,w,h, Color(3,3,3,248))
  end

  local XPInfoLabel = vgui.Create("DLabel",HFrame)
    XPInfoLabel:SetPos(10,20)
    XPInfoLabel:SetText("ⓘ XP Tips: A higher combo (additional kills while the KTC is active) will generate more XP once the KTC has ended.\n Each player's seperate xp is combined into one for the world XP total. '??' LVL enemies count as 2 kills!")
    XPInfoLabel:SetSize(600,50)
    XPInfoLabel:SetTextColor(Color(98,255,84))

    local TimerLabel = vgui.Create("DLabel",HFrame)
    TimerLabel:SetPos(10,60)
    TimerLabel:SetText("ⓘ Timer Tips: Dealing damage and getting kills around a party or alone can increase your active combo time.\n Getting hurt can lower your time! '??'LVL foes provide extra time when damged or killed!")
    TimerLabel:SetSize(600,50)

    local WorldInfoLabel = vgui.Create("DLabel",HFrame)
    WorldInfoLabel:SetPos(10,100)
    WorldInfoLabel:SetText("ⓘ World Level Tips: Each time the world level increases, so could every new NPC's LVL!\n Players start combo time also increases each level. \nOnce reaching world level 6+ the world will prestige and reset to level 1.")
    WorldInfoLabel:SetSize(600,50)

    local PresInfoLabel = vgui.Create("DLabel",HFrame)
    PresInfoLabel:SetPos(10,150)
    PresInfoLabel:SetText("ⓘ Prestige Tips: Prestiging also further increases NPC level cap and xp requirements.\n Every prestige level will provide players with one token, allowing for unique skills! (5 skill max.)")
    PresInfoLabel:SetSize(600,50)

    local PartInfoLabel = vgui.Create("DLabel",HFrame)
    PartInfoLabel:SetPos(10,200)
    PartInfoLabel:SetText("ⓘ Party Tips: Player's within the same party name have a chance to boost each other in various ways! \n You can help start or keep a surrounding member(s) timer alive by dealing dmg!\n Member(s) around each other can also generate XP depending on their last active or inactive combo kills.\n NPC's that aren't in combat with you can also help keep you timer stable by dealing damage to anyone.")
    PartInfoLabel:SetSize(600,50)

    local CommandinfoLabel = vgui.Create("DLabel",HFrame)
    CommandinfoLabel:SetPos(10,248)
    CommandinfoLabel:SetText("ⓘ Concommand Tips: wp_party, wp_vs, wp_debug, wp_stop, wp_reset, wp_token+, wp_token-, \nwp_prestige+, wp_prestige-, wp_world+, wp_world-, wp_csettings, wp_settings")
    CommandinfoLabel:SetSize(600,50)
    CommandinfoLabel:SetTextColor(Color(106,168,255))

    local DiffinfoLabel = vgui.Create("DLabel",HFrame)
    DiffinfoLabel:SetPos(10,290)
    DiffinfoLabel:SetText("ⓘ Difficulty Tips: Each difficulty affects the chances of higher levels to spawn.\n Each difficulty also effects world XP amount, XP gain, and combo start time (<- when the world gets stronger).\n In hard difficulty, combo time limit is ignored (no reduction when 60s+), but at the cost of stronger foes!")
    DiffinfoLabel:SetSize(600,50)

    local VsinfoLabel = vgui.Create("DLabel",HFrame)
    VsinfoLabel:SetPos(10,340)
    VsinfoLabel:SetText("ⓘ PVP / VS Mode Tips: (VS Mini Panel Mode recommended)\n With this mode toggled on aim for the top xp in the server while the world levels up as usual! \nKilling a player can allow you to steal their inactive kills to start a new timer with, or their current active combo kills!")
    VsinfoLabel:SetSize(600,50)
    VsinfoLabel:SetTextColor(Color(255,132,66))
end

function PrestigePanel()
  local fp = LocalPlayer()
  net.Start("GetPSSkills")
  net.WriteEntity(fp)
  net.SendToServer()

  net.Receive("PresSkillGet", function()
    local skilltable = net.ReadTable()
    skillList = skilltable
    local sm = 0
    for i = 1, #skillList do 
      if(type(skillList[i]) == "string" ) then
        sm = sm+1
      end
    end

    local PresFrame = vgui.Create("DFrame")
    PresFrame:SetPos(scrw / 2 - 50,40)
    PresFrame:SetSize(660,500)
    PresFrame:SetTitle("Prestige Skill Token Page")
    PresFrame:SetVisible(true)
    PresFrame:SetDraggable(true)
    PresFrame:ShowCloseButton(true)
    PresFrame:MakePopup()
    PresFrame.Paint = function(self,w,h)
      --draw.RoundedBox(0,0,0,w,h, Color(252,234,201,224))
      draw.RoundedBox(0,0,0,w,h, Color(215,241,255,245))
    end
    PresFrame.OnClose = function()
      local npt = LocalPlayer()
      SendTokens(pTok,npt)
    end

    local resetSkill = vgui.Create("DButton",PresFrame)
    resetSkill:SetText("Reset Skills")
    resetSkill:SetPos(250,450)
    resetSkill:SetSize(100,30)
    resetSkill.DoClick = function()
      if(sm <= 0)then
        LocalPlayer():ChatPrint("No current skills!")
      else
        PresFrame:Close()
        net.Start("resetSkills")
        net.WriteEntity(fp)
        net.SendToServer()
        SendTokens(pTok,fp)
      end
    end

    local resetSkillLabel = vgui.Create("DLabel",PresFrame)
    resetSkillLabel:SetPos(360,445)
    resetSkillLabel:SetText("⚠ Resetting skills will \nalso cost all you your XP &\n take one current token! ⚠")
    resetSkillLabel:SetSize(400,50)
    resetSkillLabel:SetTextColor(Color(252,27,27))

    local pinfoLabel = vgui.Create("DLabel",PresFrame)
    pinfoLabel:SetPos(8,3)
    pinfoLabel:SetText("Click the desired skill icon to purchase the skill.")
    pinfoLabel:SetSize(400,50)
    pinfoLabel:SetTextColor(Color(0,0,0))

    local PTLabel = vgui.Create("DLabel",PresFrame)
    PTLabel:SetPos(260,3)
    PTLabel:SetText("Prestige Tokens: " .. pTok)
    PTLabel:SetSize(400,50)
    if(pTok == 0) then
      PTLabel:SetTextColor(Color(255,0,0))
    elseif(pTok == 1) then
      PTLabel:SetTextColor(Color(255,241,38))
    elseif(pTok > 1) then
      PTLabel:SetTextColor(Color(42,181,20))
    end

    local PSTLabel = vgui.Create("DLabel",PresFrame)
    PSTLabel:SetPos(420,2)
    PSTLabel:SetText("Skill Amount: " .. sm .. "/5")
    PSTLabel:SetSize(400,50)
    if(sm == 5)then
      PSTLabel:SetTextColor(Color(255,0,0))
    else
      PSTLabel:SetTextColor(Color(81,87,84))
    end
    
  
    local xp2x = vgui.Create("DImageButton",PresFrame)
    xp2x:SetPos(58,90)
    xp2x:SetImage("icon16/cake.png")
    xp2x:SetSize(80,80)
    xp2x.DoClick = function()
      if(table.HasValue(skillList,"2x")) then
        LocalPlayer():ChatPrint("Perk in tree!")
      else
        if(pTok >= 2)then
          local add = false
          local max = 0
          for i = 1, #skillList do 
            if(type(skillList[i]) == "string" ) then
              max = max+1
            end
          end
          if(max >= 5) then
            LocalPlayer():ChatPrint("Max Skills!")
          else
            pTok = pTok-2
            LocalPlayer():ChatPrint("Acquired Double XP!")
            local skill = "2x"
            local size = 0
            for i = 1, #skillList do 
              if(skillList[i] == nil) then
                size = size+1
              end
  
              if(size < 4) then
                table.insert(skillList,"2x")
              end
  
            end
            local fp = LocalPlayer()
            net.Start("PresSkillSet")
            net.WriteString(skill)
            net.WriteEntity(fp)
            net.SendToServer()
            PresFrame:Close()
            local npt = LocalPlayer()
            SendTokens(pTok,npt)
            PrestigePanel()
          end
        
        else
          LocalPlayer():ChatPrint("Insufficent Tokens!")
        end
      end
      
    end
    local xp2Label = vgui.Create("DLabel",PresFrame)
    xp2Label:SetPos(50,140)
    xp2Label:SetText("Double XP gain once your\n KTC ends and give 1.5xp\n to nearby party members. \n        (stackable)")
    xp2Label:SetSize(145,145)
    xp2Label:SetTextColor(Color(10,0,0))
    local xp2Labelc = vgui.Create("DLabel",PresFrame)
    xp2Labelc:SetPos(58,4)
    xp2Labelc:SetText("       '2x XP'\n      Cost: 2")
    xp2Labelc:SetSize(120,120)
    if(table.HasValue(skillList,"fxCombo"))then
      xp2Labelc:SetText("Perk in tree")
    else
      if(pTok >= 2) then
        xp2Labelc:SetTextColor(Color(130,237,53))
      else
        xp2Labelc:SetTextColor(Color(255,82,77))
      end
    end
  
    local fxCombo = vgui.Create("DImageButton",PresFrame)
    fxCombo:SetPos(68,285)
    fxCombo:SetImage("icon16/fire.png")
    fxCombo:SetSize(90,90)
    fxCombo.DoClick = function()
      if(table.HasValue(skillList,"hfc")) then
        LocalPlayer():ChatPrint("Skill in tree!")
      else
        if(pTok >= 1)then
          local add = false
          local max = 0
          for i = 1, #skillList do 
            if(type(skillList[i]) == "string" ) then
              max = max+1
            end
          end
          if(max >= 5) then
            LocalPlayer():ChatPrint("Max Perks!")
          else
            pTok = pTok-1
            LocalPlayer():ChatPrint("Learned Hunters Fury!")
            local skill = "hfc"
            local size = 0
            for i = 1, #skillList do 
              if(skillList[i] == nil) then
                size = size+1
              end
  
              if(size < 4) then
                table.insert(skillList,skill)
              end
            end
            local fp = LocalPlayer()
            net.Start("PresSkillSet")
            net.WriteString(skill)
            net.WriteEntity(fp)
            net.SendToServer()
            PresFrame:Close()
            local npt = LocalPlayer()
            SendTokens(pTok,npt)
            PrestigePanel()
          end
        
        else
          LocalPlayer():ChatPrint("Insufficent Tokens!")
        end
      end
      
    end
  
    local fxComboLabel = vgui.Create("DLabel",PresFrame)
    fxComboLabel:SetPos(55,345)
    fxComboLabel:SetText("Kills also add +0.1 to a\nseperate kill chain (HTC)\nuntil the player is hurt,\ncausing the HTC to reset.")
    fxComboLabel:SetSize(125,125)
    fxComboLabel:SetTextColor(Color(0,0,0))
    local fxComboLabelc = vgui.Create("DLabel",PresFrame)
    fxComboLabelc:SetPos(68,184)
    fxComboLabelc:SetText("'Hunters Fury'\n      Cost: 1")
    fxComboLabelc:SetSize(150,155)
    if(table.HasValue(skillList,"hfc"))then
      fxComboLabelc:SetText("Perk in tree")
    else
      if(pTok >= 1) then
        fxComboLabelc:SetTextColor(Color(130,237,53))
      else
        fxComboLabelc:SetTextColor(Color(255,82,77))
      end
    end

    --Substitution
    local ComboS = vgui.Create("DImageButton",PresFrame)
    ComboS:SetPos(208,95)
    ComboS:SetImage("icon16/shield_delete.png")
    ComboS:SetSize(80,80)
    ComboS.DoClick = function()
      if(table.HasValue(skillList,"CS")) then
        LocalPlayer():ChatPrint("Perk in tree!")
      else
        if(pTok >= 1)then
          local add = false
          local max = 0
          for i = 1, #skillList do 
            if(type(skillList[i]) == "string" ) then
              max = max+1
            end
          end
          if(max >= 5) then
            LocalPlayer():ChatPrint("Max Perks!")
          else
            pTok = pTok-1
            LocalPlayer():ChatPrint("Learned Iron Skin!")
            local skill = "CS"
            local size = 0
            for i = 1, #skillList do 
              if(skillList[i] == nil) then
                size = size+1
              end
  
              if(size < 4) then
                table.insert(skillList,skill)
              end
            end
            local fp = LocalPlayer()
            net.Start("PresSkillSet")
            net.WriteString(skill)
            net.WriteEntity(fp)
            net.SendToServer()
            PresFrame:Close()
            local npt = LocalPlayer()
            SendTokens(pTok,npt)
            PrestigePanel()
          end
        
        else
          LocalPlayer():ChatPrint("Insufficent Tokens!")
        end
      end
      
    end
  
    local ComboSLabel = vgui.Create("DLabel",PresFrame)
    ComboSLabel:SetPos(208,145)
    ComboSLabel:SetText("Prevent any time loss\n on hit once per KTC,\n after that the KTC time\n loss is reduced by half.")
    ComboSLabel:SetSize(125,120)
    ComboSLabel:SetTextColor(Color(0,0,0))
    local ComboSLabelc = vgui.Create("DLabel",PresFrame)
    ComboSLabelc:SetPos(215,1)
    ComboSLabelc:SetText("  'Iron Skin'\n     Cost: 1")
    ComboSLabelc:SetSize(150,150)
    if(table.HasValue(skillList,"CS"))then
      ComboSLabelc:SetText("Perk in tree")
    else
      if(pTok >= 1) then
        ComboSLabelc:SetTextColor(Color(130,237,53))
      else
        ComboSLabelc:SetTextColor(Color(255,82,77))
      end
    end
    --shield
    local ShCombo = vgui.Create("DImageButton",PresFrame)
    ShCombo:SetPos(208,285)
    ShCombo:SetImage("icon16/shield_add.png")
    ShCombo:SetSize(80,80)
    ShCombo.DoClick = function()
      if(table.HasValue(skillList,"shC")) then
        LocalPlayer():ChatPrint("Perk in tree!")
      else
        if(pTok >= 2)then
          local add = false
          local max = 0
          for i = 1, #skillList do 
            if(type(skillList[i]) == "string" ) then
              max = max+1
            end
          end
          if(max >= 5) then
            LocalPlayer():ChatPrint("Max Perk!")
          else
            pTok = pTok-2
            LocalPlayer():ChatPrint("Acquired Shield Syphon!")
            local skill = "shC"
            local size = 0
            for i = 1, #skillList do 
              if(skillList[i] == nil) then
                size = size+1
              end
  
              if(size < 4) then
                table.insert(skillList,skill)
              end
            end
            local fp = LocalPlayer()
            net.Start("PresSkillSet")
            net.WriteString(skill)
            net.WriteEntity(fp)
            net.SendToServer()
            PresFrame:Close()
            local npt = LocalPlayer()
            SendTokens(pTok,npt)
            PrestigePanel()
          end
        
        else
          LocalPlayer():ChatPrint("Insufficent Tokens!")
        end
      end
    end
  
    local ShieldComboLabel = vgui.Create("DLabel",PresFrame)
    ShieldComboLabel:SetPos(208,345)
    ShieldComboLabel:SetText("Your kills while your \nKTC is active will be \nconverted into shields\n when the KTC ends.")
    ShieldComboLabel:SetSize(120,120)
    ShieldComboLabel:SetTextColor(Color(10,0,0))
    local ShieldComboLabelc = vgui.Create("DLabel",PresFrame)
    ShieldComboLabelc:SetPos(208,204)
    ShieldComboLabelc:SetText("'Shield Syphon' \n       Cost: 2")
    ShieldComboLabelc:SetSize(120,120)
    if(table.HasValue(skillList,"shC"))then
      ShieldComboLabelc:SetText("Perk in tree")
    else
      if(pTok >= 2) then
        ShieldComboLabelc:SetTextColor(Color(130,237,53))
      else
        ShieldComboLabelc:SetTextColor(Color(255,82,77))
      end
    end
    
  --Boots
    local tBoots = vgui.Create("DImageButton",PresFrame)
    tBoots:SetPos(350,75)
    tBoots:SetImage("icon16/car.png")
    tBoots:SetSize(90,90)
    tBoots.DoClick = function()
      if(table.HasValue(skillList,"tBt")) then
        LocalPlayer():ChatPrint("Perk in tree!")
      else
        if(pTok >= 1)then
          local add = false
          local max = 0
          for i = 1, #skillList do 
            if(type(skillList[i]) == "string" ) then
              max = max+1
            end
          end
          if(max >= 5) then
            LocalPlayer():ChatPrint("Max Perks!")
          else
            pTok = pTok-1
            LocalPlayer():ChatPrint("Acquired Cranked Boots!")
            local skill = "tBt"
            local size = 0
            for i = 1, #skillList do 
              if(skillList[i] == nil) then
                size = size+1
              end
  
              if(size < 4) then
                table.insert(skillList,skill)
              end
            end
            local fp = LocalPlayer()
            net.Start("PresSkillSet")
            net.WriteString(skill)
            net.WriteEntity(fp)
            net.SendToServer()
            PresFrame:Close()
            local npt = LocalPlayer()
            SendTokens(pTok,npt)
            PrestigePanel()
          end
        
        else
          LocalPlayer():ChatPrint("Insufficent Tokens!")
        end
      end
    end
  
    local tBootsLabel = vgui.Create("DLabel",PresFrame)
    tBootsLabel:SetPos(353,148)
    tBootsLabel:SetText("Dealing damage\n increases your \nmovement speed\n while a KTC is active.")
    tBootsLabel:SetSize(100,100)
    tBootsLabel:SetTextColor(Color(10,0,0))
    local tBootsc = vgui.Create("DLabel",PresFrame)
    tBootsc:SetPos(350,10)
    tBootsc:SetSize(100,100)
    if(table.HasValue(skillList,"tBt"))then
      tBootsc:SetText("Perk in tree")
    else
      tBootsc:SetText(" 'Cranked Boots'\n        Cost: 1")
      if(pTok >= 1) then
        tBootsc:SetTextColor(Color(130,237,53))
      else
        tBootsc:SetTextColor(Color(255,82,77))
      end
    end
  
    local tLeader = vgui.Create("DImageButton",PresFrame)
    tLeader:SetPos(350,280)
    tLeader:SetImage("icon16/group_go.png")
    tLeader:SetSize(80,80)
    tLeader.DoClick = function()
      if(table.HasValue(skillList,"tlS")) then
        LocalPlayer():ChatPrint("Perk in tree!")
      else
        if(pTok >= 1)then
          local add = false
          local max = 0
          for i = 1, #skillList do 
            if(type(skillList[i]) == "string" ) then
              max = max+1
            end
          end
          if(max >= 5) then
            LocalPlayer():ChatPrint("Max Perks!")
          else
            pTok = pTok-1
            LocalPlayer():ChatPrint("Learned NPC Party!")
            local skill = "tlS"
            local size = 0
            for i = 1, #skillList do 
              if(skillList[i] == nil) then
                size = size+1
              end
  
              if(size < 4) then
                table.insert(skillList,skill)
              end
            end
            local fp = LocalPlayer()
            net.Start("PresSkillSet")
            net.WriteString(skill)
            net.WriteEntity(fp)
            net.SendToServer()
            PresFrame:Close()
            local npt = LocalPlayer()
            SendTokens(pTok,npt)
            PrestigePanel()
          end
        
        else
          LocalPlayer():ChatPrint("Insufficent Tokens!")
        end
      end
    end
  
    local tLeaderLabel = vgui.Create("DLabel",PresFrame)
    tLeaderLabel:SetPos(350,345)
    tLeaderLabel:SetText("NPC KTC assist time\nis increased, NPC kills \nnow aid in KTC, NPCs can\n now start a KTC for you.")
    tLeaderLabel:SetSize(135,120)
    tLeaderLabel:SetTextColor(Color(0,0,0))
    local tLeadersc = vgui.Create("DLabel",PresFrame)
    tLeadersc:SetPos(365,205)
    if(table.HasValue(skillList,"tlS"))then
      tLeadersc:SetText("Perk in tree")
    else
      tLeadersc:SetText("'NPC Party'\n  Cost: 1")
      if(pTok >= 1) then
        tLeadersc:SetTextColor(Color(130,237,53))
      else
        tLeadersc:SetTextColor(Color(255,82,77))
      end
    end
    tLeadersc:SetSize(100,100)
  
    local vamp = vgui.Create("DImageButton",PresFrame)
    vamp:SetPos(500,75)
    vamp:SetImage("icon16/heart_add.png")
    vamp:SetSize(80,80)
    vamp.DoClick = function()
      if(table.HasValue(skillList,"vamp")) then
        LocalPlayer():ChatPrint("Perk in tree!")
      else
        if(pTok >= 3)then
          local add = false
          local max = 0
          for i = 1, #skillList do 
            if(type(skillList[i]) == "string" ) then
              max = max+1
            end
          end
          if(max >= 5) then
            LocalPlayer():ChatPrint("Max Perks!")
          else
            pTok = pTok-3
            LocalPlayer():ChatPrint("Acquired Vampric Abrasion!")
            local skill = "vamp"
            local size = 0
            for i = 1, #skillList do 
              if(skillList[i] == nil) then
                size = size+1
              end
  
              if(size < 4) then
                table.insert(skillList,skill)
              end
            end
            local fp = LocalPlayer()
            net.Start("PresSkillSet")
            net.WriteString(skill)
            net.WriteEntity(fp)
            net.SendToServer()
            PresFrame:Close()
            local npt = LocalPlayer()
            SendTokens(pTok,npt)
            PrestigePanel()
          end
        
        else
          LocalPlayer():ChatPrint("Insufficent Tokens!")
        end
      end
    end

    local vampLabel = vgui.Create("DLabel",PresFrame)
    vampLabel:SetPos(500,140)
    vampLabel:SetText("Dealing dmg siphons\n 1/150 of target health, \n headshot dmg will \n provide 1/100 health.")
    vampLabel:SetSize(120,100)
    vampLabel:SetTextColor(Color(0,0,0))
    local vampsc = vgui.Create("DLabel",PresFrame)
    vampsc:SetPos(500,5)
    if(table.HasValue(skillList,"vamp"))then
      vampsc:SetText("Perk in tree")
    else
      vampsc:SetText("'Vampiric Abrasion'\n       Cost: 3")
      if(pTok >= 3) then
        vampsc:SetTextColor(Color(130,237,53))
      else
        vampsc:SetTextColor(Color(255,82,77))
      end
    end
    vampsc:SetSize(120,120)

    local cohSkill = vgui.Create("DImageButton",PresFrame)
    cohSkill:SetPos(500,280)
    cohSkill:SetImage("icon16/clock_add.png")
    cohSkill:SetSize(80,80)
    cohSkill.DoClick = function()
      if(table.HasValue(skillList,"coh")) then
        LocalPlayer():ChatPrint("Perk in tree!")
      else
        if(pTok >= 2)then
          local add = false
          local max = 0
          for i = 1, #skillList do 
            if(type(skillList[i]) == "string" ) then
              max = max+1
            end
          end
          if(max >= 5) then
            LocalPlayer():ChatPrint("Max Skills!")
          else
            pTok = pTok-2
            LocalPlayer():ChatPrint("Granted Covenant of Harrow!")
            local skill = "coh"
            local size = 0
            for i = 1, #skillList do 
              if(skillList[i] == nil) then
                size = size+1
              end
  
              if(size < 4) then
                table.insert(skillList,skill)
              end
            end
            local fp = LocalPlayer()
            net.Start("PresSkillSet")
            net.WriteString(skill)
            net.WriteEntity(fp)
            net.SendToServer()
            PresFrame:Close()
            local npt = LocalPlayer()
            SendTokens(pTok,npt)
            PrestigePanel()
          end
        
        else
          LocalPlayer():ChatPrint("Insufficent Tokens!")
        end
      end
    end
  
    local cohSkillLabel = vgui.Create("DLabel",PresFrame)
    cohSkillLabel:SetPos(500,320)
    cohSkillLabel:SetText("Headshot dmg now\nadds extra KTC time,\nheadshot dmg on a\n target near death\n   adds more.")
    cohSkillLabel:SetSize(145,165)
    cohSkillLabel:SetTextColor(Color(0,0,0))
    local cohSkillsc = vgui.Create("DLabel",PresFrame)
    cohSkillsc:SetPos(500,205)
    cohSkillsc:SetText("'Covenant of Harrow'\n        Cost: 2")
    if(table.HasValue(skillList,"coh"))then
      cohSkillsc:SetText("Skill in tree")
    elseif(pTok >= 2) then
        cohSkillsc:SetTextColor(Color(130,237,53))
    else
        cohSkillsc:SetTextColor(Color(255,82,77))
    end
    cohSkillsc:SetSize(120,120)
  
  end)

end

--CLIENT SIDE SETTINGS PANEL
function Csettingpanel()
  local fp = LocalPlayer()
      net.Start("plyCSettings")
      net.WriteEntity(fp)
      net.SendToServer()

      net.Receive("PlySettings", function()
       plyDM = net.ReadBool()
       if(plyDM == nil)then
         plyDM = false
       end
       plyPM = net.ReadBool()
       if(plyPM == nil)then
        plyPM = false
      end
        fp = net.ReadEntity()
          local CSFrame = vgui.Create("DFrame")
          CSFrame:SetPos(ScrW() / 2,ScrH() / 2)
          CSFrame:SetSize(300,250)
          CSFrame:SetTitle("Client Settings")
          CSFrame:SetVisible(true)
          CSFrame:SetDraggable(true)
          CSFrame:ShowCloseButton(true)
          CSFrame:MakePopup()
          CSFrame:SetKeyboardInputEnabled(false)
          CSFrame.Paint = function(self, w, h)
          draw.RoundedBox(0,0,0,w,h, Color(13,13,10,233))
        end

        local cb1 = CSFrame:Add("DCheckBoxLabel")
        cb1:SetPos(10,50)
        cb1:SetText("World UI Information")
        cb1:SetTextColor(Color(255,255,255))
        cb1:SetValue(wrldinfoUI)
        cb1:SizeToContents()
        cb1.OnChange = function(chkbox)
          local wrldinfoUIx = cb1:GetChecked()
          wrldinfoUI = wrldinfoUIx
          WHudRefresh()
        end
        local cb2 = CSFrame:Add("DCheckBoxLabel")
        cb2:SetPos(10,80)
        cb2:SetText("Timer & Combo UI Information")
        cb2:SetTextColor(Color(255,255,255))
        cb2:SetValue(TCUI)
        cb2:SizeToContents()
        cb2.OnChange = function(chkbox)
          TCUI = cb2:GetChecked()
          if(TCUI == false)then
            hook.Remove("HUDPaint", "HUDPaint_CTIME")
            hook.Remove("HUDPaint", "HUDPaint_COMBO")
          end
        end
        local cb3 = CSFrame:Add("DCheckBoxLabel")
        cb3:SetPos(10,120)
        cb3:SetText("NPC UI Information")
        cb3:SetTextColor(Color(255,255,255))
        cb3:SetValue(NPCinfoUI)
        cb3:SizeToContents()
        cb3.OnChange = function(chkbox)
          NPCinfoUI = cb3:GetChecked()
        end
        local cb4 = CSFrame:Add("DCheckBoxLabel")
        cb4:SetPos(10,150)
        cb4:SetText("Player Combo UI Information (When looking at them)")
        cb4:SetTextColor(Color(255,255,255))
        cb4:SetValue(plyinfoUI)
        cb4:SizeToContents()
        cb4.OnChange = function(chkbox)
          plyinfoUI = cb4:GetChecked()
        end

        local cb5 = CSFrame:Add("DCheckBoxLabel")
        cb5:SetPos(10,180)
        cb5:SetText("Party System")
        cb5:SetTextColor(Color(255,255,255))
        cb5:SetValue(plyPM)
        cb5:SizeToContents()
        cb5.OnChange = function(chkbox)
          plyPM = cb5:GetChecked()
          net.Start("PartyS")
          net.WriteBool(plyPM)
          net.WriteEntity(fp)
          net.SendToServer()
        end

      end)
end

function Ssettingpanel()
  RefreshLUI(LocalPlayer())
  local SSFrame = vgui.Create("DFrame")
  SSFrame:SetPos(ScrW() / 2,ScrH() / 2)
  SSFrame:SetSize(300,150)
  SSFrame:SetTitle("Server Settings")
  SSFrame:SetVisible(true)
  SSFrame:SetDraggable(true)
  SSFrame:ShowCloseButton(true)
  SSFrame:MakePopup()
  SSFrame:SetKeyboardInputEnabled(false)
  SSFrame.Paint = function(self, w, h)
      draw.RoundedBox(0,0,0,w,h, Color(0,0,0,231))
    end

    local difcb = vgui.Create("DComboBox", SSFrame)
    local v = ""
    if(worldD == 1) then
      v = "Easy"
      elseif(worldD == 2)then
       v = "Normal"
      elseif(worldD ==3 ) then
        v = "Hard"
      else
        v = "Custom"
    end
    difcb:SetPos(10,20)
    difcb:SetSize(100,20)
    difcb:SetValue(v)
    difcb:AddChoice("Easy","easy")
    difcb:AddChoice("Normal","norm")
    difcb:AddChoice("Hard", "hard")
    
    difcb.OnSelect = function(self,index,value)
      local fp = LocalPlayer()
      net.Start("WorldDiff")
      net.WriteEntity(fp)
      net.WriteString(value)
      net.SendToServer()
      difcb:SetValue(value)
    end

    local prescb = vgui.Create("DCheckBoxLabel", SSFrame)
    prescb:SetPos(10,50)
    prescb:SetText("Prestige System")
    prescb:SetTextColor(Color(255,255,255))
    prescb:SetValue(presmode)
    prescb:SizeToContents()
    prescb.OnChange = function(chkbox)
      if(LocalPlayer():IsAdmin())then
        presmode = prescb:GetChecked()
        if(presmode == true) then
          LocalPlayer():ChatPrint("(" ..LocalPlayer():GetName() .. ")" .. "Prestige System Activated!")
          SendPresys(presmode,LocalPlayer())
        else
          LocalPlayer():ChatPrint("(" .. LocalPlayer():GetName() .. ")" .. "Prestige System Deactivated!")
          SendPresys(presmode,LocalPlayer())
        end
      else
        LocalPlayer():ChatPrint("You must be admin to change server settings.")
      end
    end

    local npcb = vgui.Create("DCheckBoxLabel", SSFrame)
    npcb:SetPos(10,80)
    npcb:SetText("NPC Timer Assist")
    npcb:SetTextColor(Color(255,255,255))
    npcb:SetValue(npcmode)
    npcb:SizeToContents()
    npcb.OnChange = function(chkbox)
      if(LocalPlayer():IsAdmin())then
        npcmode = npcb:GetChecked()
        if(npcmode == true) then
          LocalPlayer():ChatPrint("(" ..LocalPlayer():GetName() .. ")" .. "NPC Timer Assist Activated!")
          SendNPCHelp(npcmode,LocalPlayer())
        else
          LocalPlayer():ChatPrint("(" .. LocalPlayer():GetName() .. ")" .. "NPC Timer Assist Deactivated!")
          SendNPCHelp(npcmode,LocalPlayer())
        end
      else
        LocalPlayer():ChatPrint("You must be admin to change server settings.")
      end
    end

    local pvpcb = vgui.Create("DCheckBoxLabel", SSFrame)
       pvpcb:SetPos(10,110)
       pvpcb:SetText("XP VS Mode")
       pvpcb:SetTextColor(Color(255,255,255))
       pvpcb:SetValue(pvpmode)
       pvpcb:SizeToContents()
       pvpcb.OnChange = function(chkbox)
        if(LocalPlayer():IsAdmin())then
          local npvpmode = pvpcb:GetChecked()
          if(npvpmode == true) then
            LocalPlayer():ChatPrint("(" ..LocalPlayer():GetName() .. ")" .. "PVP / VS Mode Activated!")
           SendPVPS(npvpmode,LocalPlayer())
          else
            LocalPlayer():ChatPrint("(" .. LocalPlayer():GetName() .. ")" .. "PVP / VS Mode Deactivated!")
           SendPVPS(npvpmode,LocalPlayer())
          end
        else
          LocalPlayer():ChatPrint("You must be admin to change server settings.")
        end
      end

      local csys = vgui.Create("DCheckBoxLabel", SSFrame)
      csys:SetPos(10,135)
      csys:SetText("Combo System")
      csys:SetTextColor(Color(255,255,255))
      csys:SetValue(true)
      csys:SizeToContents()
      csys.OnChange = function(chkbox)
        if(LocalPlayer():IsAdmin())then
          local csysmode = csys:GetChecked()
          if(csysmode == true) then
           LocalPlayer():ConCommand("wp_combosys")
          else
            LocalPlayer():ConCommand("wp_combosys")
          end
        else
          LocalPlayer():ChatPrint("You must be admin to change server settings.")
        end
      end
end

hook.Add("AddToolMenuCategories", "WorldProgCat",function()
  spawnmenu.AddToolCategory("Utilities","World Progression","#World Progression")
end)

concommand.Add("openworldui", function ()
  --create call to server to reupdate plyr values before panel
  local fp = LocalPlayer()
  net.Start("uiSend")
  net.WriteEntity(fp)
  net.SendToServer()
end)

concommand.Add("updatecombotime", function ()
  --create call to server to reupdate World Combo TIme values 
  if(LocalPlayer():IsAdmin())then
    LocalPlayer():ChatPrint("Combo Start Time to: Cannot be editted since in development." )
   else
     LocalPlayer():ChatPrint("Must be admin to set this value")
  end

end)

concommand.Add("deathxp", function ()
  --create call to server to reupdate death xp values
     if(LocalPlayer():IsAdmin())then
        LocalPlayer():ChatPrint("Death xp loss set to: Cannot be editted since in development." )
       else
         LocalPlayer():ChatPrint("Must be admin to set this value")
      end
end)

concommand.Add("defaultSet", function ()
  --create call to server to reupdate death xp values
  local fp = LocalPlayer()
  net.Start("DefWrld")
  net.WriteEntity(fp)
  net.SendToServer()
end)

concommand.Add("wp_help", function ()
  Helppanel()
end)

concommand.Add("wp_csettings", function ()
  Csettingpanel()
end)

concommand.Add("wp_settings", function()
  Ssettingpanel()
end)

concommand.Add("wp_mc", function()
  if(lockedUI != nil)then
    lockedUI:Close()
  end

  if(lockedUI != nil)then
    lockedpUI:Close()
  end
end)

concommand.Add("wp_resetp", function()
  local fp = LocalPlayer()
  net.Start("ResetPly")
  net.WriteEntity(fp)
  net.SendToServer()
end)

concommand.Add("wp_save", function()
  local fp = LocalPlayer()
  net.Start("SaveWrld")
  net.WriteEntity(fp)
  net.SendToServer()
end)

concommand.Add("wp_load", function()
  local fp = LocalPlayer()
  net.Start("LoadWrld")
  net.WriteEntity(fp)
  net.SendToServer()
end)

concommand.Add("wp_reseths", function()
  chainHS = 0
  timeHS = 0
  LocalPlayer():PrintMessage(3,"Your highscores have been reset.")
end)

hook.Add("PopulateToolMenu","WorldProgSettings", function()
  spawnmenu.AddToolMenuOption("Utilities","World Progression","WPC_Settings","#Client", "", "", function(panel)
    local txt = "can also bind 'key' worldprogp"
    panel:Add(txt)
    panel:Button("⚠ End Combo Timer ⚠", "wp_stop")
    panel:Button("World Progression Panel", "openworldui")
    panel:Button("Prestige Panel", "wp_ppanel")
    panel:Button("⚙ Client Settings ⚙", "wp_csettings")
    panel:Button("ⓘ Help ⓘ", "wp_help")
    panel:Button("ⓘ Close Mini Panel(s) ⓘ", "wp_mc")
    panel:Button("⚠ Reset Your HighScores ⚠", "wp_reseths")
  end)

  spawnmenu.AddToolMenuOption("Utilities","World Progression","WPS_Settings","#Server", "", "", function(panel)
    panel:Button("↑  Increase Level ↑ ", "wp_world+")
    panel:Button("↓  Decrease Level ↓ ", "wp_world-")
    panel:Button("↑  Increase Prestige ↑ ", "wp_prestige+")
    panel:Button("↓  Decrease Prestige ↓ ", "wp_prestige-")
    panel:Button("↑  Add Token ↑ ", "wp_token+")
    panel:Button("↓  Remove Token ↓ ", "wp_token-")
    panel:Button("⚙ Server Settings ⚙", "wp_settings")
    panel:Button("⚠ Reset the World ⚠", "wp_reset")
  end)
end)


concommand.Add("wp_ppanel", function (ply)
  PrestigePanel()
end)

--BINDS
hook.Add("PlayerBindPress", "Worldprogpm", function(ply,bind,pressed)
  if string.find(bind,"worldprogp") then
    if(pressed == true) then
      net.Start("wpbind")
      net.WriteEntity(ply)
      net.SendToServer()
    end
  end
end)
