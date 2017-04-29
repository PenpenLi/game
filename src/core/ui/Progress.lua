module("Progress", package.seeall)
setmetatable(Progress, {__index = Control}) 

UI_PROGRESS_TYPE = "Progress"
UI_PROGRESS_DEFAULT_SKIN = {
	name="myProgress",type="Progress",x=98,y=72,width=275,height=24,
	children=
	{
		{name="hpLeft1",type="Image",x=0,y=0,width=275,height=24,
			{name = "hpLeft1",status = "",img="Fight.pg_hpLeft1",x=0,y=0,width=385,height=120},
		},
	}
}

isProgress = true

function new(skin)
	local pg = { 
		name = skin.name,
		uiType = UI_PROGRESS_TYPE,
		_skin = skin, 
		_ccnode = nil,
	}
	setmetatable(pg, {__index = Progress})
	pg:init(skin)
	return pg
end

function init(self, skin)
	self.touchChildren = false
	--Control.init(self, skin)
	local imgSkin = skin.children[1]
	self._ccnode = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName(imgSkin[1].img .. ".png"))
	if imgSkin[1].status == "r" then
		self._ccnode:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
	else
		self._ccnode:setType(cc.PROGRESS_TIMER_TYPE_BAR)
		self._ccnode:setBarChangeRate(cc.p(1,0))
		self._ccnode:setMidpoint(cc.p(0,0))
	end
    self._ccnode:setPosition(cc.p(skin.x,skin.y))
	self._ccnode:setAnchorPoint(cc.p(0,0))
end

function setType(self,t)
	self._ccnode:setType(t)
end

function setPercent(self,per)
	self._ccnode:setPercentage(per)
end

function getPercent(self)
	return self._ccnode:getPercentage()
end

function setMidpoint(self,p)
	self._ccnode:setMidpoint(p)
end

function setBarChangeRate(self,p) --cc.p(1, 0))
	self._ccnode:setBarChangeRate(p)
end

function setReverseDirection(self,flag)
	self._ccnode:setReverseDirection(flag)
end
