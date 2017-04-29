--[[
--
-- 数据请求等待条
--]]
module("WaittingUI", package.seeall)
setmetatable(_M, {__index = Control})

local TIME_OUT = 8

Event = {
	Timeout = "timeout",		--收包超时
}

local list = {}

function create(packetId,timeout)
	local instance = list[packetId]
	--延迟删除
	if instance then
		instance:removeFromParent()
		instance = nil
	end
	if not instance then
		instance = new(packetId,timeout)
		local parent = Stage.currentScene
		parent:addChild(instance,9999)
		instance:setPosition(0,0)
		list[packetId] = instance
	end
	instance:addPacket()
	return instance
end

function remove(packetId)
	local instance = list[packetId]
	if instance then
		instance:removePacket()
	end
end

function cleanup()
	for _, instance in pairs(list) do
		instance:removeFromParent()
	end
end

local index = 0
function new(packetId,timeout)
	local ctrl = LayerColor.new("TopWaitting",0,0,0,100,Stage.width,Stage.height)
	setmetatable(ctrl,{__index = _M})
	--ctrl.name = "WaittingUI" 
	ctrl.gname = "TopWaitting"
	ctrl.name = "WaittingUI_" .. index
	index = index + 1
	ctrl.packetId = packetId
	ctrl.counter = 0
	ctrl.timeout = timeout or TIME_OUT
	ctrl:init()
	return ctrl
end

function uiEffect(self)
	return UIManager.FIRST_TEMP_LABEL
end


function init(self)
	local size = self:getContentSize()
	self.main = Control.new(require("res/common/WaittingSkin"),{"res/common/Waitting.plist"})
	self.main:setAnchorPoint(0.5,0.5)
	self.main:setPosition(size.width/2,size.height/2)
	self:addChild(self.main)

	self.timer = Stage.addTimer(function() 
		self:dispatchEvent(Event.Timeout,{etype=Event.Timeout,packetId=self.packetId})
		--TipsUI.showTipsOnlyConfirm("网络似乎不太好")
		self:removeFromParent()
	end,self.timeout,1)
	--加菊花
	local fb = Common.getRotateFlower()
	fb:setAnchorPoint(0.5,0.5)
	local x,y = self.main.txttip:getPosition() 
	fb:setPosition(x - 25,y + self.main.txttip:getContentSize().height/2)
	self.main._ccnode:addChild(fb)
end

function addPacket(self)
	self.counter = self.counter + 1
end

function removePacket(self)
	self.counter = self.counter - 1
	if self.counter == 0 then
		self:removeFromParent()
	end
end

function removeFromParent(self)
	Stage.delTimer(self.timer)
	DisplayObject.removeFromParent(self)
	list[self.packetId] = nil
end

function addStage(self)
	--local back = LayerColor.new("backgroud",0,0,0,100,Stage.width,Stage.height)
	--self:addChild(back,-99)
	--back:setPositionY(-Stage.uiBottom)
	--self:setPositionY(Stage.uiBottom)
end







