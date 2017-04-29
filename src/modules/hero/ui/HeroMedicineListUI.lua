module(..., package.seeall)
local HeroListUI = require("src/ui/HeroListUI")
setmetatable(_M, {__index = HeroListUI})
local Def = require("src/modules/hero/HeroDefine")
local Hero = require("src/modules/hero/Hero")
local BagData = require("src/modules/bag/BagData")
local BagLogic = require("src/modules/bag/BagLogic")
local ItemConfig = require("src/config/ItemConfig").Config
Instance = nil

function new(itemId)
	local ctrl = HeroListUI.new("recruited",heroName)
	setmetatable(ctrl,{__index = _M})
	ctrl.name = "HeroMedicineListUI"
	ctrl:init(itemId)
	Instance = ctrl
	return ctrl
end

function init(self,itemId)
	self.itemId = itemId
	self.herocnt.txtmedtip:setVisible(true)
	self:addArmatureFrame("res/common/effect/progup/progup.ExportJson")
	self:addArmatureFrame("res/common/effect/lvUpTxt/lvUpTxt.ExportJson")

end


function onClickRecruitedHero(self,event,target)
	local heroName = target.heroName
	local hero = Hero.getHero(heroName)
	local function onHold(self,event,target)
		local itemNum = BagData.getItemNumByItemId(self.itemId)
		if itemNum <= 0 then
			local itemName = ItemConfig[self.itemId].name
			if itemName then
				Common.showMsg(itemName..'不足')
			end
			return
		end
		
		local nextExp = hero:getExpForNextLv()
		if hero.lv >= Master:getInstance().lv and hero.exp == nextExp then
			-- local tip = TipsUI.showTipsOnlyConfirm("英雄等级无法超过战队等级")
			Common.showMsg('英雄等级无法超过战队等级')
		else
			local cnt = 1
			if event then
				local t = math.abs(event.maxTimes)
				if t < 3 then
					cnt = 1
				elseif t < 5 then
					cnt = math.min(4,itemNum)
				elseif t < 10 then
					cnt = math.min(8,itemNum)
				elseif t < 15 then
					cnt = math.min(10,itemNum)
				else
					cnt = math.min(13,itemNum)
				end
			end
			BagLogic.useItem(self.itemId,cnt,{heroName})
		end
	end

	if event.etype == Event.Touch_began then
		if target.holdTimer then
			target:delTimer(target.holdTimer)
		end
		target.holdTimer = target:addTimer(onHold,0.2,-1,self)
		target:openTimer()
	elseif event.etype == Event.Touch_ended then
		onHold(self)
		if target.holdTimer then
			target:delTimer(target.holdTimer)
			target.holdTimer = nil
		end
	elseif event.etype == Event.Touch_out then
		if target.holdTimer then
			target:delTimer(target.holdTimer)
			target.holdTimer = nil
		end
	end
end

function onClickUnRecruitedHero(self,event,target)
	if event.etype == Event.Touch_ended then
	end
end

function onClickComposeHero(self,event,target)
end

function refreshRecruitedHero(self,item)
	local hero = Hero.getHero(item.heroName)
	item.lvpb = ccs.Armature:create('progup')
	item.lvpb:setAnchorPoint(0.5,0.5)
	local x,y = item.recruited.expprog:getContentSize().width/2,item.recruited.expprog:getContentSize().height/2
	item.lvpb:setPosition(x,y)
	item.recruited.expprog._ccnode:addChild(item.lvpb,10)
	self:refreshLvUp(item,hero)
end

function showLvUp(self,name,lvup)
	for i,item in ipairs(self.herolist.itemContainer) do
		if item.heroName == name and item.recruited and item.recruited._ccnode and item.recruited:isVisible() then
			local hero = Hero.getHero(name)
			self:refreshLvUp(item,hero)
			item.lvpb:getAnimation():play("经验条2",-1,0)
			UIManager.playMusic('expUp')

			if lvup then
				local ani = ccs.Armature:create("lvUpTxt")
				ani:setAnchorPoint(0.5,0.5)
				local size = item:getContentSize()
				item._ccnode:addChild(ani,1)
				ani:setPosition(size.width/2,size.height/2+100)
				-- ani:setPosition(px+size.width/2,py+size.height/2)
				ani:getAnimation():play("头像升级啦",-1,0)
			end

		end
	end
end
