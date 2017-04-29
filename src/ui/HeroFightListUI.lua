module(..., package.seeall)
setmetatable(_M, {__index = Control})

local Hero = require("src/modules/hero/Hero")
local Common = require("src/core/utils/Common")
local FightControl = require("src/modules/fight/FightControl")
local HeroDefine = require("src/modules/hero/HeroDefine")
local OpenLv = require("src/config/FightOpenLvConfig").Config[1].openlv
local HeroGridL = require("src/ui/HeroGridL")
local HeroGridS = require("src/ui/HeroGridS")
local BoneRes= require("src/modules/hero/StandByBoneRes").BoneRes

Instance = nil

function new(enemyFightList,isAssistOpened)
	local ctrl = Control.new(require("res/common/HeroFightListSkin"),{"res/common/HeroFightList.plist","res/common/an.plist"})
	ctrl.qhqz:setVisible(false)
	ctrl.name = "Fight"
	ctrl.fightHeroes = {}
	ctrl.monsters = {}
	ctrl.enemyFightList = enemyFightList
	ctrl.heroGridList = {}
	if isAssistOpened == nil then
		ctrl.isAssistOpened = true
	else
		ctrl.isAssistOpened = isAssistOpened
	end
	setmetatable(ctrl,{__index = _M})
	Instance = ctrl
	return ctrl
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
end

function uiEffect()
	return UIManager.FIRST_TEMP
end

function onClose(self,event,target)
	if event.etype == Event.Touch_ended then
		self:closeUI()
	end
end

function closeUI(self)
	self:doClose()
	UIManager.removeUI(self)
end

function clear(self)
	self.loader:removeAllArmatureFileInfo()
	Control.clear(self)
	Instance = nil
end

function doClose(self)
	
end

function getHeroFightListCnt(self)
	local cnt = 0
	for i=1,4 do
		if self.heroFightList[i] and self.heroFightList[i] ~= '' then
			cnt = cnt + 1
		end
	end
	return cnt
end

function canFight(self)
	local ret = false
	if self:getHeroFightListCnt() == 0 then
		TipsUI.showTipsOnlyConfirm("请先上阵英雄，然后开始战斗")
		return false
	elseif self:getHeroFightListCnt() == 1 and self.heroFightList[4] ~= nil and self.heroFightList[4] ~= '' then
		TipsUI.showTipsOnlyConfirm("请先上阵非援助英雄，然后开始战斗")
		return false
	elseif (self.heroFightList[4] == nil or self.heroFightList[4] == '') and self.isAssistOpened and self.isGuide == nil then
		TipsUI.showTipsOnlyConfirm("请上阵援助英雄，然后开始战斗")
		return false
	else
		return true
	end
	return ret
end

function setFightEnabled(self,enabled)
	self.fight:setEnabled(enabled)
end

local clickTime = 0
function onFight(self,event,target)
	if (os.time() - clickTime) < 1 then
		return
	else
		clickTime = os.time()
	end
	if self:canFight() then
		self:setFightEnabled(false)
		self:doFight()
	end
end

function doFight(self)
	local openNum = self:getOpenNum()
	if Common.GetTbNum(self.heroFightList) < openNum and self.isGuide == nil then
		local tip = TipsUI.showTips(string.format("你的出战阵容不足%d人，是否继续？",openNum))
		tip:addEventListener(Event.Confirm,function(self,event) 
			self:setFightEnabled(true)
			if event.etype == Event.Confirm_yes then
				self:doTeamFight()
			end
		end,self)
	else
		self:doTeamFight()
	end
end

function doTeamFight(self)
	self:sendFightMsg()
	self:setFightHeros()
	self:setMonsters()
	self:toFightScene()
	self:doFightFinal()
end

function doFightFinal(self)
end


function sendFightMsg(self)
	
end

function setFightHeros(self)
	local fightHeroes = {}
	for _,hname in pairs(self.heroFightList) do
		local h = self:getHeroList()[hname]
		if h then
			table.insert(fightHeroes,h)
		end
	end
	self.fightHeroes = fightHeroes
end

function prepareHeroes(self)
	self.AHeroes = {}
	self.BHeroes = {}
	for i=1,4 do 
		if self.heroFightList[i] then
			table.insert(self.AHeroes,Hero.getHero(self.heroFightList[i]))
		end
		if self.enemyFightList[i] then
			table.insert(self.BHeroes,self.enemyFightList[i])
		end
	end
end

function setMonsters(self)
end

function toFightScene(self,fightType,args)
	self:prepareHeroes()
	--此行不准删，不然#%!#你老婆
	--local fightControl = FightControl.new({Hero.getHero("Shermie2"),Hero.getHero("Leona2")},{Hero.getHero("Shermie2"),Hero.getHero("Leona2")})
	if Stage.currentScene.name == "fight" then
		return Stage.currentScene
	end
	local fightControl = FightControl.new(self.AHeroes,self.BHeroes)
	local scene = require("src/scene/FightScene").new(fightControl,nil,fightType,args)
	scene:addEventListener(Event.InitEnd,self.onFightInit,self)
	scene:addEventListener(Event.FightEnd,self.onFightEnd,self)
	scene:addEventListener(Event.FightDie,self.onFightDie,self)
	Stage.replaceScene(scene)
	return scene
end

function returnToMainScene(self)
	local scene = require("src/scene/MainScene").new()
	Stage.replaceScene(scene)
	return scene
end

function onFightInit(self,event)
end

function onFightEnd(self,event)
end

function onFightDie(self,event)
end

function refreshHeroList(self)
	for i,item in ipairs(self.herolist.itemContainer) do
		if self:isInFightList(item.heroName) then
			item.checked:setVisible(true)
			item.zhedang:setVisible(true)
		else
			item.checked:setVisible(false)
			item.zhedang:setVisible(false)
		end
	end
end
function showHeroes(self)
	self.herolist:removeAllItem()
	local hlist = self:getHeroList()

	for i,hero in ipairs(hlist) do 
		local no = self.herolist:addItem()
		local item = self.herolist.itemContainer[no]
		local name = hero.name
		self.heroGridList[name] = item
		item.heroName = name

		item.touchParent = false
		item.dead:setVisible(false)
		--item.hp:setVisible(false)
		--item.hpback:setVisible(false)
		Common.setLabelCenter(item.lv)
		item.lv:setString(hero.lv)
		--setCareerIcon(item,hero.career)

		if self:isInFightList(name) then
			item.checked:setVisible(true)
			item.zhedang:setVisible(true)
		else
			item.checked:setVisible(false)
			item.zhedang:setVisible(false)
		end
		--CommonGrid.bind(item.itembg)
		--item.itembg:setHeroIcon2(name,'f',hero.quality)
		local grid = HeroGridS.new()
		grid:setPositionX(-2)
		grid:setPositionY(item.itembg:getPositionY())
		item:addChild(grid)
		grid:setHero(hero)
		item.checked:setTop()
		item.keep:setTop()
		item.keep:setVisible(false)
		item.zhedang:setTop()

		function onClickHero(self,event,target)
			if event.etype == Event.Touch_ended then
				self:clickHero(event,target,hero,item)
				
				if hero.name == "Shingo" then
					GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_CHAPTER_FIRST, step = 6})
					GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_CHAPTER_FIGHT_SEC, step = 4})
					GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_CHAPTER_FIGHT_THIRD, step = 4})
					GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_HERO_ACTIVE, step = 9})
				end
				if hero.name == "Athena" then
					GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_CHAPTER_FIRST, step = 7})
					GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_CHAPTER_FIGHT_SEC, step = 5})
					GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_CHAPTER_FIGHT_THIRD, step = 5})
					GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_HERO_ACTIVE, step = 11})
				end
				if hero.name == "Chang" then
					GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_HERO_ACTIVE, step = 10})
				end
				if hero.name == "Mai" then
					GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_HERO_ACTIVE, step = 12})
				end
			end
		end
		item:addEventListener(Event.TouchEvent,onClickHero,self)

		self:refreshListItem(item, hero)
	end
	self.herolist:getChild('herolistbg'):setVisible(false)
end
function init(self,goName)
	self:addArmatureFrame("res/common/effect/FightHero.ExportJson")
	local bg = cc.Scale9Sprite:create("res/common/HeroFightListBg.png")
	bg.touchEnabled = false
	local width = Stage.winSize.width
	bg:setAnchorPoint(0,0)
	bg:setContentSize(cc.size(width,640))
	bg:setPositionY(-80)
	self.bg = bg
	self._ccnode:addChild(bg,-1)

	if goName and goName == "save" then
		self.save:setVisible(true)
		self.fight:setVisible(false)
	else
		self.save:setVisible(false)
		self.fight:setVisible(true)
	end

	initAsyncLoader(self)
	self.heroFightList = {}
	self.heroAssist = ''
	self.back:addEventListener(Event.TouchEvent,self.onClose,self)
	self.back.touchParent = false
	self.touchNo = 1
	self.herolist:setDirection(List.UI_LIST_HORIZONTAL)
	self.herolist.UI_LIST_BTW_SPACE = 0
	self.herolist.UI_LIST_MOVE_DISTANCE = 5
	for i=1,4 do 
		self.szyx["kapai"..i]:setVisible(false)
		self.fighter["hero"..i].xhr:setVisible(false)
	end
	
	--CommonGrid.bind(self.heroTemp.itembg)
	--local grid = HeroGridL.new()
	--self.heroTemp:addChild(grid)
	--self.heroTemp:setVisible(false)
	
	--Common.setLabelCenter(self.power.txtpower)
	--self.power.txtpower:setString('0')
	self.power.txtpower:setString("")

	local label = cc.Label:createWithBMFont("res/common/zdl.fnt", "0")
	self.power._ccnode:addChild(label)
	label:setAnchorPoint(0,0.5)
	label:setPositionX(self.power.txtpower:getPositionX())
	label:setPositionY(self.power.txtpower:getPositionY()+5)
	self.power.artPower = label
	self.power.artPower:setString('0')

	self:showFightList()
	self:showHeroes()
	self.fight:addEventListener(Event.Click,self.onFight,self)
	self.fight.touchParent = false
	self.save:addEventListener(Event.Click,self.onFight,self)

	-- 展示对手头像
	self:setEnemyFightList(self.enemyFightList)
	function onLeft(self)
		self.herolist:turnPage(List.UI_LIST_PAGE_LEFT,3)
	end
	self.left:addEventListener(Event.Click,onLeft,self)
	function onRight(self)
		self.herolist:turnPage(List.UI_LIST_PAGE_RIGHT,3)
	end
	self.right:addEventListener(Event.Click,onRight,self)
	
	self.rec:setVisible(false)
	self.rec:addEventListener(Event.Click,self.onClickRecHero,self)

	self.txmc1:setVisible(false)
	self.txmc2:setVisible(false)
	self.timeDesTxt:setVisible(false)
	self.timeTxt:setVisible(false)
	self.checked:setVisible(false)
	--jumpAction(self.vs)
end

function setEnemyFightList(self, enemyList)
	self.enemyFightList = enemyList
	for i=1,4 do 
		if self.enemyFightList[i] then
			self:playArm(i+10)
			setCareerIcon(self.enemy['hero'..i],self.enemyFightList[i].career)
			setLvIcon(self.enemy['hero'..i],self.enemyFightList[i].lv)
		else
			setCareerIcon(self.enemy['hero'..i])
			setLvIcon(self.enemy['hero'..i])
			Shader.setShader(self.enemy['hero'..i].itembg._ccnode,"Gray")
			Shader.setShader(self.enemy['hero'..i]['no'..i]._ccnode,"Gray")
		end
		self.enemy["hero"..i].xhr2:setVisible(false)
	end
end

function onClickRecHero(self)
	return UIManager.addChildUI("src/ui/HeroRec2UI")
end

function isInFightList(self,heroName)
	for _,n in pairs(self.heroFightList) do
		if heroName == n then return true end
	end
	return false
end

function swapFightList(self,a,b)
	self.heroFightList[a],self.heroFightList[b] = self.heroFightList[b],self.heroFightList[a]
end

function getAllFight(self)
	local power = 0
	--不算援助
	for i=1,3 do
		local n = self.heroFightList[i]
		if n then
			local h = Hero.heroes[n]
			if h then
				power = power + h:getFight()
			end
		end
	end
	return power
end

function resetHeroFightList(self,list,limit)
	--if not next(list) then
	--	self:setDefaultHeroList(list)
	--end
	self.heroFightList = list
	self.limitGrids = limit or {}
	self:showFightList()
	self:refreshHeroList()
end

function setDefaultHeroList(self, list)
	local sortlist = Hero.getSortedHeroes()
	for i = 1,#sortlist do
		local hero = sortlist[i]
		table.insert(list,hero.name)
		if i >= 4 then
			break
		end
	end
end

function getFightHeroCnt(self)
	local cnt = 0
	for i=1,4 do
		if self.heroFightList[i] and self.heroFightList[i] ~= '' then
			cnt = cnt + 1
		end
	end
	return cnt
end

function clickHero(self, event, target, hero, hitem)
	if self:isInFightList(hero.name) then
		local no = 1
		for index=1,4 do
			local name = self.heroFightList[index]
			if name == hero.name then
				self.heroFightList[index] = nil
				no = index
				break
			end
		end
		self:showFightList(no)
		hitem.checked:setVisible(false)
		hitem.zhedang:setVisible(false)
		return
	end
	if  self:getFightHeroCnt(self.heroFightList) >= 4 then
		return
	end

	if self.loadno > 0 and (self.heroFightList[self.loadno] == nil or self.heroFightList[self.loadno] == '') then
		local no = self.loadno
		self.heroFightList[self.loadno] = hero.name
		hitem.checked:setVisible(false)
		hitem.zhedang:setVisible(false)

		UIManager.playMusic("lvUpAttr")
		self:showFightList(no)
		self:refreshHeroList()
	end
end

function refreshListItem(self, hitem, h)
	
end

function deleteFightHero(self,name)
	for i=1,4 do 
		if self.heroFightList[i] == name then
			self.heroFightList[i] = nil
			break
		end
	end
end

function onSwap(self,event,target)
	local ret = false
	if event.etype == Event.Touch_began then
		local c = target:getTouchedChild(event.p)
		if c and c.heroName then
			self.touchBeginHero = c.heroName
			self.touchBeginIcon = c.itembg
			self.touchLastX = event.p.x
			self.touchFirstX = event.p.x
			self.touchOriginX = self.touchBeginIcon:getPositionX()

			self.touchNo = c.no
			c:setTop()
		end
	elseif event.etype == Event.Touch_moved then
		if self.touchBeginHero  then
			self.touchBeginIcon:setPositionX(self.touchBeginIcon:getPositionX()+(event.p.x-self.touchLastX)/Stage.uiScale)
			self.touchLastX = event.p.x
		end
	elseif event.etype == Event.Touch_ended then
		local c = target:getTouchedChild(event.p)
		if self.touchBeginHero then
			self.touchBeginIcon:setPositionX(0)
		end
		if c and self.touchBeginHero then
			if c.heroName and c.heroName ~= self.touchBeginHero  then

				self:swapFightList(self.touchNo,c.no)
				self.touchBeginHero = nil
				self.touchBeginIcon = nil
				self.touchLastX = 0
				self.touchOriginX = 0
				self.touchFirstX = 0
				self:showFightList(c.no,self.touchNo)
			elseif c.heroName and c.heroName == self.touchBeginHero then
				if math.abs(event.p.x - self.touchFirstX) < 5 then
					-- 看成是点击，取消这个英雄
					self:deleteFightHero(self.touchBeginHero)
					self.touchBeginHero = nil
					self.touchBeginIcon = nil
					self.touchLastX = 0
					self.touchOriginX = 0
					self.touchFirstX = 0
					self:showFightList(c.no)
					self:refreshHeroList()
				else
					-- 看成是移动失败，不会取消英雄，只能退回
					self.touchBeginHero = nil
					self.touchBeginIcon = nil
					self.touchLastX = 0
					self.touchOriginX = 0
					self.touchFirstX = 0
					self:showFightList(c.no)
				end
			elseif self.touchNo then
				-- 这里是英雄移动到了空格子这里
				if checkOpenLv(c.no) and self:checkLimitGrid(c.no) then
					self:swapFightList(self.touchNo,c.no)
					ret = true
				--else
				--	local lv = OpenLv[c.no]
				--	if lv then
				--		Common.showMsg(string.format("战队等级未达到%d级，请先升级",lv))
				--	end
				end
				self.touchBeginHero = nil
				self.touchBeginIcon = nil
				self.touchLastX = 0
				self.touchFirstX = 0
				self.touchOriginX = 0
				self:showFightList(c.no,self.touchNo)
			end
		end
	elseif event.etype == Event.Touch_out then
		if self.touchBeginHero then
			self.touchBeginIcon:setPositionX(0)
		end
		self.touchBeginHero = nil
		self.touchBeginIcon = nil
		self.touchLastX = 0
		self.touchOriginX = 0
		self.touchFirstX = 0
		self:showFightList(self.touchNo)
	end
	return ret
end

function removeHeroSprite(self,index,name)
	local child = self.szyx:getChild("heroicon"..index)
	if child then
		local callBackFuc = function()
			self.szyx:removeChildByName("heroicon"..index)
		end
		local callBack=cc.CallFunc:create(callBackFuc)
		local moveBy = cc.MoveBy:create(0.35,cc.p(Stage.winSize.width,0))
		local sineOut = cc.EaseSineOut:create(moveBy)
		child:runAction(cc.Sequence:create({sineOut, callBack}))
	else
		self.szyx:removeChildByName("heroicon"..index)
	end
end

function addHeroSprite(self,index,name,isAction)
	--local item = self.szyx["kapai"..index]
	----local action = true
	----if self.szyx:getChild("heroicon"..index) then
	----	action = false
	----end
	--self.szyx:removeChildByName("heroicon"..index)
	--local spr = Sprite.new('heroicon'..index,'res/hero/nicon/'..name..".jpg")
	--if spr then
	--	spr:setOpacity(128)
	--	spr:setPositionX(item:getPositionX())
	--	spr._ccnode:setLocalZOrder(-1)
	--	spr:setPositionY(item:getPositionY()+Stage.uiBottom)
	--	self.szyx:addChild(spr)
	--	if isAction then
	--		spr:setPositionX(item:getPositionX()-Stage.winSize.width)
	--		local moveBy = cc.MoveBy:create(0.35,cc.p(Stage.winSize.width,0))
	--		local sineOut = cc.EaseSineOut:create(moveBy)
	--		spr:runAction(sineOut)
	--	end
	--end
end

function showFightList(self,index1,index2)
	local con = self.fighter
	local loadhere = true
	self.loadno = 0
	if self.fighter:hasEventListener(Event.TouchEvent, onSwap) == false then
		self.fighter:addEventListener(Event.TouchEvent, onSwap, self)
	end
	local hasHero = false
	for i=1,4 do
		CommonGrid.bind(con['hero'..i].itembg)
		local name = self.heroFightList[i]
		con["hero" .. i].no = i
		--con['hero'..i].hp:setScaleX(1)
		con['hero'..i].lock:setVisible(false)
		if name ~= nil and name ~= '' then
			local hero = Hero.getHero(name)
			if index1 == nil or i == index1 or i == index2 then
				self:playArm(i)
				local isAction = index1 and true or false
				self:addHeroSprite(i,name,isAction)
			end
			setCareerIcon(con['hero'..i],hero.career)
			setLvIcon(con['hero'..i],hero.lv)
			con['hero'..i].heroName = name
			con['hero'..i].loadhere:setVisible(false)
			--con['hero'..i].empty:setVisible(false)

			hasHero = true
			--if hero.fightAttr.hp then
			--	con['hero'..i].hp:setScaleX(hero.fightAttr.hp / hero.dyAttr.maxHp)
			--end
		else
			-- con:removeChildByName('head'..i)
			--con['hero'..i].itembg:setHeroIcon2()
			if index1 == nil or i == index1 or i == index2 then
				self:stopArm(i)
				self:removeHeroSprite(i,name)
			end
			--con['hero'..i].heroGrid:setHero()
			setCareerIcon(con['hero'..i])
			setLvIcon(con['hero'..i])
			con['hero'..i].heroName = nil
			local flagOpenLv = checkOpenLv(i)
			local flagLimit = self:checkLimitGrid(i)
			if flagOpenLv and flagLimit then
				if loadhere == true then 
					local len = self.herolist.itemNum
					if len == 2 and (i == 2 or i == 3) then
						con['hero'..i].loadhere:setVisible(false)
					elseif len == 3 and (i == 3) then
						con['hero'..i].loadhere:setVisible(false)
					else
						con['hero'..i].loadhere:setVisible(true)
						self.loadno = i
						loadhere = false
					end
				else
					con['hero'..i].loadhere:setVisible(false)
				end
				con['hero'..i].txtlv:setString("")
			elseif not flagOpenLv then
				con['hero'..i].txtlv:setAnchorPoint(0.5,0)
				local lv = OpenLv[i]
				if lv then
					con['hero'..i].txtlv:setString(string.format("战队达到\n%d级开放",lv))
				end
				con['hero'..i].loadhere:setVisible(false)
			elseif not flagLimit then
				con['hero'..i].txtlv:setString("")
				con['hero'..i].loadhere:setVisible(false)
				Shader.setShader(con['hero'..i].itembg._ccnode,"Gray")
				Shader.setShader(con['hero'..i]['no'..i]._ccnode,"Gray")
			else
			end
		end   
	end
	for i = 4,1,-1 do
		con["hero" .. i]:setTop()
	end
	--self.qhqz:setVisible(not hasHero)
	--self.power.txtpower:setString(tostring(self:getAllFight()))
	self.power.artPower:setString(tostring(self:getAllFight()))
end

function getOpenNum(self)
	local num = 0 
	for i = 1,4 do
		if checkOpenLv(i) and checkLimitGrid(self,i) then
			num = num + 1
		end
	end
	return num
end

function checkOpenLv(id)
	local lv = Master.getInstance().lv
	local openLv = OpenLv[id]
	if openLv and lv < openLv then
		return false
	end
	return true
end

function checkLimitGrid(self,id)
	if not self.limitGrids then
		return true
	end
	for i = 1,#self.limitGrids do
		if id == self.limitGrids[i] then
			return false
		end
	end
	return  true
end

function getHeroList(self)
	local hlist = {}
	for _,h in pairs(Hero.heroes) do
		hlist[#hlist+1] = h
	end
	table.sort(hlist,Hero.sortRecruitedHero)
	return hlist
end

function setLvIcon(item,lv)
	if lv and lv > 0 then
		item.lvv:setString("lv."..lv)
	else
		item.lvv:setString("")
	end
end

function setCareerIcon(item,id)
	for i=1,5 do
		if i == id then
			item["careersicon"..i]:setVisible(true)
		else
			item["careersicon"..i]:setVisible(false)
		end
	end
end

function cb(self,event) 
		if event.etype == AsyncLoader.Event.Finish then
			if self.alive then
				local index = self.loaderIndex
				local loaderHero = self.loaderHero
				local ctrl
				local name
				if index < 10 then
					ctrl = self.fighter['hero'..index]
					name = self.heroFightList[index]
				else
					ctrl = self.enemy['hero'..(index-10)]
					name = self.enemyFightList[index-10].name
				end
				if ctrl.animation then
					ctrl.itembg._ccnode:removeChild(ctrl.animation)
				end
				if name ~= nil and name ~= '' and name == loaderHero then
					--self:addArmatureFrame(string.format("res/armature/%s/small/%s.ExportJson",string.lower(name),name))
					self:addSpriteFrames(string.format("res/armature/%s/%sSkin.plist",string.lower(name),name))
					if index < 10 then
						self.fighter['hero'..index].xhr:setVisible(false)
					else
						self.enemy['hero'..(index-10)].xhr2:setVisible(false)
					end
					ctrl.animation = ccs.Armature:create(name)
					local armScale = 0.7
					ctrl.animation:setScale(armScale)
					ctrl.itembg._ccnode:addChild(ctrl.animation)
					--jumpAction(ctrl.animation)
					local bgposx,bgposy = ctrl.itembg:getPosition()
					local armposx= bgposx + ctrl.itembg:getContentSize().width/2
					local armposy= bgposy + 30
					ctrl.animation:setPosition(cc.p(armposx,armposy))
					ctrl.animation:getAnimation():playWithNames({'待机'},0,false)

					--敌人使用2p换肤
					if index >= 10 then
						local boneRes = BoneRes[name] or {}
						for name,res in pairs(boneRes) do
							local bone = ctrl.animation:getBone(name)
							for k1,v1 in pairs(res) do
								local skin = ccs.Skin:createWithSpriteFrameName(v1)
								if skin then
									bone:addDisplay(skin,k1 - 1)
								end
							end
						end
					end

					local scaleX = self.loaderIndex > 10 and armScale or -armScale
					ctrl.animation:setScaleX(scaleX)
					ctrl.itembg.touchEnabled = true
					ctrl.itembg.touchParent = true
					ctrl.animation:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID) 
						if movementType == ccs.MovementEventType.complete then
							ctrl.animation:getAnimation():playWithNames({'待机'},0,true)
						end
					end)
				end
				self.loaderIndex = nil
				self.loaderHero = nil
			else
				self.loader:removeAllArmatureFileInfo()
			end
		end
end

function initAsyncLoader(self)
	self.queue = {}
	self:openTimer()
	self:addEventListener(Event.Frame,checkLoader,self)
	self.loader = AsyncLoader.new()
	self.curArm = nil
	self.loader:addEventListener(self.loader.Event.Load,cb,self)
end

function checkLoader(self)
	if self.loaderIndex == nil then
		local k,v = next(self.queue)
		if k and v then
			local index = k
			local ctrl
			local name
			if index < 10 then
				ctrl = self.fighter['hero'..index]
				name = self.heroFightList[index]
			else
				ctrl = self.enemy['hero'..(index-10)]
				name = self.enemyFightList[index-10].name
			end
			if name then
				if index < 10 then
					self.fighter['hero'..index].xhr:setVisible(true)
					if not self.fighter['hero'..index].bone then
						self.fighter['hero'..index].bone = Common.setBtnAnimation(self.fighter['hero'..index]._ccnode,"FightHero","Animation",{x=-5,y=0})
					else
						self.fighter['hero'..index].bone:getAnimation():play("Animation",-1,-1)
					end
				else
					self.enemy['hero'..(index-10)].xhr2:setVisible(true)
				end
				self.loader:addArmatureFileInfo(string.format("res/armature/%s/small/%s.ExportJson",string.lower(name),name))
				self.loaderIndex = k
				self.loaderHero = name
				self.loader:start()
			end
			self.queue[k] = nil
		end
	end
end

function playArm(self,index)
	self.queue[index] = index
end

function stopArm(self,index)
	local ctrl = self.fighter['hero'..index]
	local name = ctrl.heroName
	if index == self.loaderIndex then
		return 
	end
	if name then
		self.loader:removeArmatureFileInfo(string.format("res/armature/%s/small/%s.ExportJson",string.lower(name),name))
	end
	if ctrl.animation then
		ctrl.itembg._ccnode:removeChild(ctrl.animation)
	end
end

function jumpAction(ctrl)
	--local moveBy = cc.MoveBy:create(1,cc.p(50,-50))
	--local sineOut = cc.EaseSineOut:create(moveBy)
	--local scaleTo = cc.ScaleTo:create(0.5,1,0.7)
	--local scaleTo2 = cc.ScaleTo:create(0.5,1,1)
	--local seq = cc.Sequence:create(scaleTo,scaleTo2)
	--local spawn = cc.Spawn:create(sineOut,seq)
	--ctrl:runAction(spawn)
	local jumpBy = cc.JumpBy:create(0.25,cc.p(0,-50),100,1)
	local sineOut = cc.EaseSineOut:create(jumpBy)
	local scaleTo = cc.ScaleTo:create(0.25,1,0.7)
	local scaleTo2 = cc.ScaleTo:create(0.25,1,1)
	local seq = cc.Sequence:create(scaleTo,scaleTo2)
	local spawn = cc.Spawn:create(sineOut,seq)
	ctrl:runAction(spawn)
end
