module("LvUpUI", package.seeall)
setmetatable(_M, {__index = Control})
local Hero = require("src/modules/hero/Hero")
local OpenLvConfig = require("src/config/OpenLvConfig").Config
local OriginalPos = OriginalPos or {}

function new(heroName,attrs,name)
	local ctrl = Control.new(require("res/common/LvUpSkin"), {"res/common/LvUp.plist"})
	ctrl.name = "TopMasterLvUp"
	setmetatable(ctrl,{__index = _M})
	ctrl:init(heroName,attrs,name)
	return ctrl
end

function init(self,heroName,attrs,name)
	self.canRemove = false
	self.newfunc = {}
	local back = LayerColor.new("backgroud",0,0,0,200,Stage.width,Stage.height)
	back.touchEnabled = false
	back:setPositionY(-Stage.uiBottom)
	self:addChild(back,-1)
	self:addEventListener(Event.TouchEvent,function(self,event) 
		if event.etype == Event.Touch_ended then
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_SUB_COMPONENT)
			if self.canRemove then
				self:removeFromParent() 
				Master.getInstance():dispatchEvent(Event.LvUpUIEnd,{etype=Event.Touch_ended,heroName=heroName,attrs=attrs,effectName=name})
				if #self.newfunc > 0 then
					UIManager.addUI("src/ui/NewFuncUI",self.newfunc)
				end
			end
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_SUB_COMPONENT)
		end
	end)
	self:addArmatureFrame("res/common/effect/lvUpDesc/LvUp.ExportJson")
	self.master = Master.getInstance()
	local cName
	local effectName = name or "lvup"
	if effectName == "transfer" then
		effectName = "lvup"
		cName = Hero.getCNameByName(heroName)
		self.src:setPositionX(self.arrow2:getPositionX())
		self.dst:setVisible(false)
		self.arrow2:setVisible(false)
		Common.setBtnAnimation(self.src._ccnode,"LvUp",effectName,{y=100})
	elseif not heroName then
		cName = self.master.name 
		CommonGrid.bind(self.src.head)
		self.src:setPositionX(self.arrow2:getPositionX())
		self.src.head:setBodyIcon(self.master.bodyId)
		self.dst:setVisible(false)
		self.arrow2:setVisible(false)
		Common.setBtnAnimation(self.src._ccnode,"LvUp",effectName,{y=100})
	else
		Common.setBtnAnimation(self.arrow2._ccnode,"LvUp",effectName,{y=80})
		cName = Hero.getCNameByName(heroName)
	end
	UIManager.playMusic("lvUpArt")
	self.src.txtname:setAnchorPoint(0.5,0)
	self.src.txtname:setString(cName)
	local hero = Hero.heroes[heroName]
	local srcGrid = HeroGridS.new(self.src.head)
	self.dst.txtname:setAnchorPoint(0.5,0)
	self.dst.txtname:setString(cName)
	local dstGrid = HeroGridS.new(self.dst.head)

	local maxId = 0
	local hasStarUp = false
	for i = 1,5 do
		self.src["star"..i]:setVisible(false)
		self.dst["star"..i]:setVisible(false)
		self["line"..i]:setVisible(false)
		self["line"..i].txtname:setAnchorPoint(1,0)
		self["line"..i].txtsrc:setAnchorPoint(0.5,0)
		self["line"..i].txtdst:setAnchorPoint(0.5,0)
		if attrs[i] then
			maxId = maxId + 1
			local attrName = attrs[i].cname
			if not attrName then
				if attrs[i].name == "star" then
					attrName = "星级"
					hasStarUp = true
				else
					attrName = Hero.getAttrCName(attrs[i].name)	
				end
			elseif attrName == "战队等级" then
				local temp = {}
				for k,v in pairs(OpenLvConfig) do
					temp[v.charLv] = temp[v.charLv] or {}
					table.insert(temp[v.charLv],v)
				end
				for n = attrs[i].src+1,attrs[i].dst do
					if temp[n] then
						for k,v in pairs(temp[n]) do
							if OpenLvConfig[v.id].newFunc == 1 then
								table.insert(self.newfunc,v.id)
							end
						end
					end
				end
			end
			self["line"..i].txtname:setString(attrName..":")
			self["line"..i].txtsrc:setString(attrs[i].src)
			if attrs[i].dst then
				self["line"..i].txtdst:setString(attrs[i].dst)
			else
				self["line"..i].arrow:setVisible(false)
				self["line"..i].txtdst:setVisible(false)
			end
		end
	end
	if name == "transfer" then
		hero.strength.transferLv = hero.strength.transferLv - 1
		srcGrid:setHero(hero)
		hero.strength.transferLv = hero.strength.transferLv + 1
	elseif hasStarUp then
		hero.quality = hero.quality - 1
		srcGrid:setHero(hero)
		hero.quality = hero.quality + 1
	else
		srcGrid:setHero(hero)
	end
	dstGrid:setHero(hero)

	local function lineMove(curId)
		if curId <= maxId then
			local line = self["line"..curId]
			line:setVisible(true)
			local callBackFuc = function()
				--if curId >= maxId then
				--	--self:dealEnd()
				--	print("lineMove end")
				--else
				--	lineMove(curId+1)
				--end
				if curId >= maxId then
					self.canRemove = true
				end
				lineMove(curId+1)
			end
			local oldx = line:getPositionX()
			line:setPositionX(oldx-line:getContentSize().width)
			local moveto = cc.MoveTo:create(0.1,cc.p(oldx,line:getPositionY()))
			local callBack=cc.CallFunc:create(callBackFuc)
			line:runAction(cc.Sequence:create({moveto,callBack}))
			UIManager.playMusic("lvUpAttr")
		end
	end
	self:addTimer(function() 
		lineMove(1)
	end, 0.3, 1, self)
	self:openTimer()
end

function uiEffect(self)
	return UIManager.FIRST_TEMP_RAW
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
	self:setScale(Stage.uiScale)
end


return LvUpUI
