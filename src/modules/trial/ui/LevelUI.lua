module(..., package.seeall)
setmetatable(_M, {__index = Control}) 

local Hero = require("src/modules/hero/Hero")
local HeroDefine = require("src/modules/hero/HeroDefine")
local BaseMath = require("src/modules/public/BaseMath")

--local trialConfig = require("src/config/trialConfig").Config
local Logic = require("src/modules/trial/TrialLogic")
local Define = require("src/modules/trial/TrialDefine")

local Col = 4

function new(levelId)
    local ctrl = Control.new(require("res/trial/LevelSkin"),{"res/trial/Level.plist"})
    setmetatable(ctrl,{__index = _M})
	ctrl.levelId = levelId
    ctrl:init()
    return ctrl
end

function uiEffect()
	return UIManager.FIRST_TEMP
end

function init(self)
	self.master = Master.getInstance()

	self.levelInfo = Logic.getLevelByLevelId(self.levelId)
	local counter = Define.MAX_LEVEL_COUNTER - self.levelInfo.counter
	self.counterLabel:setString(tostring(counter))

	self.close:addEventListener(Event.Click,onBack,self)
	self.heroList:setBgVisiable(false)
	self:createHeroList()
	self:createReward()

	self.fight:addEventListener(Event.Click,onFight,self)
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
end


function createHeroList(self)
	local monsters = Logic.getLevelMonster(self.levelId)
	local rows = math.ceil(#monsters / Col )
	self.heroList:setItemNum(rows)
	for i=1,rows do
		local item = self.heroList:getItemByNum(i) 
		for j=1,4 do
			local num = (i -1) * Col +j
			local monster = monsters[num]
			local grid = item["grid" .. j]
			local numBg = item["num" .. j]
			if monster then 
				grid = CommonGrid.bind(grid)
				grid:setMonsterIcon(monster.monsterId)
				if num == #monsters then
					num = "援"
				end
				Common.setLabelCenter(numBg.num)
				numBg.num:setString(num)
			else
				numBg:setVisible(false)
				grid:setVisible(false)
			end
		end
	end
end

function createReward(self)
	local itemList = Logic.getLevelItem(self.levelId)	
	for i=1,5 do
		local grid = self.reward["grid" .. i]
		CommonGrid.bind(grid,"tips")
		grid:setItemIcon(itemList[i])
	end
end

--
function onFight(self,event,target)
	if self.levelInfo.counter >= Define.MAX_LEVEL_COUNTER then
		Common.showMsg("今天挑战次数已满")
	else
		UIManager.addUI("src/modules/trial/ui/FightUI",self.levelId)
	end
end


function onBack(self,event)
	UIManager.removeUI(self)
end

function setLvNum(lv,target)
	local lv = cc.LabelBMFont:create(tostring(lv),  "res/common/LvNum.fnt")
	lv:setAnchorPoint(cc.p(0,0))
	lv:setPosition(target:getPosition())
	target:setVisible(false)
	target._parent._ccnode:addChild(lv)
end





