module(..., package.seeall)
setmetatable(_M, {__index = Control}) 

local Hero = require("src/modules/hero/Hero")
local HeroDefine = require("src/modules/hero/HeroDefine")
local BaseMath = require("src/modules/public/BaseMath")
local ShopUI = require("src/modules/shop/ui/ShopUI")
local ShopDefine = require("src/modules/shop/ShopDefine")

local Config = require("src/config/TrialConfig").Config
local Logic = require("src/modules/trial/TrialLogic")
local Define = require("src/modules/trial/TrialDefine")


Instance = nil
function new(levelType)
    local ctrl = Control.new(require("res/trial/LevelGateSkin"),{"res/trial/LevelGate.plist"})
    setmetatable(ctrl,{__index = _M})
	ctrl.levelType = levelType or 1
    ctrl:init()
	Instance = ctrl
    return ctrl
end

function clear(self)
	Control.clear(self)
	Instance = nil
end

function uiEffect()
	--return UIManager.THIRD_TEMP
	return UIManager.FIRST_TEMP_RAW
end

function init(self)
	self.master = Master.getInstance()
	--_M.touch = Common.outSideTouch

	for i=1,3 do
		self.title["t" .. i]:setVisible(false)
	end
	local titleLb = self.title["t" .. self.levelType]
	titleLb:setVisible(true)

	self.back:addEventListener(Event.Click,function() UIManager.removeUI(self) end,self)
	--self.view:addEventListener(Event.Click,onViewItem,self)
	self.rec:addEventListener(Event.Click,doRecHero,self)
	self:addArmatureFrame("res/common/effect/heroRec/HeroRec.ExportJson")
	Common.setBtnAnimation(self.rec._ccnode,"HeroRec","1",{x=-52,y=7})
	self.level:setTopSpace(0)
	self.level:setBgVisiable(false)
	self.levelPage = self.level:getItemByNum(self.level:addItem())
	print("self.======>",self.levelPage.name)
	self.levelPage.touch = function(page,event) self:onTouchPage(page,event) end 
	self.level:setContentSize(cc.size(809,self.level._skin.height))
	self.level:setDirection(List.UI_LIST_HORIZONTAL)
	--self:createLevel()
	self:setLevelData()
	self:openTimer()
	self:addTimer(function() 
		local key = "level_" .. self.levelType
		if self.master:getDBIntVal("trial",key) ~= 1 then
			self.master:setDBIntVal("trial",key,1)
			self:doRecHero()
		end
	end,0.1,1)
	--增加次数
	self.addTime:addEventListener(Event.Click,function() 
		local shopIdName = string.format("K_SHOP_VIRTUAL_TRIAL_%d_ID",self.levelType)
		ShopUI.virBuy(ShopDefine[shopIdName],{self.levelType})
	end,self)
end

function doRecHero(self)
	local conf = Config[self.curLevelId]
	local ui = UIManager.addChildUI("src/ui/HeroRec2UI")
	ui:setRec(conf.recType,conf.recDesc,conf.recHero)
end

function addStage(self)
end

function onViewItem(self,event,target)
	--UIManager.addChildUI("src/modules/trial/ui/ViewItemUI",self.levelType)
end


function onTouchPage(self,page,event)
	if event.etype == Event.Touch_ended then
		local worldPoint = event.p
		local touchLocation = page._parent._ccnode:convertToNodeSpace(worldPoint) 
		for i=1,6 do
			local child = page["lv" .. i]
			if not child then
				break
			end
			local levelId = child.levelId
			local bound = child._ccnode:getBoundingBox()
			if cc.rectContainsPoint(bound, touchLocation) then
				local loc = child._ccnode:convertToNodeSpace(worldPoint)
				local ret,r,g,b,a = child["lvicon" .. i]._ccnode:getPixelRGBA(loc.x,loc.y)
				print('ret='..tostring(ret)..' r='..r..' g='..g..' b='..b..' a='..a)
				if ret and a > 0 then
					if self:isOpen(levelId) then
						if self.leftCounter <= 0 then
							Common.showMsg("今天挑战次数已满")
						else
							print("open levelId========>",levelId)
							UIManager.addChildUI("src/modules/trial/ui/FightUI",levelId)
						end
						break
					else
						local msg = string.format("%d级开启",Config[levelId].openLv)
						Common.showMsg(msg)
						break
					end
				end
			end
		end
	end
end

function isOpen(self,levelId)
	return Config[levelId].openLv <= Master.getInstance().lv
end

function setLevelData(self)
	if not self.levelType then return end
	local list = {}
	for levelId,v in pairs(Config) do
		list[#list+1] = v
	end
	table.sort(list,function(a,b) return a.levelId < b.levelId end)
	self.sortList = list
	local levelData = Logic.getLevelList()
	local index = 1
	for _,v in ipairs(self.sortList) do
		if Config[v.levelId].type == self.levelType then
			self.curLevelId = v.levelId
			local lvInfo = Logic.getLevelByLevelId(v.levelId)
			local item = self.levelPage["lv" .. index]
			index = index + 1
			if item then
				item.levelId = v.levelId
				if not self:isOpen(v.levelId) then
					item:shader(Shader.SHADER_TYPE_GRAY)
				end
			end
		end
	end
	--次数
	local counter = Define.MAX_LEVEL_COUNTER-Logic.getCounterByType(self.levelType)
	self.leftCounter = counter
	self.counter:setString(string.format("%s",counter))
end

