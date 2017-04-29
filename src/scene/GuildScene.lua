module("GuildScene", package.seeall)
setmetatable(_M, {__index = MainScene}) 
local GuildFighter = require("src/modules/guild/ui/GuildFighter")
local BG_MAXPOSX = 0
local BG_SCALE = 64/75
START_POS = -1060

function new(isFightScene)
	--local scene = Scene.new("guild") 
	local scene = Scene.new("main") 
	setmetatable(scene, {__index = _M})
	scene.isFightScene = isFightScene
	scene:init()
	return scene
end

function addStage()
end

function init(self)
	self.touchEnabled = false
	self.loading = Control.new(require("res/master/MainLoadingSkin"),{"res/master/MainLoading.plist"})
	self:addChild(self.loading)
	self.loading:setScale(Stage.uiScale)
	self.loading:setPositionY(Stage.uiBottom)

	local res = {
	"res/map/guildBg1.png",
	"res/map/guildBg2.jpg",
	"res/master/MainUI.png",
	"res/master/GuildBg.png",
	}

	self.loading:openTimer()
	self.loading:addTimer(function(target,event) 
		local str = {"载入中.","..","..","..","..","..."} 
		local k = (100 - event.maxTimes) % (#str) + 1
		local msg = ""
		for i=1,k do
			msg = msg .. str[i]
		end
		self.loading.txtfree:setString(msg)
	end,0.05,100)

	local resCnt = #res
	for k,v in ipairs(res) do
		cc.Director:getInstance():getTextureCache():addImageAsync(v, function()
			if Stage.currentScene.name ~= "main" then return end
			--self.loading.txtfree:setString("Loading ... " .. 100 * (k+1) / resCnt .. "%")
			if k == resCnt then
				self:removeChild(self.loading)
				self:init2()
				self:addStage2()
				Stage.currentScene:addTimer(function() 
					self:dispatchEvent(Event.InitEnd) 
				end, 0.01, 1)
			end
		end)
	end
end

function addStage2()
end

function init2(self)
	self.touchEnabled = true
	self.master = Master.getInstance()
	self.bg1 = Sprite.new('guildBg1','res/map/guildBg1.png')
	--self.bg3 = Sprite.new('guildBg3','res/map/guildBg3.jpg')
	self.bg1:setScale(BG_SCALE)
	--self:addChild(self.bg3,-100)
	self:addChild(self.bg1,-100)
	local guildBg = require("src/modules/master/ui/GuildBg").new()
	self.bg1:addChild(guildBg)

	self.bg1:setPosition(START_POS+Stage.winSize.width/2,0)

	self.minPosX = Stage.width - self.bg1:getContentSize().width*BG_SCALE
	self.maxPosX = BG_MAXPOSX

	self.ui = require("src/modules/master/ui/MainUI").new()
	self.ui:setBtnState("guild")
	self:addChild(self.ui)

	self.touches = 0

	--场景人物
	self:loadGuildFighter()
	
	self:resetBtnTouch(self.bg1:getChild("GuildBg"))
	--self.bg:shader(Shader.SHADER_TYPE_BLUR, 0.0038, 0.0005)
	--self:shader(Shader.SHADER_TYPE_RELIEF,1800,1600)
	self:addTimer(playEffect, 0.1, 1)
	if not self.isFightScene then
		Network.sendMsg(PacketID.CG_GUILD_SCENE_ENTER)
	end
end

function loadGuildFighter(self)
	GuildFighter.new("Iori2",self.bg1)
end

function loadGuildGuide(self)
	if self.isFightScene then
		return
	end
	if Master.getInstance().guildCnt > 5 then
		return
	end
	self:addArmatureFrame("res/guild/effect/guide/GuildGuide.ExportJson")
	local cnt = 1
	local bone = Common.setBtnAnimation(self._ccnode,"GuildGuide","向右",{y=100})
	bone:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID) 
		if movementType == ccs.MovementEventType.complete then
			if cnt > 2 then
				bone:removeFromParent()
			else
				bone:getAnimation():play("向右",-1,-1)
				cnt = cnt + 1
			end
		end
	end)
end

function playEffect(self)
	--手指引导
	self:loadGuildGuide()

	local mapEffect = "GuildBuildings"
	local offsetX = 124
	local offsetY = 92
	self:addArmatureFrame("res/guild/effect/"..mapEffect..".ExportJson")
	local bone=ccs.Armature:create(mapEffect)
	local size = self.bg1:getContentSize()
	bone:setAnchorPoint(0.5,0.5)
	bone:setPosition(size.width / 2 + offsetX,size.height / 2+offsetY)
	bone:getAnimation():play(1)
	self.bg1._ccnode:addChild(bone)

	local bone2=ccs.Armature:create(mapEffect)
	bone2:setAnchorPoint(0.5,0.5)
	bone2:setPosition(size.width / 2 + offsetX,size.height / 2+offsetY)
	bone2:getAnimation():play(2)
	self.bg1._ccnode:addChild(bone2)
end


function touch(self, event)
	if self.touchEnabled then
		if event.etype == Event.Touch_began then
			self:touchBeganFuc(event)
		elseif event.etype == Event.Touch_ended or event.etype == Event.Touch_over then
			self.touches = self.touches - 1
		end
		
		local sceneChild = self:getTouchedChild(event.p)
		local hasTouchTarget = true
		if sceneChild then
			if sceneChild.name == "GuideMask" then
				hasTouchTarget = sceneChild:touch(event)
			elseif sceneChild.name == "TopTips" then
				sceneChild:touch(event)
				hasTouchTarget = false
			elseif sceneChild.name == "TopMasterLvUp" then
				sceneChild:touch(event)
				hasTouchTarget = false
			end
		end
		if hasTouchTarget == true then
			local child = getTouchedChild(self.ui, event.p)
			if child then
				child:touch(event)
			elseif self.ui.name == "MainUI" then
				self:onBgTouch(event)
			end
		end
	end
end

return GuildScene
