module("FaceUI", package.seeall)
setmetatable(_M, {__index = Control})

local TEN = 10

require("src/modules/face/FaceData")

Instance = nil

function new()
	local ctrl = Control.new(require("res/face/FaceSkin"),{"res/face/Face.plist"})
	print "say hello"
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	Instance = ctrl
	return ctrl
end

function clear(self)
	Control.clear(self)
	Instance = nil
end

function addStage(self)
	self:setScale(Stage.uiScale)
end

function uiEffect()
	return UIManager.FIRST_TEMP_RAW
end

function init(self)
	self.master = Face.getInstance()
	self:openTimer()
end

function start(self)
	self.bg:setVisible(false)

end


return FaceUI
