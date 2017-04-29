module(..., package.seeall)
local HeroRecruitEffect = require("src/modules/hero/ui/HeroRecruitEffect")
local HeroDefine = require("src/modules/hero/HeroDefine")
setmetatable(_M, {__index = HeroRecruitEffect})
local cache = {}

function new(name,star,color,fragNum,disFrag)
	local ctrl = HeroRecruitEffect.new(name,star)
	setmetatable(ctrl,{__index = _M})
	ctrl:init(color,fragNum,disFrag)
	return ctrl
end

function addStage(self)
end

function init(self,color,fragNum,disFrag)
	self.disFrag = disFrag
	self.color = color
	self.fragNum = fragNum
	self:setAnchorPoint(0.5,0.5)
	local width = Stage.winSize.width/Stage.uiScale
	local height = Stage.winSize.height/Stage.uiScale
	self:setPosition(width/2,height/2-Stage.uiBottom)
	self.heroUI.confirm:removeEventListener(Event.TouchEvent,self.onClose)
end

function touch(self,event)
	Control.touch(self,event)
	if event.etype == Event.Touch_ended then
		if self.step == 1 then
			if self.disFrag == 1 then
				local scaleTo = cc.ScaleTo:create(0.3,0.8,0.8)
				local moveBy = cc.MoveBy:create(0.3,cc.p(0,50))
				local spawn = cc.Spawn:create(scaleTo,moveBy)
				self.recruitEffect_card:runAction(spawn)
				self.heroUI:setVisible(true)
				self.char:setVisible(false)
				self.heroUI.tabhdxyx:setVisible(false)
				self.heroUI.txtname:setVisible(false)
				self.heroUI.btm1:setVisible(false)
				self.heroUI.txtdesc:setVisible(true)
				self.heroUI.txtdesc2:setVisible(true)
				local qualityName = HeroDefine.HERO_QUALITY[self.color].name
				self.heroUI.txtdesc:setAnchorPoint(0.5,0)
				self.heroUI.txtdesc2:setAnchorPoint(0.5,0)
				self.heroUI.txtdesc:setString(string.format("已拥有该英雄，%s色卡牌转换成该英雄碎片%d个",qualityName,self.fragNum))
				self.heroUI.txtdesc2:setString("英雄碎片可提升英雄品质")
				self.heroUI.txtdesc:setPositionX(420)
				self.heroUI.txtdesc2:setPositionX(420)
				self.heroUI.confirm:setVisible(false)
				self.heroUI.hdxyxzi:setVisible(false)
			else
				self.recruitEffect_card:setVisible(false)
				self.heroUI:setVisible(true)
				self.char:getAnimation():playWithNames({'待机'},0,true)
			end
			self.step = 2
		elseif self.step == 2 then
			UIManager.removeUI(self)
			if not empty() then
				local data = popCache()
				local ShopOnceUI = UIManager.addChildUI(data.url,unpack(data.params))
				ShopOnceUI:refreshBack(unpack(data.params))
			end
			Stage.currentScene:dispatchEvent(Event.HeroRecruitRemove)
		end
	end
end

function closePanel(self)
	cache = {}
	self:removeFromParent()
end

function empty()
	return #cache <= 0 
end

function pushCache(data)
	cache[#cache+1] = data
end

function topCache()
	return cache[#cache]
end

function popCache()
	local data = topCache()
	cache[#cache] = nil
	return data
end
