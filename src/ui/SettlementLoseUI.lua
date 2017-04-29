module(..., package.seeall)
setmetatable(_M, {__index = Control})

local ItemConfig = require("src/config/ItemConfig").Config
local SettleConfig = require("src/config/SettlementConfig").Config
local ItemCmd = require("src/modules/bag/ItemCmd")

function new()
	local ctrl = Control.new(require("res/common/SettlementLoseSkin"), {"res/common/SettlementLose.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	return ctrl
end

function addStage(self)
	local back = LayerColor.new("backgroud",29,10,10,255,Stage.width,Stage.height)
	back.touchEnabled = false
	--back:setPositionX(-self:getPositionX())
	self:addChild(back,-1)
	local bg = Sprite.new('loseScene','res/common/losescene.jpg')
	bg.touchEnabled = false
	self:addChild(bg,-1)
	back:setPositionY(-Stage.uiBottom)
	self:setPositionY(Stage.uiBottom)
end

--[[
suming:宿命
weapon:神兵
herostar:英雄升星
baoshi:合成宝石
herolv:英雄等级提升
skill:技能提升"
--]]
local btnMap = {'shouchong','getHero','weaponUp','suming','weapon','herostar','baoshi','herolv','skill',"strength","gift","train","tupo"}
local btnDesc = {
	suming= "通过激活英雄之间的关系可大幅度提升英雄的属性",
	weapon = "提升神兵等级和品阶能提升全体英雄的属性",
	herostar = "收集足够的英雄碎片后，英雄就可以升星，提升各属性的成长",
	baoshi = "通过战役关卡掉落或战胜大蛇八杰可以获得宝石，装备宝石能提升英雄战斗力",
	herolv = "使用经验药水或参与战役战斗可以提升英雄等级",
	skill = "提升技能等级能快速增强英雄的战斗力",
}
--local posMap = {81,315,549}
local posMap = {196,430,549}
function init(self)
	self.sure:addEventListener(Event.Click,self.onClose,self)
	local master = Master.getInstance()
	for _,v in ipairs(SettleConfig) do
		if master.lv <= v.lv then
			self.conf = v
			break
		end
	end
	for _,b in pairs(btnMap) do
		self[b]:setVisible(false)
	end
	--self.hero.touchParent = false
	--self.skill.touchParent = false
	--self.hero:addEventListener(Event.Click, self.onOpenHeroUI, self)
	--self.skill:addEventListener(Event.Click, self.onOpenSkillUI, self)
	local centerX = 399
	local gap = 32
	local boxWidth = 90
	local boxNum = #self.conf.way
	local beginX = self:getContentSize().width/2 - (boxNum * boxWidth + (boxNum-1) * gap)/2
	for i,way in ipairs(self.conf.way) do
		local btn = self[way]
		btn:setPositionX(beginX+(gap+boxWidth) * (i-1))
		btn.openCmd = self.conf.clientCmd[i]
		btn:setVisible(true)
		btn:addEventListener(Event.Click, self.onOpenWay, self)
	end
end

function onOpenWay(self,event,target)
	local scene = require("src/scene/MainScene").new()
	Stage.replaceScene(scene)
	scene:addEventListener(Event.InitEnd, function()
		if target.openCmd and next(target.openCmd) then
			for kk,vv in pairs(target.openCmd) do
				if ItemCmd[kk] then
					if type(vv[1]) == 'number' then
						vv[1] = self.heros[vv[1]]
					end
					ItemCmd[kk](vv)
					break
				end
			end
		end
	end)
end

function setHeroes(self,expedition)
	self.heros = expedition
end

function onOpenHeroUI(self, event)
	self:replaceScene("src/modules/hero/ui/HeroLvUpUI")
end

function onOpenSkillUI(self, event)
	self:replaceScene("src/modules/skill/ui/SkillHeroUI")
end

function replaceScene(self, url)
	UIManager.removeUI(self)
	if Stage.currentScene.name ~= 'main' then
		local scene = require("src/scene/MainScene").new()
		Stage.replaceScene(scene)
		scene:addEventListener(Event.InitEnd, function()
			UIManager.replaceUI(url)
		end)
	else
		UIManager.replaceUI(url)
	end
end

function setTitle(self,title,difficulty)
	--[[
	local block = self
	--title
	block.titleLabel:setString(title)
	--star
	if difficulty then
		for i=1,difficulty do 
			block.star['star'..i]:setVisible(true)
		end
		if difficulty < 3 then
			for i=difficulty+1,3 do
				block.star['star'..i]:setVisible(false)
			end
		end
	end
	--]]
end

function onClose(self,event,target)
	UIManager.removeUI(self)
	if self.closeFun then
		self.closeFun()
	end
end

function setCloseFun(self, fun)
	self.closeFun = fun
end

