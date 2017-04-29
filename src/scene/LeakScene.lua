module(..., package.seeall)
setmetatable(_M, {__index = Scene}) 

function new()
	local scene = Scene.new("leak") 
	setmetatable(scene, {__index = _M})
	scene:init()
	return scene
end

function init(self)
    self:openTimer()
	self:addEventListener(Event.TouchEvent,onClick,self)
end

function onClick(self, event)
	if event.etype == Event.Touch_ended then
		if event.x > 500 then
			local scene = require("src/scene/LoginScene").new()
			Stage.replaceScene(scene)
		else
			Common.cUtil():printLeaks()
		end
	end
end
