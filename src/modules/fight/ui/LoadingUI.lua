module(..., package.seeall)
setmetatable(_M, {__index = Control})

local LoadingConfig = require("src/config/LoadingConfig").Config

function new()
	local ctrl = Control.new(require("res/common/LoadingbarSkin"),{"res/common/Loadingbar.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function init(self)
	local labelBgSize = self.loadLabelBg:getContentSize()
	local labelSkin = {
		name="loadLabel",type="Label",
		x=self.loadLabelBg:getPositionX() + labelBgSize.width/2,y=self.loadLabelBg:getPositionY() + labelBgSize.height/2,
		width=0,height=labelBgSize.height,
		normal={txt="test",font="SimSun",size=20,bold=false,italic=false,color={255,255,255}}
	}
	self.loadLabel = Label.new(labelSkin)
	self.loadLabel:setDimensions(0,0)
	self.loadLabel:setAnchorPoint(0.5,0.5)
	self:addChild(self.loadLabel)

	self:initStory()

	local fb = Common.getRotateFlower()
	fb:setPositionY(self.loadLabel:getPositionY())
	self.flower = fb
	self._ccnode:addChild(fb)

	self:openTimer()
	self:addTimer(loadingTxt, 3, 3)
	self:loadingTxt()

	self.loader = AsyncLoader.new()
end

function loadingTxt(self)
	local len = #LoadingConfig
	local i = math.random(1, len)
	for n = 1, len do 
		local cfg = LoadingConfig[(i + n) % len + 1]
		if cfg.lv <= Master.getInstance().lv then
			self:setBarString(cfg.txt)
			return
		end
	end
end

function initStory(self)
	self:addArmatureFrame("res/fight/Loading.ExportJson")
	local skin = {name="story",type="Container",x=250,y=200,children={}}
	self.story = Control.new(skin)
	self.story:setScale(0.9)
	self:addChild(self.story)

	local terry = ccs.Armature:create("Loading")
	terry:getAnimation():play('特瑞待机',-1,1)
	terry:setPosition(450,0)
	terry:setScaleX(-1)
	self.story._ccnode:addChild(terry)
	self.terry = terry 

	local mary = ccs.Armature:create("Loading")
	mary:getAnimation():play('玛丽跑',-1,1)
	mary:setPosition(0,0)
	mary:setScaleX(-1)
	self.story._ccnode:addChild(mary)
	self.mary = mary

	local dog = ccs.Armature:create("Loading")
	dog:getAnimation():play('狗跑',-1,1)
	dog:setPosition(80,0)
	dog:setScaleX(-1)
	self.story._ccnode:addChild(dog)
	self.dog = dog 
end

function storyRun(self, val) 
	if self.mary and self.dog then
		self.mary:stopAllActions()
		self.mary:runAction(cc.MoveTo:create(0.8,cc.p(val*1.8,0)))
		self.dog:stopAllActions()
		self.dog:runAction(cc.MoveTo:create(0.8,cc.p(100+val*1.6,0)))
	end
end

function addStage(self)
	self:setWinCenter()
end

function addArmatureFileInfo(self, exportJson)
	self.loader:addArmatureFileInfo(exportJson)
end

function start(self)
	self.loader:addEventListener(self.loader.Event.Load, onLoad, self)
	self.loader:start()
end

function onLoad(self, event)
	if event.etype == AsyncLoader.Event.Finish then
		self.story._ccnode:removeChild(self.mary)
		self.mary = nil
		self.story._ccnode:removeChild(self.terry)
		self.terry = nil
		local terry2mary = ccs.Armature:create("Loading")
		terry2mary:getAnimation():play('玛丽扑倒特瑞',-1,0)
		terry2mary:setPosition(300,0)
		terry2mary:setScaleX(-1)
		self.story._ccnode:addChild(terry2mary)
		terry2mary:getAnimation():setMovementEventCallFunc(
			function(armatureBack,movementType,movementID) 
				if movementType == ccs.MovementEventType.complete then
					Stage.addTimer(function() self:dispatchEvent(Event.Finish, {etype=Event.Finish}) end, 0.01, 1)
				end
			end
		)
		self.loader:removeEventListener(self.loader.Event.Load, onLoad)
	elseif event.etype == AsyncLoader.Event.OnLoad then
		self:setPercent(event.loadedIndex / event.resIndex * 100)
		self:storyRun(event.loadedIndex / event.resIndex * 100)
	end
end

function setBarString(self,val)
	self.loadLabel:setString(val)
	local x = self.loadLabel:getPositionX() - self.loadLabel:getContentSize().width/2 - 20
	self.flower:setPositionX(x)
end

function setPercent(self,val)
	if val < 97 then
		self.loadLight:setVisible(false)
	else
		self.loadLight:setVisible(true)
	end
	self.loadingBar:setPercent(val)
end

