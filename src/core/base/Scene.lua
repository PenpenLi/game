module("Scene", package.seeall)
setmetatable(Scene, {__index = Control}) 
UI_SCENE_TYPE = "Scene"

isScene = true

function new(sceneName)
	local scene = { 
		name = sceneName,
		uiType = UI_SCENE_TYPE,
		_ccnode = cc.Scene:create(),
		isAsyncLoad = false,    --开启异步加载
		hasTouchEff = true,
	}
	setmetatable(scene, {__index = Scene})
	scene:setContentSize(Stage.winSize)
	scene:init()
	return scene
end

function init(self)
    local function onTouchBegan(touch, event)
        --[[
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        
        if cc.rectContainsPoint(rect, locationInNode) then
            print(string.format("sprite began... x = %f, y = %f", locationInNode.x, locationInNode.y))
            return true
        end
        return false
        --]]
        local p = touch:getLocation()
		self:touch({etype = Event.Touch_began, p = p, x = p.x, y = p.y})
		--print('====================bagan=========================')
		return true
    end

    local function onTouchMoved(touch, event)
        --[[
        local target = event:getCurrentTarget()
        local posX,posY = target:getPosition()
        local delta = touch:getDelta()
        --target:setPosition(cc.p(posX + delta.x, posY + delta.y))
        print('moved ======= delta.x,y:',delta.x,delta.y)
        --]]
        local p = touch:getLocation()
		self:touch({etype = Event.Touch_moved, p = p, x = p.x, y = p.y,delta = touch:getDelta()})
		--print('====================moved=========================')
		return true
    end

    local function onTouchEnded(touch, event)
        --[[
        local target = event:getCurrentTarget()
        print("ended ============onTouchesEnded..")
        --]]
        local p = touch:getLocation()
		self:touch({etype = Event.Touch_ended, p = p, x = p.x, y = p.y})
		--print('====================ended=========================')
		return true
    end

    local function onTouchCancel(touch,event)
        --print('================cancelled===================')
        local p = touch:getLocation()
		self:touch({etype = Event.Touch_over, p = p, x = p.x, y = p.y})
		--print('====================cancel=========================')
		return true
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    listener:registerScriptHandler(onTouchCancel,cc.Handler.EVENT_TOUCH_CANCELLED)

    local eventDispatcher = self._ccnode:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener,self._ccnode)
    
	if Device.platform ~= "ios" then
		self:openKeyboard()	
	end
	self:openTimer()
end

function playMusic(self)
end

function getUI(self)
	return self.ui or self
end

function openKeyboard(self)
	local function onKeyReleased(keyCode, event)
		if keyCode == cc.KeyCode.KEY_ESCAPE then
			if Stage.currentScene.name == "main" then
				UserSDK.exit()
			end
		end
		if Config.Debug then
			if keyCode == cc.KeyCode.KEY_R then
				restartGame()
			elseif keyCode == cc.KeyCode.KEY_T then
				Common.printTexInfo()
			elseif keyCode == cc.KeyCode.KEY_V then
				if Stage.currentScene.decHeroBHp then
					local scene = Stage.currentScene
					if not scene.heroB then
						return 
					end
					local hp = scene.heroB:getInfo():getHp()
					scene.heroB:decHp(hp)
				end
			elseif keyCode == cc.KeyCode.KEY_B then
				if Stage.currentScene.setHeroAHp then
					Stage.currentScene:setHeroAHp(0)
				end
			elseif keyCode == cc.KeyCode.KEY_G then
				Config.isGuideNil = true	
				if Stage.currentScene:getChild("GuideMask") then
					Stage.currentScene:removeChildByName("GuideMask")
				end
			end
		end
	end
	local listener = cc.EventListenerKeyboard:create()
	listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )

	local eventDispatcher = self._ccnode:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self._ccnode)
end

function openTouches(self)
    local function onTouchesBegan(touches, event)
        print('=============================touchs began:',#touches)
        --touches[1]:getLocation()
        self:onTouches({})
        return true
    end

    local function onTouchesEnd(touches, event)
        print('=============================touchs ended:',#touches)
    end

    local touchAllAtOnceListener = cc.EventListenerTouchAllAtOnce:create()
    touchAllAtOnceListener:registerScriptHandler(onTouchesBegan,cc.Handler.EVENT_TOUCHES_BEGAN )
    touchAllAtOnceListener:registerScriptHandler(onTouchesEnd,cc.Handler.EVENT_TOUCHES_ENDED )

    local eventDispatcher = self._ccnode:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(touchAllAtOnceListener, self._ccnode)
end

function preload(self)
end

function start(self)
	if Config.Debug then
		Common.showMemUsage(self)
		self:addTimer(Common.showMemUsage,1,-1)
		--self:addTimer(Common.printTexInfo,20,-1)
	end

end

function setAsyncLoad(self,isAsyncLoad)
	self.isAsyncLoad = isAsyncLoad
end

function clear(self)
	Control.clear(self)
	UIManager.reset()
	if GuideManager then
		GuideManager.clearAllModuleComponent()
	end
	--print("gc.count ",gc.count())
	--gc.collect()
	--print("gc.count ",gc.count())
end

function touch(self, event)
	if event.etype == Event.Touch_began then
		self:addTouchEff(event.p)
	end
	Control.touch(self, event)
end

function addTouchEff(self, p)
	--if self._ccnode and self.hasTouchEff == true then
	--	if self._ccnode:getChildByName("TouchEff") then
	--		self._ccnode:removeChildByName("TouchEff")
	--	end
	--	self:addArmatureFrame("res/armature/effect/TouchEff.ExportJson")
	--	local fingerEff = ccs.Armature:create("TouchEff")
	--	fingerEff:getAnimation():play('Animation1', -1, 0)
	--	fingerEff:getAnimation():setSpeedScale(3)
	--	fingerEff:setPosition(p.x, p.y)
	--	self._ccnode:addChild(fingerEff)
	--end
end
