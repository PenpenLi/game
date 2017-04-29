module(..., package.seeall)
setmetatable(_M, {__index = Control})
local Chapter = require("src/modules/chapter/Chapter")
local ChapterDefine = require("src/modules/chapter/ChapterDefine")
local ItemConfig = require("src/config/ItemConfig").Config
local Hero = require("src/modules/hero/Hero")
local BaseMath = require("src/modules/public/BaseMath")
local Common = require("src/core/utils/Common")

Instance = nil
function new()
	local ctrl = Control.new(require("res/common/SettlementWinSkin"), {"res/common/SettlementWin.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	Instance = ctrl
	return ctrl
end

function addStage(self)
	--back
	--local back = LayerColor.new("backgroud",29,10,10,255,Stage.width,Stage.height)
	local back = LayerColor.new("backgroud",0,0,0,200,Stage.width,Stage.height)
	back.touchEnabled = false
	self:addChild(back,-99)
	--self.back = back
	--self.back:setPositionX(-self:getPositionX())
	--local bg = Sprite.new('winScene','res/common/winscene.jpg')
	--bg.touchEnabled = false
	--self:addChild(bg,-99)
	back:setPositionY(-Stage.uiBottom)
	self:setPositionY(Stage.uiBottom)
end

function init(self)
	self:openTimer()
	self.money = Master.getInstance().money
	--星星
	self:addArmatureFrame("res/common/effect/Star.ExportJson")
	self:addArmatureFrame("res/common/effect/lvUpDesc/LvUp.ExportJson")
	--胜利
	self:addArmatureFrame("res/common/effect/Win.ExportJson")
	--大蛇宝箱
	self:addArmatureFrame("res/chapter/effect/boxblink.ExportJson")
	--win effect
	local winAnimation = ccs.Armature:create('Win')
	winAnimation:getAnimation():play("Animation1",-1,-1)
	winAnimation:setAnchorPoint(0,0)
	winAnimation:setPosition(178,75)
	self.winbg._ccnode:addChild(winAnimation)
	self.heroGridMap = {}

	local ui = Stage.currentScene:getUI()
	for _,v in pairs(ui._children) do
		if v ~= self then
			v:setVisible(false)
		end
	end
	self.orochi:setVisible(false)
	self.main.star:setVisible(false)
	self.main.chiefBtn:setVisible(false)
	self.main.chapterBtn:setVisible(false)
	self.main.nextBtn:setVisible(false)
	self:addEventListener(Event.TouchEvent,self.onStopNumRun,self)
end

--关卡
function initChapter(self)
	self:addConfirmBtn()
	-- block.next:addEventListener(Event.Click,self.onNext,self)
	-- block.next.touchParent = false
end

function addConfirmBtn(self)
	local block = self.main.chapterBtn
	block:setVisible(true)
	block.back:addEventListener(Event.Click,self.onClose,self)
	block.back.touchParent = false
end

function addNextBtn(self)
	self.main.nextBtn:setVisible(true)
	self.main.nextBtn:addEventListener(Event.Click,self.onNext,self)
end

function onNext(self)
end

--[[
--大蛇霸主
function initOrochi(self)
	self.heroBody:setVisible(false)
	self.orochi:setVisible(true)
	--self.winbg:setPositionX(self.main:getPositionX() + 130)
	--self.main:setPositionX(self.main:getPositionX() + self.orochi:getContentSize().width)
	self:addConfirmBtn()
	self.main.chiefBtn:setVisible(true)
	self.main.chiefBtn.view.touchParent = false
	self.main.chiefBtn.view:addEventListener(Event.Click,self.onView,self)
end

function setOrochiChief(self,isChief,time)
	local block = self.orochi
	block.timeLabel:setString(Common.getDCTime(time))
	if not isChief then
		block.chief:setVisible(false)
	else
		local boxEffect = ccs.Armature:create('boxblink')
		block.chief._ccnode:addChild(boxEffect)
		boxEffect:setPosition(10,-60)
		boxEffect:setAnchorPoint(0,0)
		boxEffect:getAnimation():playWithNames({'Animation1'},0,true)
		block.chief.huangguan:setTop()
	end
end
--]]

--星星
function setStarNum(self,num)
	self.winbg:setVisible(false)
	self.main.star:setVisible(true)
	--背后闪耀
	local target = self.main.star["xing2"]
	local blink = Common.setBtnAnimation(target._ccnode,"LvUp","lvup",{y=-5})
	blink:setScale(1.3)
	blink:setVisible(false)
	--star
	self.main.star.xing1:setTop()
	local addStar = function(starPos,timeGap)
		local target = self.main.star["xing" .. starPos]
		local sequence = cc.Sequence:create(cc.DelayTime:create(timeGap), cc.CallFunc:create(function()
				local winAnimation = ccs.Armature:create('Star')
				winAnimation:getAnimation():play("Animation1",-1,0)
				winAnimation:setAnchorPoint(0,0)
				--local wx,wy = self.winbg:getPosition()
				local posX,posY = self.main.star["xing" .. starPos].starbg:getPosition()
				if starPos == 3 and num >= 3 then 
					blink:setVisible(true)
				end
				winAnimation:setPosition(posX+35,posY+35)
				target._ccnode:addChild(winAnimation)
			end
		))
		target:runAction(sequence)
	end 
	local timeGap = 0.1
	for i=1,num do
		addStar(i,timeGap)
		timeGap = timeGap + 0.2
	end
end

function setTitle(self,title)
	--title
	self.main.title:setString(title)
end

function setMaster(self,lv,percent,rewardExp,rewardMoney,addMoney)
	local block = self.main.master
	--block.txtlv:setString('等级：'.. lv)
	--block.exp:setPercent(percent)
	addMoney = addMoney or 0
	rewardMoney = rewardMoney or 0
	self.rewardExpBlock = rewardExp
	self.rewardMoney = rewardMoney + addMoney
	--self.addMoney = addMoney
	if rewardExp and rewardExp > 0 then
		Common.addNumAction(block.txtexp, rewardExp, "+")
	else
		block.expicon2:setVisible(false)
		block.txtexp:setString("")
	end

	if rewardMoney and rewardMoney > 0 then
		local suffix = ""
		if addMoney then
			--suffix = "+" .. addMoney
		end
		Common.addNumAction(block.txtmoney, rewardMoney,"+",suffix)
	else
		block.jbbicon:setVisible(false)
		block.txtmoney:setString("")
	end  
end

function setReward(self,reward)
	local block = self.main.reward
	local index = 0
	for itemId,num in pairs(reward) do 
		local itemId = tonumber(itemId)
		if itemId then
			index = index + 1
			local grid = block['grid'..index]
			if grid then
				CommonGrid.bind(grid,"tips")
				grid:setItemIcon(itemId)
				grid:setItemNum(num)
			end
		end
	end
	for i=index+1,5 do
		local grid = block['grid'..i]
		grid:setVisible(false)
	end
end

function onHeroLvUp(self,heroName)
	--升级特效
	self:addArmatureFrame("res/common/effect/lvUpTxt/lvUpTxt.ExportJson")
	local heroGrid = self.heroGridMap[heroName]
	local lvupEffect = ccs.Armature:create('lvUpTxt')
	local size = heroGrid:getContentSize()
	local posX,posY = heroGrid:getPosition()
	lvupEffect:setScale(0.7)
	lvupEffect:setPosition(posX + size.width/2,posY + size.height)
	--heroGrid._ccnode:addChild(lvupEffect,99)
	heroGrid._parent._ccnode:addChild(lvupEffect,99)
	self:addTimer(function() 
		lvupEffect:getAnimation():play("头像升级啦",-1,0)
	end,1,1)
	self:setHeroes(self.expedition,self.rewardExp)
end

function setHeroes(self,expedition,rewardExp)
	self.expedition = expedition
	self.rewardExp = rewardExp
	local block = self.main.heroes
	local index = 1
	for i=1,4 do
	--for i,name in ipairs(expedition) do
		local name = expedition[i]
		local heroGrid = block['hero'.. index]
		if name and name:len() > 0 then
			self.heroGridMap[name] = heroGrid
			index = index + 1
			local hero = Hero.getHero(name)
			--CommonGrid.bind(heroGrid.headlv6)
			--heroGrid.headlv6:setHeroIcon(name)
			if heroGrid.heroGridS == nil then
				heroGrid.heroGridS = HeroGridS.new(heroGrid.headlv6,i)
			end
			heroGrid.heroGridS:setHero(hero)

			--self:onHeroLvUp(name)
			if rewardExp then
				Common.addNumAction(heroGrid.txtexp, rewardExp, "EXP+")
			else
				heroGrid.txtexp:setString("")
			end
			local nextLvExp = hero:getExpForNextLv()
			local percent = hero.exp/nextLvExp*100
			heroGrid.exp:setPercent(percent)
		end
	end
	for i=index,4 do
		local heroGrid = block['hero'.. i]
		heroGrid:setVisible(false)
	end
	local showName 
	for i=1,4 do
		showName = expedition[i]
		if showName then
			break
		end
	end
	CommonGrid.bind(self.heroBody)
	self.heroBody:setHeroIcon(showName,"b")
	self.heroBody._icon:setFlippedX(true)
	--self.heroBody._icon:setOpacity(100)
end

function onStopNumRun(self, evt)
	local block = self.main.master
	if self.rewardExpBlock ~= nil and self.rewardMoney ~= nil then
		block.txtexp:stopAllActions()
		if self.rewardExpBlock and self.rewardExpBlock > 0 then
			block.txtexp:setString("+" .. self.rewardExpBlock)
		else
			block.txtexp:setString("")
		end

		block.txtmoney:stopAllActions()
		local suffix = ""
		if self.addMoney then
			suffix = "+" .. self.addMoney 
		end
		if self.rewardMoney and self.rewardMoney > 0 then
			block.txtmoney:setString("+" .. self.rewardMoney .. suffix)
		else
			block.txtmoney:setString("0")
		end
		self.rewardExpBlock = nil
		self.rewardMoney = nil
	end

	if self.rewardExp ~= nil then 
		block = self.main.heroes
		for i,name in ipairs(self.expedition) do
			local heroGrid = block['hero'..i]
			heroGrid.txtexp:stopAllActions()
			if self.rewardExp then
				heroGrid.txtexp:setString("EXP+" .. self.rewardExp)
			else
				heroGrid.txtexp:setString("")
			end
		end
		self.rewardExp = nil
	end
end

function onClose(self,event,target)
	if event.etype == Event.Touch_ended then
		UIManager.removeUI(self)
	end
end

function clear(self)
	Instance = nil
	Control.clear(self)
end


