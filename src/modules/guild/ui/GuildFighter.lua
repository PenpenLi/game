module(..., package.seeall)
setmetatable(_M, {__index = Control}) 
--方向
DIRECTION_RIGHT = -1
DIRECTION_LEFT = 1
--AI状态
STAND_STATUS = "stand"
RUN_STATUS = "run"
--边距
BORDER_WIDTH = 100
--速度 
SPEED = 3

local STATUSTB = {
	[1] = {id = STAND_STATUS,name = "待机"},
	[2] = {id = RUN_STATUS,name = "跑"},
}

function new(name,node)
	local o = {
		alive = true,
		heroName = name,
		parent = node,
		heroBody = nil,
		fly = nil,
		callback = nil,
	}
	setmetatable(o,{__index = _M})
	o:init()
	return true
end

function init(self)
	self.armatureCfg = require(string.format("src/config/hero/%sConfig",self.heroName)).Config
	local bigBody = string.format("res/armature/%s/small/%s.ExportJson",string.lower(self.heroName),self.heroName)
	local loader = AsyncLoader.new()
	loader:addEventListener(loader.Event.Load,function(s,event) 
		if self.alive and event.etype == AsyncLoader.Event.Finish then
			self:loadHeroBody(bigBody,self.heroName)
			self:changeStatus()
		else
			self.loader:removeAllArmatureFileInfo()
		end
	end)
	loader:addArmatureFileInfo(bigBody)
	loader:start()
	self.loader = loader
end

function loadHeroBody(self,resUrl,name)
	self.parent:addArmatureFrame(resUrl)
	self.armatureFile = resUrl
	self.heroBody = ccs.Armature:create(name)
	self.heroBody:setAnchorPoint(0.5,0.5)

	local w = 160
	local h = 210
	local node = Control.new({name="node",x=0,y=0,width=w,height=h,children={}})
	node:setPosition(0, 0)
    node:setAnchorPoint(0, 0)
	node:adjustTouchBox(w/2,0,0,0)

	local node2 = Control.new({name="node",x=0,y=0,width=w,height=h,children={}})
	node2:setPosition(0, 0)
    node2:setAnchorPoint(0.5, 0)
	local function onTouchBoss(self,event,target)
    	if event.etype == Event.Touch_ended then
			UIManager.addUI("src/modules/guild/boss/ui/GuildBossUI")
		end
	end
	node2:addEventListener(Event.TouchEvent,onTouchBoss,self)

	self.heroNode = node 
	local startPos = -self.parent:getPositionX() + Stage.winSize.width/2
	self:setPositionX(startPos)
	self.heroNode._ccnode:addChild(self.heroBody)
	self.heroNode:addChild(node2)
	self.parent:addChild(self.heroNode)
	self.parent:openTimer()
	self.parent:addEventListener(Event.Frame,onFrameEvent,self)

	local tt = cc.LabelTTF:create("公会BOSS",Label.UI_DEFAULT_FONT,20,cc.size(0,0),0,2)
	local height = self:getBoundingBox("受击框").height
	tt:setPositionY(height)
	self.heroNode._ccnode:addChild(tt)

	return self.heroBody
end

function onFrameEvent(self,event)
	self:doAI()
end

function doAI(self)
	_M[self.status](self)
end

function randomStatus(self)
	local status = math.random(1,2)
	return STATUSTB[status]
end

function randomDirection(self)
	local direction = math.random(1,2)
	if direction == 1 then
		return DIRECTION_LEFT
	elseif direction == 2 then
		return DIRECTION_RIGHT
	end
end

function playStatus(self,status)
	if self.status ~= status.id then
		self.heroBody:getAnimation():playWithNames({status.name},0,true)
		self.status = status.id
		if status.id == RUN_STATUS then
			local direction = self:randomDirection()
			self:setDirection(direction)
		end
	end
end

function changeStatus(self,event,target)
	local status = self:randomStatus()
	local nextTime = math.random(1,5)
	self:playStatus(status)
	self.parent:addTimer(function()
		self:changeStatus()
	end,nextTime,1,self)
end

--_M[func]
function stand(self)
	if self.heroBody then
	end
end

function run(self)
	if self.heroBody then
		local dx = -self:getDirection() * SPEED
		local boundBox = self:getBoundingBox("影子")
		local width = -boundBox.width
		if self:getPositionX() + width + dx > -self.parent:getPositionX() + Stage.winSize.width then
			self:setDirection(DIRECTION_LEFT)
		elseif self:getPositionX() + width + dx < -self.parent:getPositionX() then
			self:setDirection(DIRECTION_RIGHT)
		end
		self:setPositionX(self:getPositionX()+dx)
	end
end

function setDirection(self,direction)
    if direction == DIRECTION_RIGHT or direction == DIRECTION_LEFT then
        if self.direction ~= direction then
			local x = self:getPositionX()
            self.direction = direction
			self.heroBody:setScaleX(direction == DIRECTION_LEFT and 1 or -1)
			self:setPositionX(x)
        end
    end
end

function getDirection(self)
	return self.direction or DIRECTION_RIGHT
end

function getPositionX(self)
	local boundBox = self:getBoundingBox("影子")
    local x = self.heroNode:getPositionX()
    return x + (boundBox.x + boundBox.width / 2) * self:getDirection()
end

function setPositionX(self,x)
	local boundBox = self:getBoundingBox("影子")
	local rx = x - (boundBox.x + boundBox.width / 2) * self:getDirection()
    self.heroNode:setPositionX(rx)
end

function getBoundingBox(self,name)
	local bone = self.heroBody:getBone(name)
	return bone:getDisplayManager():getBoundingBox()
end
