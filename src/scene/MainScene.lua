module("MainScene", package.seeall)
setmetatable(_M, {__index = Scene}) 
local Announce = require("src/modules/announce/Announce")

local LAST_CLICK_NUM = 5 	--记录最近点击
local BG2_MOVE_FACTOR = 0.73 --X轴滑动背景2相对背景1的比例
local BG3_MOVE_FACTOR = 0.3 --X轴滑动背景3相对背景1的比例
local END_MOVE_FACTOR = 3	--结束后滑动因子
local MOVE_TIME_OUT = 0.4	--结束后滑动超时时间
local BG_MAXPOSX = 0
--local BG1_BASE_POSX = -60+BG_MAXPOSX	--背景1初始X
--local BG1_BASE_POSX = -1300 + Stage.winSize.width
local BG1_BASE_POSX = 0
local BG2_BASE_POSX = BG_MAXPOSX	--背景2初始X
local BG2_BASE_POSY = 0 --背景2初始Y
local BG3_BASE_POSX = -204+BG_MAXPOSX	--背景3初始X
local BG_SCALE = 1

function new()
	local s = os.clock()
	local scene = Scene.new("main") 
	setmetatable(scene, {__index = _M})
	scene:init()
	print("=====>tick init MainScene: ",os.clock() - s)
	return scene
end

function addStage2(self)
	self:playMusic()
	local mainBg = self.bg1:getChild("MainBg")
	local mainBg2 = self.bg2:getChild("MainBg2")
	mainBg:loadSceneFinish()
	mainBg2:loadSceneFinish()
	self.ui:loadSceneFinish()

	if self.master.name:len() < 1 then
		UIManager.addUI("src/modules/master/ui/NameUI")
	else
		Announce.showLoginAnnounce()
	end
	self:addEventListener(Event.InitEnd, function()
		self.master:showLvUp()
	end)
	--UIManager.addUI("src/modules/orochi/ui/SettlementUI",1,1,10,nil,true)
end

function playMusic(self)
	AudioEngine.playMusic(string.format("res/sound/mainScene/BackgroundMusic1.mp3"), true)
	AudioEngine.setEffectOn(Master.getInstance():isEffectON())
end

function preload(self)
end

function clear(self)
	AudioEngine.stopMusic()
	Scene.clear(self)
end

function init(self)
	self:addArmatureFrame("res/master/effect/BuildBlink.ExportJson")
	self.touchEnabled = false
	self.loading = Control.new(require("res/master/MainLoadingSkin"),{"res/master/MainLoading.plist"})
	self:addChild(self.loading)
	self.loading:setScale(Stage.uiScale)
	self.loading:setPositionY(Stage.uiBottom)

	local res = {
	"res/map/mainBg1.png",
	--"res/map/mainBg2.jpg",
	"res/master/MainUI.png",
	"res/master/MainBg.png",
	"res/master/MainBg2.png",
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
				--Stage.currentScene:addTimer(function() 
					self:dispatchEvent(Event.InitEnd) 
				--end, 0.01, 1)
			end
		end)
	end
end

function init2(self)
	self.touchEnabled = true
	self.master = Master.getInstance()
	self.bg1 = Sprite.new('mainBg1','res/map/mainBg1.png')
	self.bg2 = Sprite.new('maingBg2')
	--self.bg3 = Sprite.new('mainBg3','res/map/mainBg3.jpg')
	self.bg1:setScale(BG_SCALE)
	self.bg1:setPosition(BG1_BASE_POSX,0)
	self.bg2:setPosition(BG2_BASE_POSX,BG2_BASE_POSY)
	--self.bg3:setPosition(BG3_BASE_POSX,0)
	--self:addChild(self.bg3,-100)
	self:addChild(self.bg2,-100)
	self:addChild(self.bg1,-100)
	local mainBg = require("src/modules/master/ui/MainBg").new()
	self.bg1:addChild(mainBg)
	local mainBg2 = require("src/modules/master/ui/MainBg2").new()
	self.bg2:addChild(mainBg2)

	self.minPosX = Stage.width - self.bg1:getContentSize().width*BG_SCALE
	self.maxPosX = BG_MAXPOSX

	self.ui = require("src/modules/master/ui/MainUI").new()
	self:addChild(self.ui)

	self.touches = 0

	self:resetBtnTouch()
	self:resetBtnTouch(mainBg2)
	--self.bg:shader(Shader.SHADER_TYPE_BLUR, 0.0038, 0.0005)
	--self:shader(Shader.SHADER_TYPE_RELIEF,1800,1600)
	
	self:addTimer(playEffect, 0.1, 1)
end

function playEffect(self)
	self:addArmatureFrame("res/master/effect/MainBg.ExportJson")
	Common.setBtnAnimation(self.bg1._ccnode,"MainBg","weapon",{y=230})

	local mainBg2 = self.bg2:getChild("MainBg2")
	Common.setBtnAnimation(mainBg2._ccnode,"MainBg","wave",{x=-150})
	Common.setBtnAnimation(mainBg2._ccnode,"MainBg","cloud")
end

function playEffect2(self)
	local mapEffect = "Buildings"
	local offsetX = 87
	local offsetY = 90
	self:addArmatureFrame("res/armature/effect/"..mapEffect..".ExportJson")
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

	local bone3=ccs.Armature:create(mapEffect)
	bone3:setAnchorPoint(0.5,0.5)
	bone3:setPosition(size.width / 2 + offsetX,size.height / 2+offsetY)
	bone3:getAnimation():play(3)
	self.bg1._ccnode:addChild(bone3)
end

function touch(self, event)
	if self.touchEnabled then
		if event.etype == Event.Touch_began then
			self:touchBeganFuc(event)
		--elseif event.etype == Event.Touch_ended 
		--	or event.etype == Event.Touch_over 
		--	or event.etype == Event.Touch_cancelled
		--	or event.etype == Event.Touch_out
		--	then
		elseif event.etype == Event.Touch_moved then
		else
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
			elseif sceneChild.gname == "TopWaitting" then
				sceneChild:touch(event)
				hasTouchTarget = false
			end
		end
		if event.p.x > Stage.width or event.p.y > Stage.height then
			--未知原因，可能触发
			hasTouchTarget = false
		end
		if hasTouchTarget == true then
			local child = getTouchedChild(self.ui, event.p)
			if child then
				if self._lastTouch and self._lastTouch ~= child and self._lastTouch.alive then
					local ev = {etype=Event.Touch_out, x=event.x, y=event.y, p=event.p}
					self._lastTouch:touch(ev)
				end
				self._lastTouch = child
				child:touch(event)
				self.lastPos = {}
			elseif self.ui.name == "MainUI" then
				if self._lastTouch and self._lastTouch.alive then
					local ev = {etype=Event.Touch_out, x=event.x, y=event.y, p=event.p}
					self._lastTouch:touch(ev)
					self._lastTouch = nil
				end
				self:onBgTouch(event)
			end
		end
		if event.etype == Event.Touch_ended then
			self:addTouchEff(event.p)
		end
	end
end

function resetBtnTouch(self,mainBg)
	local mainBg = mainBg or self.bg1:getChild("MainBg")
	for k,v in ipairs(mainBg._children) do
		v:openTimer()
		v.touch = function(btn,event)
			if event.etype == Event.Touch_began then
				self.beganBtn = btn 
				btn.timer = btn:addTimer(function(self,evt) 
					btn:onTouchEvent({etype=Event.Touch_began})
				end,0.2,1,self)
			elseif event.etype == Event.Touch_moved then
				if math.abs(event.delta.x) > 5 or math.abs(event.delta.y) > 5 then
					self.beganBtn = nil
					btn:onTouchEvent({etype=Event.Touch_out})
					if btn.timer then
						btn:delTimer(btn.timer)
						btn.timer = nil
					end
				else
					btn:onTouchEvent(event)
				end
			elseif event.etype == Event.Touch_ended then
				if btn.timer then
					btn:delTimer(btn.timer)
					btn.timer = nil
				end
				btn:onTouchEvent(event)
				if self.beganBtn == btn then
					self.beganBtn = nil
					btn:dispatchEvent(Event.Click,{etype=Event.Click, x=event.x, y=event.y, p=event.p})
				end
			end
		end
	end
end

function onBgTouch(self, evt)
	ItemTips.hide()
	local btnLayer = getTouchedChild(self.bg1, evt.p)
	if btnLayer then
		local child = getTouchedChild(btnLayer,evt.p)
		if child then
			child:touch(evt)
		else
			if self.bg2 then
				local btnLayer2 = getTouchedChild(self.bg2, evt.p)
				if btnLayer2 then
					local child2 = getTouchedChild(btnLayer2,evt.p)
					if child2 then
						child2:touch(evt)
					end
				end
			end
		end
	end
	if self.bg1 and self.bg1.alive then
		if evt.etype == Event.Touch_began then
			--self:touchBeganFuc(evt)
		elseif evt.etype == Event.Touch_moved then
			self:touchMovedFuc(evt)	
		elseif evt.etype == Event.Touch_ended then
			self:touchEndedFuc(evt)
		end
	end
end

function touchBeganFuc(self,event)
	self.touches = self.touches + 1
	self.lastPos = {}
	self:bgStopAction()
end

function touchMovedFuc(self,event)
	if self.touches > 1 then
		return
	end
	self.lastPos = self.lastPos or {}
	table.insert(self.lastPos,{x = event.x,t = os.clock()})
	if #self.lastPos <= 1 then
		return
	end
	if #self.lastPos > LAST_CLICK_NUM then
		table.remove(self.lastPos,1)
	end
	local diffX = self.lastPos[#self.lastPos].x - self.lastPos[#self.lastPos-1].x
	local curX = diffX + self.bg1:getPositionX()
	if curX >= self.minPosX and curX <= self.maxPosX then
		self.bg1:setPositionX(curX)
		if self.bg2 then
			self.bg2:setPositionX(self.bg2:getPositionX()+diffX*BG2_MOVE_FACTOR)
		end
		if self.bg3 then
			self.bg3:setPositionX(self.bg3:getPositionX()+diffX*BG3_MOVE_FACTOR)
		end
	end
end

function touchEndedFuc(self,event)
	if not self.lastPos or #self.lastPos <= 1 then
		return
	end
	local diffX = (event.x-self.lastPos[1].x)*END_MOVE_FACTOR
	local diffT = os.clock() - self.lastPos[1].t
	if diffT > MOVE_TIME_OUT then
		return
	end
	local destX = self.bg1:getPositionX()+ diffX
	destX = math.max(self.minPosX,destX)
	destX = math.min(self.maxPosX,destX)
	local dis = destX - self.bg1:getPositionX()
	self:bgFollowMove(dis,diffT)
	self.lastPos = nil
end

function bgStopAction(self)
	self.bg1:stopAllActions()
	if self.bg2 then
		self.bg2:stopAllActions()
	end
	if self.bg3 then
		self.bg3:stopAllActions()
	end
end

function bgFollowMove(self,dis,time)
	followMove(self.bg1,dis,time)
	if self.bg2 then
		followMove(self.bg2,dis*BG2_MOVE_FACTOR,time)
	end
	if self.bg3 then
		followMove(self.bg3,dis*BG3_MOVE_FACTOR,time)
	end
end

function followMove(bg,dis,time)
	local action = cc.MoveBy:create(0.8,cc.p(dis,0))
	local sineOut = cc.EaseSineOut:create(action)
	bg:runAction(sineOut)
end

function moveBg(self, dis)
	self.bg1:setPosition(dis,0)
	self.bg2:setPosition(BG2_BASE_POSX+dis*BG2_MOVE_FACTOR,BG2_BASE_POSY)
end

function setSceneRight(self)
	local dis = self.minPosX
	self.bg1:setPosition(dis,0)
	self.bg2:setPosition(BG2_BASE_POSX+dis*BG2_MOVE_FACTOR,BG2_BASE_POSY)
	--self.bg3:setPosition(BG3_BASE_POSX+dis*BG3_MOVE_FACTOR,0)
end

return MainScene
