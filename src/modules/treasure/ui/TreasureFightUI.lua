module(..., package.seeall)
local HeroFightListUI = require("src/ui/HeroFightListUI")
setmetatable(_M, {__index = HeroFightListUI})
local Hero = require("src/modules/hero/Hero")
local Treasure = require("src/modules/treasure/Treasure")
local TreasureConfig = require("src/config/TreasureConfig").Config
local FightControl = require("src/modules/fight/FightControl")
local FBConfig = require("src/config/FBConfig").Config
local Monster = require("src/modules/hero/Monster")
local ChapterDefine = require("src/modules/chapter/ChapterDefine")
local Common = require("src/core/utils/Common")
local TDefine = require("src/modules/treasure/TreasureDefine")
local HDef = require("src/modules/hero/HeroDefine")
local Enemy = require("src/modules/hero/Enemy")
function new(mode,forbid,mineId,guards)
	local enemies = {}
	local btnName
	if mode == TDefine.MODE_FIGHT then
		if guards and next(guards) then
			for i=1,math.max(1,#guards) do
				if guards[i].name and guards[i].name ~= '' then
					enemies[i] = Enemy.new(guards[i].name,0,guards[i].lv,guards[i].quality,0,guards[i].dyAttr,guards[i].skillGroupList,guards[i].gift)
				else
					enemies[i] = nil
				end
			end
			enemies[4] = Enemy.new(guards[#guards].name,0,guards[#guards].lv,guards[#guards].quality,0,guards[#guards].dyAttr,guards[#guards].skillGroupList,guards[#guards].gift)
		else
			local monster = TreasureConfig[mineId].monster
			enemies = Monster.getMonsterObjectByIdList(monster)
		end
		btnName = "fight"
	else
		btnName = "save"
	end


	local ctrl = HeroFightListUI.new(enemies)
	setmetatable(ctrl,{__index = _M})
	ctrl.name = "TreasureFightUI"
	ctrl.forbiden = forbid
	ctrl.mineId = mineId
	ctrl.mode = mode
	ctrl:init(btnName)
	return ctrl
end

function onClose(self,event,target)
	if event.etype == Event.Touch_ended then
		UIManager.removeUI(self)
		local ui = UIManager.getUI("TreasureMain")
		if ui then
			ui:refreshData()
			local mineInfo = Treasure.mine[self.mineId]
			if mineInfo then
				ui:showMineInfo(mineInfo)
			end
		end
	end
end


function addStage(self)
	self:setPositionY(Stage.uiBottom)
end

-- function getFightList(self)
-- 	local flist = {}
-- 	for i=1,4 do 
-- 		if self.heroFightList[i] then
-- 			table.insert(flist,self.heroFightList[i])
-- 		end
-- 	end
-- 	return flist
-- end

function getFightList(self)
	local flist = {}
	for i=1,4 do 
		if self.heroFightList[i] then
			table.insert(flist,self.heroFightList[i])
		else
			table.insert(flist,'')
		end
	end
	return flist
end

function onFightEnd(self,event) 
	-- if self.pid == PacketID.CG_TREASURE_END_OCCUPY then
		if event.winer == 'A' then
			Network.sendMsg(PacketID.CG_TREASURE_END_OCCUPY,TDefine.WIN,self.mineId,self:getFightList())
		else
			Network.sendMsg(PacketID.CG_TREASURE_END_OCCUPY,TDefine.DEFEATED,self.mineId,self:getFightList())
		end
	-- elseif self.pid == PacketID.CG_TREASURE_END_ROB then
	-- 	if event.winer == 'A' then
	-- 		Network.sendMsg(PacketID.CG_TREASURE_END_ROB,TDefine.WIN,self.districtId,self.mineId,self:getFightList())
	-- 	else
	-- 		Network.sendMsg(PacketID.CG_TREASURE_END_ROB,TDefine.DEFEATED,self.districtId,self.mineId)
	-- 	end
	-- elseif self.pid == PacketID.CG_TREASURE_END_ASSIST then
	-- 	if event.winer == 'A' then
	-- 		Network.sendMsg(PacketID.CG_TREASURE_END_ASSIST,TDefine.WIN,self.districtId,self.mineId,self:getFightList())
	-- 	else
	-- 		Network.sendMsg(PacketID.CG_TREASURE_END_ASSIST,TDefine.DEFEATED,self.districtId,self.mineId)
	-- 	end
	-- end 
end
function toFightScene(self)
	
end
function goFight(self)
	HeroFightListUI.toFightScene(self)
end

-- function onFight(self,event,target)
-- 	print('onFight etype='..event.etype)


-- 	-- if Common.GetTbNum(self.heroFightList) == 0 then
-- 	-- 	TipsUI.showTipsOnlyConfirm("请先上阵英雄，然后开始战斗")
-- 	if self:canFight() then
-- 		-- Network.sendMsg(PacketID.CG_CHAPTER_FB_END,fbId,ChapterDefine.WIN)
-- 		local fightHeroes = {}
-- 		local heroName = ""
-- 		for _,hname in pairs(self.heroFightList) do
-- 			local h = Hero.getHero(hname)
-- 			heroName = hname
-- 			if h then
-- 				table.insert(fightHeroes,h)
-- 			end
-- 		end
-- 		-- if #fightHeroes < 4 then
-- 		-- 	table.insert(fightHeroes,Hero.getHero(heroName))
-- 		-- end
-- 		-- local hero = Hero.getHero("Terry2")
-- 		local enemies = {}
-- 		if next(self.monsters) then
-- 			for _,monsterId in ipairs(self.monsters) do 
-- 				print('monsterId='..monsterId)
-- 				table.insert(enemies,Monster.MonsterList[monsterId])
-- 			end
-- 		else
-- 			for _,h in ipairs(self.guards) do
-- 				local e = Enemy.new(h.name,0,h.lv,h.quality,0,h.dyAttr,h.skillGroupList)
-- 				table.insert(enemies,e)
-- 			end
-- 		end
		
-- 		local fightControl = FightControl.new(fightHeroes,enemies)
-- 		local scene = require("src/scene/FightScene").new(fightControl)
-- 		scene:addEventListener(Event.FightEnd,function(self,event)
-- 			Common.printR(self.heroFightList)
-- 			if self.pid == PacketID.CG_TREASURE_END_OCCUPY then
-- 				if event.winer == 'A' then
-- 					Network.sendMsg(PacketID.CG_TREASURE_END_OCCUPY,TDefine.WIN,self.regionId,self.districtId,self.mineId,self:getFightList())
-- 				else
-- 					Network.sendMsg(PacketID.CG_TREASURE_END_OCCUPY,TDefine.DEFEATED,self.regionId,self.districtId,self.mineId)
-- 				end
-- 			elseif self.pid == PacketID.CG_TREASURE_END_ROB then
-- 				if event.winer == 'A' then
-- 					Network.sendMsg(PacketID.CG_TREASURE_END_ROB,TDefine.WIN,self.regionId,self.districtId,self.mineId,self:getFightList())
-- 				else
-- 					Network.sendMsg(PacketID.CG_TREASURE_END_ROB,TDefine.DEFEATED,self.regionId,self.districtId,self.mineId)
-- 				end
-- 			elseif self.pid == PacketID.CG_TREASURE_END_ASSIST then
-- 				if event.winer == 'A' then
-- 					Network.sendMsg(PacketID.CG_TREASURE_END_ASSIST,TDefine.WIN,self.regionId,self.districtId,self.mineId,self:getFightList())
-- 				else
-- 					Network.sendMsg(PacketID.CG_TREASURE_END_ASSIST,TDefine.DEFEATED,self.regionId,self.districtId,self.mineId)
-- 				end
-- 			end 
-- 		end,self)
-- 		Stage.replaceScene(scene)
-- 		Network.sendMsg(PacketID.CG_TREASURE_STATUS,self.regionId,self.districtId,self.mineId,TDefine.MINE_STATUS.Occupying)
-- 	end
-- end
function doFightFinal(self)
	if self.mode == TDefine.MODE_FIGHT then
		-- Network.sendMsg(PacketID.CG_TREASURE_STATUS,self.mineId,TDefine.MINE_STATUS.Occupying)
		Treasure.sendTreasureStartOccupy(self.mineId)
	else
		if self:canFight() then
			Network.sendMsg(PacketID.CG_TREASURE_GUARD,self.mineId,self:getFightList())
			UIManager.removeUI(self)
		end
	end
end

function refreshListItem(self,hitem,h)
	if self.forbiden then
		for _,name in ipairs(self.forbiden) do 
			if name == h.name then
				
				hitem.touchEnabled = false
				hitem:shader(Shader.SHADER_TYPE_GRAY)
				hitem.keep:setVisible(true)
				-- if hitem.itembg.hero then
				-- 	hitem.itembg.hero:shader(Shader.SHADER_TYPE_GRAY)
				-- end
				-- Shader.setShader(hitem.itembg._icon,)
				-- hitem.itembg._icon:shader(Shader.SHADER_TYPE_GRAY)
			end
		end
	end
end

