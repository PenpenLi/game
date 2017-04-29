module(..., package.seeall)
setmetatable(_M, {__index = Scene}) 
function new()
	local scene = Scene.new("login") 
	setmetatable(scene, {__index = _M})
	scene:init()
	return scene
end

function init(self)
	--[[
	local bg = Sprite.new('loginbg','res/master/Background.jpg')
	bg:setAnchorPoint(0.5,0.5)
	bg:setPosition(Stage.width/2,Stage.height/2)
	bg:setScale(Stage.uiScale)
	self:addChild(bg,-100)
	bg.touchEnabled = false
	--]]
	
	self:playMusic()
end

function playMusic(self)
	AudioEngine.playMusic(string.format("res/sound/loginScene/BackgroundMusic.mp3"),true)
end

function start(self)
	--loginUI
	local loginUI = require("src/modules/master/ui/MasterLoginUI").new()
	self.ui = loginUI
	self:addChild(loginUI)
	loginUI:start()
	--[[
	local labelSkin = {
		name="loadLabel",type="Label",x=0,y=0,width=0,height=0,
		normal={txt="版本号:" .. Device.getFullVersion(),size=20,bold=false,italic=false,color={255,255,255}}
	}
	local version = Label.new(labelSkin)
	local size = version:getContentSize()
	version:setPosition(Stage.width-size.width-50,Stage.height-50)
	self:addChild(version)
	--]]
end


function clear(self)
	AudioEngine.stopMusic(true)
	Scene.clear(self)
end






