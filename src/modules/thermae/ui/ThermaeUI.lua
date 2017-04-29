module(..., package.seeall)
setmetatable(_M, {__index = Control})
local Hero = require("src/modules/hero/Hero")
local ThermaeLogic = require("src/modules/thermae/ThermaeLogic")
local ThermaeDefine = require("src/config/ThermaeDefineConfig").Defined
local Data = require("src/modules/thermae/Data")
local HeroDefineConfig = require("src/config/HeroDefineConfig").Config
local ThermaeSpeak = require("src/config/ThermaeSpeakConfig").Config
local ThermaeConfig = require("src/config/ThermaeConfig").Config

local MIN_X = 40
local MIN_Y = 80
local MAX_X = 810
local MAX_Y = 320

Instance = nil 
function new()
	local ctrl = Control.new(require("res/thermae/ThermaeSkin"),{"res/thermae/Thermae.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl.selectHeroName = nil
	ctrl.bathingHero = {}
	ctrl:init()
	Instance = ctrl
	return ctrl
end

function uiEffect()
	return UIManager.FIRST_TEMP_FULL
end

function clear(self)
	Instance = nil
	Control.clear(self)
end

function init(self)
	self.speak:setVisible(false)
	self.reward:setVisible(false)

	local bg = Sprite.new("ThermaeBg","res/thermae/Thermaebg.jpg")
	--bg.touchEnabled = false
	self:addChild(bg)
	bg:marginMiddle()

	local skin = {name="arena",type="Container",x=0,y=0,children={}}
	self.arena = Control.new(skin)
	self:addChild(self.arena)
	self.arena:setContentSize(cc.size(Stage.designSize.width,Stage.designSize.height))
	self.arena:addEventListener(Event.TouchEvent,onMove,self)

	self.shu1:setTop()
	self.shu2:setTop()
	self.reward:setTop()
	self.xuanze:setTop()
	--self.xuanze:marginCenter()
	self.bathing:setTop()
	self.bath:setTop()
	--self.bath:marginTop(104)
	self.back:setTop()
	--self.back:marginTop(5)

	self.back:addEventListener(Event.TouchEvent,onClose,self)
	self.reward:addEventListener(Event.TouchEvent,onClose,self)
	self.bath:addEventListener(Event.TouchEvent,onShowSelect,self)
	self:update()
	
	self:openTimer()
	self.timer = self:addTimer(onTick,1,-1,self)

	--[[
	local node = Common.getDrawBoxNode(cc.rect(MIN_X,MIN_Y,MAX_X - MIN_X,MAX_Y - MIN_Y),cc.c4b(255,255,0,100))
	self._ccnode:addChild(node)
	--]]

	self:createBathHero()
	self:addEventListener(Event.Frame, onFrame)
end

function addStage(self)
	--self:marginCenter()
	self:setPositionY(Stage.uiBottom)
end

function onTick(self,event)
	if Data.isOpen() then
		--Data.decLeftTime(1)
		self:updateBathing()
	end
end

local nameIndex = 1
function createHero(self,name,isMy)
	nameIndex = nameIndex + 1

	local cfg = ThermaeConfig[name]
	if not cfg then
		return
	end

	local skin = {name="hero" .. nameIndex,type="Container",x=0,y=0,children={}}
	local heroImg = Control.new(skin)
	self.arena:addChild(heroImg)
	local skin = {name="h",type="Container",x=0,y=0,children={}}
	local h = Control.new(skin)
	heroImg:addChild(h)

	--local body = Sprite.new("body","res/thermae/ThermaeBody.png")
	local body = Sprite.new("body","res/thermae/" .. cfg.body)
	h:setContentSize(body:getContentSize())
	h:setAnchorPoint(0.5,0)

	local head = Sprite.new("head","res/hero/icon/" .. name .. ".png")
	--head:setPosition(-9,12)
	head:setPosition(cfg.offsetX,cfg.offsetY)

	if cfg.headFront == 1 then
		h:addChild(body)
		h:addChild(head)
	else
		h:addChild(head)
		h:addChild(body)
	end

	local moveBy = cc.MoveBy:create(math.random(500,1500)/1000,cc.p(0,1))
	local seq = cc.Sequence:create(moveBy,moveBy:reverse())
	local rep = cc.RepeatForever:create(seq)
	head:runAction(rep)


	local speak = Control.new(self.speak:getSkin())
	speak:setAnchorPoint(0.5,0)
	heroImg:addChild(speak)
	speak:setPosition(100,100)
	speak:setVisible(false)

	local size = speak.txtspeak:getContentSize()
	local x,y = speak.txtspeak:getPosition()
	heroImg.speakY = y + size.height
	speak.txtspeak:setDimensions(speak.txtspeak:getContentSize().width)


	heroImg:setPosition(math.random(MIN_X,MAX_X),math.random(MIN_Y,MAX_Y))
	heroImg:openTimer()

	local moveBy = cc.MoveBy:create(math.random(500,1500)/1000,cc.p(0,3))
	local seq = cc.Sequence:create(moveBy,moveBy:reverse())
	local rep = cc.RepeatForever:create(seq)
	heroImg:runAction(rep)

	if not isMy then
		heroImg:addTimer(function() 
			--[[
			if heroImg:numberOfRunningActions() > 0 then
				return
			end
			--]]
			if math.random(0,99) < 10 then
				local ox,oy = heroImg:getPosition()
				local nx,ny = math.random(MIN_X,MAX_X),math.random(MIN_Y,MAX_Y)
				if heroImg.moveAction then
					heroImg:stopAction(heroImg.moveAction)
				end
				local moveAction = cc.MoveTo:create(math.random(100,300) / 100 + math.sqrt((nx-ox) * (nx-ox) + (ny-oy) * (ny-oy)) / 100,cc.p(nx,ny))
				heroImg:runAction(moveAction)
				heroImg.moveAction = moveAction
				if nx > ox then
					--heroImg:setFlipX(true)
					h:setScaleX(-1)
				else
					--heroImg:setFlipX(false)
					h:setScaleX(1)
				end
			end
			---[[
			if not heroImg.speak:isVisible() and math.random(0,99) < 5 then
				local s = ThermaeSpeak[math.random(1,#ThermaeSpeak)].speak
				heroImg.speak.txtspeak:setString(s)
				local size = heroImg.speak.txtspeak:getContentSize()
				heroImg.speak.txtspeak:setPositionY(heroImg.speakY - size.height)
				heroImg.speak:setVisible(true)
				heroImg.speak:runAction(cc.Sequence:create(
					cc.DelayTime:create(5),
					cc.CallFunc:create(function() 
						heroImg.speak:setVisible(false)
					end)
				))
			end
			--]]
		end,math.random(1000,4000)/1000,-1)
	else
		heroImg:shader(Shader.SHADER_TYPE_BLINK)
	end
	return heroImg
end

function createBathHero(self)
	local len = #HeroDefineConfig
	for k = 1,math.random(20,30) do
		local index = math.random(1,len)
		local cfg = HeroDefineConfig[index]
		if cfg.tag == 1 then
			local heroImg = self:createHero(cfg.name)
			table.insert(self.bathingHero,heroImg)
		end
	end
end

function onFrame(self,event)
	local function sortFunc (heroA,heroB)
		if heroA and heroB then
			local ay = heroA:getPositionY()
			local by = heroB:getPositionY()
			if ay ~= by then
				return ay > by
			else
				return heroA.name > heroB.name
			end
			--return heroA:getPositionY() > heroB:getPositionY()
		else
			return true
		end
	end
	table.sort(self.bathingHero,sortFunc)

	for k,v in ipairs(self.bathingHero) do
		v:setTop()
	end
end

function update(self)
	local hero = ThermaeLogic.getBathingHero()
	if hero then
		self.xuanze:setVisible(false)
		self.bathing:setVisible(true)
	else
		self.xuanze:setVisible(true)
		self.bathing:setVisible(false)
	end
	self:initSelect()
	self:initBathing()

end

function onClose(self,event)
	if event.etype == Event.Touch_ended then
		UIManager.removeUI(self)
	end
end

function onShowSelect(self,event)
	if event.etype == Event.Touch_ended then
		self.xuanze:setVisible(true)
	end
end

function initSelect(self)
	self.xuanze.jiangli.txtzuanshi:setString(string.format("%d/%d秒",ThermaeDefine.rmb[2],ThermaeDefine.rmb[1]))
	self.xuanze.jiangli.txtjinbi:setString(string.format("%d/%d秒",ThermaeDefine.money[2],ThermaeDefine.money[1]))


	for k = 1,6 do
		local itemCfg = ThermaeDefine.item[k+1]
		local item = self.xuanze.jiangli["daoju" .. k]
		if itemCfg then
			item:setVisible(true)
			CommonGrid.bind(item,true)
			item:setItemIcon(itemCfg[2])
			item:setItemNum(itemCfg[3])
		else
			item:setVisible(false)
		end
	end

	self.xuanze.xuanzeyingx.heroList:setDirection(List.UI_LIST_HORIZONTAL)
	self.xuanze.xuanzeyingx.left:addEventListener(Event.Click,function() 
		self.xuanze.xuanzeyingx.heroList:turnPage(List.UI_LIST_PAGE_LEFT,3)
	end,self)
	self.xuanze.xuanzeyingx.right:addEventListener(Event.Click,function() 
		self.xuanze.xuanzeyingx.heroList:turnPage(List.UI_LIST_PAGE_RIGHT,3)
	end,self)


	local heroList = Hero.getSortedHeroes()
	local row = #heroList
	self.xuanze.xuanzeyingx.heroList:setItemNum(row)
	for i = 1,row do
		local name = heroList[i].name
		local ctrl = self.xuanze.xuanzeyingx.heroList:getItemByNum(i)
		ctrl.heroName = name
		ctrl:addEventListener(Event.TouchEvent,function(self,event,target) 
			if event.etype == Event.Touch_ended then
				--UIManager.addChildUI("src/modules/hero/ui/HeroFragUI",name)
				self.selectHeroName = target.heroName
				self:updateSelectHero()
			end
		end,self)
		CommonGrid.bind(ctrl.heroBg)
		ctrl.heroBg:setHeroIcon(name)
	end
	self.selectHeroName = heroList[1].name
	self:updateSelectHero()

	self.xuanze.sure:addEventListener(Event.TouchEvent,onBath,self)
end

function updateSelectHero(self)
	for k,v in ipairs(self.xuanze.xuanzeyingx.heroList.itemContainer) do
		v.gou:setVisible(v.heroName == self.selectHeroName)
	end
end

function onBath(self,event)
	if event.etype == Event.Touch_ended then
		if ThermaeLogic.getBathingHero() then
			return
		end
		if not self.selectHeroName then
			return
		end
		--[[
		local hero = Hero.getHero(self.selectHeroName)
		if hero.lv < ThermaeDefine.level then
			Common.showMsg(ThermaeDefine.level .. "级开放")
			return
		end
		--]]
		Network.sendMsg(PacketID.CG_THERMAE_BATH,self.selectHeroName)
	end
end

function onEndBath(self,event)
	if event.etype == Event.Touch_ended then
		if not ThermaeLogic.getBathingHero() then
			return
		end
		local tips = TipsUI.showTips("结束泡澡将不能再获得奖励，是否继续？")
		tips:addEventListener(Event.Confirm,function(self1,event) 
			if event.etype == Event.Confirm_yes then
				Network.sendMsg(PacketID.CG_THERMAE_END_BATH)
			end
		end)
	end
end

function initBathing(self)
	self.bathing.over:addEventListener(Event.TouchEvent,onEndBath,self)
	self:updateBathing()
end

function updateBathing(self,hero)
	hero = hero or ThermaeLogic.getBathingHero()
	if not hero then
		self.bathing:setVisible(false)
		self.bath:setVisible(true)
		if self.myHero then
			for k,v in ipairs(self.bathingHero) do
				if v == self.myHero then
					table.remove(self.bathingHero,k)
					break
				end
			end
			self.arena:removeChild(self.myHero)
			self.myHero = nil
		end
		return 
	end
	self.bath:setVisible(false)
	self.xuanze:setVisible(false)
	self.bathing:setVisible(true)
	if not self.myHero then
		self.myHero = self:createHero(hero.name,true)
		self.myHero:setPosition(400,70)
		table.insert(self.bathingHero,self.myHero)
	end
	local data = Data.getData()
	if self.heroIcon then
		self.bathing:removeChild(self.heroIcon)
	end
	self.heroIcon = HeroGridS.new(self.bathing.herobg2)
	self.heroIcon:setHero(hero)
	self.heroIcon:setScale(0.8)
	
	self.bathing.txtheroname:setString(hero.cname)
	self.bathing.txtbathing:setPositionX(self.bathing.txtheroname:getPositionX() + self.bathing.txtheroname:getContentSize().width + 10)
	self.bathing.produce.txtjinbis:setString(data.money)
	self.bathing.produce.txtzuanshis:setString(data.rmb)
	self.bathing.txttime:setString(string.format("%d分%d秒",math.floor(data.leftTime/60),data.leftTime%60))
end

function showReward(self)
	self.xuanze:setVisible(false)
	self.reward:setVisible(true)
	self.arena:removeAllChildren()
	self.myHero = nil
	self.bathingHero = {}
	local data = Data.getData()
	self.reward.txtjbsz:setString(data.money)
	self.reward.txtzssz:setString(data.rmb)
	for i = 1,4 do 
		local item= self.reward["dj" .. i]
		if data.item[i] then
			item:setVisible(true)
			CommonGrid.bind(item,true)
			item:setItemIcon(data.item[i].itemId)
			item:setItemNum(data.item[i].cnt)

		else
			item:setVisible(false)
		end
	end
	if not Data.hasReward() then
		self.xuanze:setVisible(false)
		self.reward:setVisible(false)
		local tips = TipsUI.showTips("温泉活动已经结束啦~！")
		tips:addEventListener(Event.Confirm,function(self1,event) 
			if event.etype == Event.Confirm_yes then
				UIManager.removeUI(self)
			end
		end)
	end
end

function onMove(self,event)
	if event.etype == Event.Touch_ended then
		local touchLocation = self._ccnode:convertToNodeSpace(event.p) 
		if not self.myHero then
			return
		end
		local x = math.max(MIN_X,touchLocation.x)
		x = math.min(MAX_X,x)
		local y = math.max(MIN_Y,touchLocation.y)
		y = math.min(MAX_Y,y)
		
		local ox,oy = self.myHero:getPosition()
		if self.myHero.moveAction then
			self.myHero:stopAction(self.myHero.moveAction)
		end
		local moveAction = cc.MoveTo:create(math.random(100,300) / 100 + math.sqrt((x-ox) * (x-ox) + (y-oy) * (y-oy)) / 100,cc.p(x,y))
		self.myHero:runAction(moveAction)
		self.myHero.moveAction = moveAction
		if x > ox then
			--heroImg:setFlipX(true)
			self.myHero.h:setScaleX(-1)
		else
			--heroImg:setFlipX(false)
			self.myHero.h:setScaleX(1)
		end
	end
end
