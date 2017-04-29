module(..., package.seeall)
setmetatable(_M, {__index = Control})

local Hero = require("src/modules/hero/Hero")
local SkillGroupConfig = require("src/config/SkillGroupConfig").Config
local SkillDefine = require("src/modules/skill/SkillDefine")


function new()
	local ctrl = Control.new(require("res/common/HeroRecSkin"), {"res/common/HeroRec.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function uiEffect()
	return UIManager.THIRD_TEMP
end

function init(self)
	_M.touch = Common.outSideTouch

	self.itemSkinTb = {}
	for _,childSkin in ipairs(self.heroList._skin.children) do
		self.itemSkinTb[childSkin.name] = childSkin	
	end
	for _,childSkin in ipairs(self.heroList2._skin.children) do
		self.itemSkinTb[childSkin.name] = childSkin	
	end
	Common.setLabelCenter(self.title.desc,"left")
	self.heroList2:setVisible(false)
	self.listUI = self.heroList

	local descLb = self.title.desc
	local contentSize = descLb:getContentSize()
	local posX,posY = descLb:getPosition()
	local rich = RichText.new(RichText.UI_RICH_TEXT_DEFAULT_SKIN)
	rich:setColor(38,11,11)
	rich:setPosition(posX+contentSize.width/2,posY+contentSize.height)
	rich:setContentSize(cc.size(contentSize.width,0))
	self.title:addChild(rich)
	self.title.desc:removeFromParent()
	self.title.desc = rich
	--[[
	self.heroList:setBgVisiable(false)
	self.heroList:setDirection(List.UI_LIST_HORIZONTAL)
	Common.setLabelCenter(self.descTxt)

	self.descTxt:setVisible(false)
	local contentSize = self.descTxt:getContentSize()
	local posX,posY = self.descTxt:getPosition()
	local rich = RichText.new(RichText.UI_RICH_TEXT_DEFAULT_SKIN)
	rich:setColor(38,11,11)
	rich:setPosition(posX+contentSize.width/2,posY+contentSize.height)
	rich:setContentSize(cc.size(contentSize.width,0))
	self.rich = rich
	self:addChild(rich)
	--]]
end

function setOrochi(self)
	self.title:setVisible(false)
	self.heroList:setVisible(false)
	self.heroList2:setVisible(true)
	self.listUI = self.heroList2
end

function setRec(self,type,desc,heroList)
	local descLb = self.title.desc 
	print("========>",desc)
	descLb:setString(desc)
	--descLb:setPositionY(descLb._skin.y-descLb:getContentSize().height+20)
	self:setHeroList(type,heroList)
end

function setHeroList(self,type,list)
	for _,v in ipairs(list) do
		local itemSkin = self.itemSkinTb["item" .. v.recType]
		local name = v.hero
		local listUI = self.listUI
		local item = listUI:getItemByNum(listUI:addItem(Control.new(itemSkin)))
		item:addEventListener(Event.TouchEvent,function(self,event) 
			if event.etype == Event.Touch_ended then
				UIManager.addChildUI("src/modules/hero/ui/HeroFragUI",name)
			end
		end,self)
		CommonGrid.bind(item.heroBg)
		if v.recType == 3 then
			Common.setLabelCenter(item.titleLabel,'left')
		else
			Common.setLabelCenter(item.titleLabel)
		end
		item.heroBg:setHeroIcon(name)
		item.titleLabel:setString(Hero.getCNameByName(name))
		for i,skillId in ipairs(v.skill) do
			local pos = i
			local conf = SkillGroupConfig[skillId]
			assert(conf,"lost skillconf===>gid==>" .. skillId)
			if conf and conf.type == SkillDefine.TYPE_COMBO then
				pos = 4	
			end
			local icon = item["skillBg" .. pos]
			if icon then
				CommonGrid.bind(icon,"tips")
				icon.touchParent = false
				icon:setSkillGroupIcon(skillId,50)
			end
		end
		if not v.skill[4] and item.tuijian2 then
			item.tuijian2:setVisible(false)
			item.bg:setVisible(false)
			item["skillBg4"]:setVisible(false)
		end
		if v.desc and item.desc then
			local descLb = item.desc
			descLb:setAnchorPoint(0,1)
			Common.setLabelCenter(descLb,"left")
			descLb:setPositionY(descLb._skin.y+descLb._skin.height)
			descLb:setString(v.desc)
		end
	end
end

function setDesc(self,desc)
	--self.descTxt:setString(desc)
	self.rich:setString(desc)
end




return _M

