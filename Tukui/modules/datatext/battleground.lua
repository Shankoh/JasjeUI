local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales

if not C["datatext"].battleground then return end

--Map IDs
local WSG = 443
local TP = 626
local AV = 401
local SOTA = 512
local IOC = 540
local EOTS = 482
local TBFG = 736
local AB = 461

local bgframe = TukuiInfoLeftBattleGround
bgframe:SetScript("OnEnter", function(self)
	local numScores = GetNumBattlefieldScores()
	for i=1, numScores do
		local name, killingBlows, honorableKills, deaths, honorGained, faction, race, class, classToken, damageDone, healingDone, bgRating, ratingChange = GetBattlefieldScore(i)
		if ( name ) then
			if ( name == UnitName("player") ) then
				local curmapid = GetCurrentMapAreaID()
				local color = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
				local classcolor = ("|cff%.2x%.2x%.2x"):format(color.r * 255, color.g * 255, color.b * 255)
				SetMapToCurrentZone()			
				GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, T.Scale(4))
				GameTooltip:ClearLines()
				GameTooltip:Point("BOTTOM", self, "TOP", 0, 1)
				GameTooltip:ClearLines()
				GameTooltip:AddDoubleLine(L.datatext_ttstatsfor, classcolor..name.."|r")
				GameTooltip:AddLine' '
				GameTooltip:AddDoubleLine(L.datatext_ttkillingblows, killingBlows,1,1,1)
				GameTooltip:AddDoubleLine(L.datatext_tthonorkills, honorableKills,1,1,1)
				GameTooltip:AddDoubleLine(L.datatext_ttdeaths, deaths,1,1,1)
				GameTooltip:AddDoubleLine(L.datatext_tthonorgain, format('%d', honorGained),1,1,1)
				GameTooltip:AddDoubleLine(L.datatext_ttdmgdone, damageDone,1,1,1)
				GameTooltip:AddDoubleLine(L.datatext_tthealdone, healingDone,1,1,1)
				--Add extra statistics to watch based on what BG you are in.
				if curmapid == WSG or curmapid == TP then 
					GameTooltip:AddDoubleLine(L.datatext_flagscaptured,GetBattlefieldStatData(i, 1),1,1,1)
					GameTooltip:AddDoubleLine(L.datatext_flagsreturned,GetBattlefieldStatData(i, 2),1,1,1)
				elseif curmapid == EOTS then	
                    GameTooltip:AddDoubleLine(L.datatext_flagscaptured,GetBattlefieldStatData(i, 1),1,1,1)
				elseif curmapid == AV then
					GameTooltip:AddDoubleLine(L.datatext_graveyardsassaulted,GetBattlefieldStatData(i, 1),1,1,1)
					GameTooltip:AddDoubleLine(L.datatext_graveyardsdefended,GetBattlefieldStatData(i, 2),1,1,1)
					GameTooltip:AddDoubleLine(L.datatext_towersassaulted,GetBattlefieldStatData(i, 3),1,1,1)
					GameTooltip:AddDoubleLine(L.datatext_towersdefended,GetBattlefieldStatData(i, 4),1,1,1)
				elseif curmapid == SOTA then
					GameTooltip:AddDoubleLine(L.datatext_demolishersdestroyed,GetBattlefieldStatData(i, 1),1,1,1)
					GameTooltip:AddDoubleLine(L.datatext_gatesdestroyed,GetBattlefieldStatData(i, 2),1,1,1)
				elseif curmapid == IOC or curmapid == TBFG or curmapid == AB then
					GameTooltip:AddDoubleLine(L.datatext_basesassaulted,GetBattlefieldStatData(i, 1),1,1,1)
					GameTooltip:AddDoubleLine(L.datatext_basesdefended,GetBattlefieldStatData(i, 2),1,1,1)
				end					
				GameTooltip:Show()
			end
		end
	end
end) 
bgframe:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

local Stat = CreateFrame("Frame")
Stat:EnableMouse(true)

local Text1  = TukuiInfoLeftBattleGround:CreateFontString(nil, "OVERLAY")
Text1:SetFont(C["datatext"].font, C["datatext"].fontsize,C["datatext"].fontflag)
Text1:SetPoint("LEFT", TukuiInfoLeftBattleGround, 30, 0.5)
Text1:SetHeight(TukuiInfoLeft:GetHeight())

local Text2  = TukuiInfoLeftBattleGround:CreateFontString(nil, "OVERLAY")
Text2:SetFont(C["datatext"].font, C["datatext"].fontsize,C["datatext"].fontflag)
Text2:SetPoint("CENTER", TukuiInfoLeftBattleGround, 0, 0.5)
Text2:SetHeight(TukuiInfoLeft:GetHeight())

local Text3  = TukuiInfoLeftBattleGround:CreateFontString(nil, "OVERLAY")
Text3:SetFont(C["datatext"].font, C["datatext"].fontsize,C["datatext"].fontflag)
Text3:SetPoint("RIGHT", TukuiInfoLeftBattleGround, -30, 0.5)
Text3:SetHeight(TukuiInfoLeft:GetHeight())

local int = 2
local function Update(self, t)
	int = int - t
	if int < 0 then
		local dmgtxt
		RequestBattlefieldScoreData()
		local numScores = GetNumBattlefieldScores()
		for i=1, numScores do
			local name, killingBlows, honorableKills, deaths, honorGained, faction, race, class, classToken, damageDone, healingDone, bgRating, ratingChange = GetBattlefieldScore(i)
			if healingDone > damageDone then
				dmgtxt = (hexa..L.datatext_healing..hexb..healingDone)
			else
				dmgtxt = (hexa..L.datatext_damage..hexb..damageDone)
			end
			if ( name ) then
				if ( name == T.myname ) then
					Text2:SetText(hexa..L.datatext_honor..hexb..format('%d', honorGained))
					Text1:SetText(dmgtxt)
					Text3:SetText(hexa..L.datatext_killingblows..hexb..killingBlows)
				end   
			end
		end 
		int  = 2
	end
end

--hide text when not in an bg
local function OnEvent(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
		local inInstance, instanceType = IsInInstance()
		if inInstance and (instanceType == "pvp") then
			bgframe:Show()
		else
			Text1:SetText("")
			Text2:SetText("")
			Text3:SetText("")
			bgframe:Hide()
		end
	end
end

Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
Stat:SetScript("OnEvent", OnEvent)
Stat:SetScript("OnUpdate", Update)
Update(Stat, 2)