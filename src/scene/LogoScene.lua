module(..., package.seeall)
setmetatable(_M, {__index = Scene}) 
function new()
	local scene = Scene.new("logo") 
	setmetatable(scene, {__index = _M})
	scene:init()
	return scene
end

function init(self)
	self:addArmatureFrame("res/master/logo/Logo.ExportJson")
	local bg = Sprite.new('loginbg','res/master/logo/LogoBg.png')
	bg:setAnchorPoint(0.5,0.5)
	bg:setPosition(Stage.width/2,Stage.height/2)
	bg:setScale(Stage.uiScale)
	self:addChild(bg,-100)
	bg.touchEnabled = false

	local logoAnimation = ccs.Armature:create('Logo')
	self.logoAnimation = logoAnimation
	logoAnimation:getAnimation():play("Animation1",-1,0)
	logoAnimation:setAnchorPoint(0.5,0.5)
	logoAnimation:setPosition(Stage.width/2-100,Stage.height/2)
    logoAnimation:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID) 
		if movementType == ccs.MovementEventType.complete then
			if Stage.currentScene.name == "logo" then
				Stage.replaceScene(require("src/scene/LoginScene").new())
			end
		end
	end)
	--logoAnimation:setPosition(0,Stage.uiBottom-70)
	--logoAnimation:setPosition(0,0)
	--local f = Common.getDrawBoxNode(logoAnimation:getBoundingBox())
	--self._ccnode:addChild(f)
	self._ccnode:addChild(logoAnimation)
	self:addEventListener(Event.TouchEvent,onTouchBlank,self)
end

function onTouchBlank(self,event)
	if event.etype == Event.Touch_ended then
		self.logoAnimation:getAnimation():stop()
		Stage.replaceScene(require("src/scene/LoginScene").new())
	end
end


function clear(self)
	--AudioEngine.stopMusic(true)
	Control.clear(self)
end


