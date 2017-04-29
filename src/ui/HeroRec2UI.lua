module(..., package.seeall)
setmetatable(_M, {__index = Control})
local Hero = require("src/modules/hero/Hero")

function new()
	local ctrl = Control.new(require("res/common/HeroRec2Skin"), {"res/common/HeroRec2.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function uiEffect()
	return UIManager.THIRD_TEMP
end

function init(self)
	_M.touch = Common.outSideTouch
	local descLb = self.group.recDesc.desc
	local contentSize = descLb:getContentSize()
	local posX,posY = descLb:getPosition()
	local rich = RichText.new(RichText.UI_RICH_TEXT_DEFAULT_SKIN)
	rich:setColor(38,11,11)
	rich:setPosition(posX+contentSize.width/2,posY+contentSize.height)
	rich:setContentSize(cc.size(contentSize.width,0))
	self.group.recDesc:addChild(rich)
	self.group.recDesc.desc:removeFromParent()
	self.group.recDesc.desc = rich
	self.group.heroList:setDirection(List.UI_LIST_HORIZONTAL)
	self.group.tjyxmc1:setVisible(false)
	self.group.tjyxmc2:setVisible(false)
	function onLeft(self)
		self.group.heroList:turnPage(List.UI_LIST_PAGE_LEFT,3)
	end
	self.group.left:addEventListener(Event.Click,onLeft,self)
	function onRight(self)
		self.group.heroList:turnPage(List.UI_LIST_PAGE_RIGHT,3)
	end
	self.group.right:addEventListener(Event.Click,onRight,self)
end

function setRec(self,recType,recDesc,recHero)
	self.group.recType:setString(recType)
	self.group.recDesc.desc:setString(recDesc)
	local row = #recHero
	self.group.heroList:setItemNum(row)
	for i = 1,row do
		local name = recHero[i]
		local ctrl = self.group.heroList:getItemByNum(i)
		ctrl:addEventListener(Event.TouchEvent,function(self,event) 
			if event.etype == Event.Touch_ended then
				UIManager.addChildUI("src/modules/hero/ui/HeroFragUI",name)
			end
		end,self)
		CommonGrid.bind(ctrl.heroBg)
		ctrl.heroBg:setHeroIcon(name)
		local cName = Hero.getCNameByName(name)
		Common.setLabelCenter(ctrl.titleLabel)
		ctrl.titleLabel:setString(cName)
	end
end

function setHeroList(self,mtype,list)
end
