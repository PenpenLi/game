module("Stage", package.seeall)
setmetatable(DisplayObject, {__index = EventDispatcher}) 
-- currentScene = currentScene or nil
currentScene = nil
isStage = true
_timerNow = 0 
width = width or 1024-- 舞台宽
height = height or 768 -- 舞台高 
scale = scale or 1 -- 舞台缩放系数 
uiScale = uiScale or 1 -- ui缩放系数(16:9设计ui) 
uiBottom = uiBottom or 0 --ui底边距

view = view or nil
--设备宽高
frameSize = frameSize or nil
--设计宽高 
designSize = designSize or nil 
--窗口宽高 
winSize = winSize or nil 
StageTimerId = 0
function init(designWidth, designHeight)
	view = cc.Director:getInstance():getOpenGLView()
	frameSize = view:getFrameSize() 
	trace("frameSize:" .. frameSize.width .. "," .. frameSize.height) 

	designSize = cc.size(designWidth, designHeight) 
	trace("designSize:" .. designSize.width .. "," .. designSize.height) 

	local ResolutionPolicy = 
	{
		ExactFit = 0, -- 全屏拉伸
		NoBorder = 1, -- 锁定比例，多出的会裁切,无黑边 
		ShowAll = 2, -- 锁定比例，全部呈现，有黑边
		FixedHeight = 3, --锁定比例，保证高度，会有宽度的黑边或者裁切
		FixedWidth = 4, --锁定比例，保证宽度，会有高度的黑边或者裁切
		UnKnown = 5,
	}
	--屏幕拉伸匹配
	view:setDesignResolutionSize(designSize.width, designSize.height, 
		ResolutionPolicy.FixedHeight) -- 场景匹配高度，等比缩放

	winSize = cc.size(designSize.height / frameSize.height  * frameSize.width, designSize.height) 
	trace("winSize:" .. winSize.width .."," .. winSize.height) 

	width = winSize.width
	height = winSize.height

	scale = frameSize.height / designSize.height 
	trace("scale:" .. scale) 
	
	uiScale = width / designSize.width -- 匹配宽度时的ui缩放系数 
	uiBottom = (640 - 480 * uiScale) / 2  -- 上下居中时ui底边距(适配 480*854 等宽ui在640等高场景的情况)
	trace("uiScale:" .. uiScale .. "    uiBottom:" .. uiBottom)
	Stage.openTimer()
end

function runWithScene(scene)
	currentScene = scene
	currentScene._parent = Stage
	currentScene:addStage()
	cc.Director:getInstance():runWithScene(scene._ccnode)
	currentScene:start()
	-- currentScene:openTimer()
	-- currentScene:addEventListener(Event.Frame,Stage.onTimerCallBack,Stage)
end

function replaceScene(scene)
	local s = os.clock()
    if currentScene then
	    currentScene._parent = nil 
		currentScene.touchEnabled = false
	    currentScene:clear() --原场景释放资源
    end

	cc.Director:getInstance():replaceScene(scene._ccnode)

	collectgarbage( "collect" ) 
	currentScene = scene
	currentScene._parent = Stage
	currentScene:addStage()
	currentScene:preload()
	if currentScene.isAsyncLoad then
		require("script/common/LoadingControl").new(function() 
			currentScene:start()
		end)
	else
		currentScene:start()
	end
	-- currentScene:openTimer()

	-- currentScene:addEventListener(Event.Frame,Stage.onTimerCallBack,Stage)

	--cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames() 
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
	if Master then
		Master.getInstance():dispatchEvent(Event.EnterScene)
	end


	print("=====>tick Stage replaceScene: ",currentScene.name, os.clock() - s)
end

-- function addTimer(func, interval, maxTimes, listener)
-- 	return DisplayObject.addTimer(Stage,func, interval, maxTimes, listener)
-- end

-- function delTimer(timer)
-- 	DisplayObject.delTimer(Stage,timer)
-- end

-- function onTimerCallBack(self, event)
-- 	DisplayObject.onTimerCallBack(self, event.delay)
-- end

function addTimer(func, interval, maxTimes, listener)
	assert(interval > 0)
	assert(maxTimes > 0 or maxTimes == -1)
	if not Stage._timerEvents then
		Stage._timerEvents = {}
	end
	local timer = {listener = listener or Stage, interval = interval, maxTimes = maxTimes}
	local now = Stage._timerNow or 0
	timer.nextCall = now + interval
	Stage._timerEvents[func] = timer
	return timer 
end

function delTimer(timer)
	for func,v in pairs(Stage._timerEvents) do
		if timer == v then
			Stage._timerEvents[func] = nil
			return 
		end
	end
end

function onTimerCallBack(delay)
	Stage._timerNow = Stage._timerNow + delay 
	if Stage._timerEvents then
		local clearTable = {}
		for func, ev in pairs(Stage._timerEvents) do
			if ev.maxTimes == 0 then -- 容错，防止func执行报错后计时器没被移除
				table.insert(clearTable,func)
			elseif ev.nextCall <= Stage._timerNow then
				--ev.nextCall = self._timerNow + ev.interval
				ev.nextCall = ev.nextCall + ev.interval
				ev.maxTimes = ev.maxTimes - 1
				if ev.maxTimes == 0 then
					table.insert(clearTable,func)
				end
				func(ev.listener, ev, Stage)--千万注意不要在回调事件里面干掉事件容器self
			end
		end
		for _,func in ipairs(clearTable) do 
			Stage._timerEvents[func] = nil
		end
	end
end

local evFrame = {etype = Event.Frame, target = nil, delay=1}
function onFrameCallBack( delay)
	evFrame.target = Stage
	evFrame.delay = delay 
	EventDispatcher.dispatchEvent(Stage, Event.Frame, evFrame)
	onTimerCallBack( delay)
end

function stageCallback(delay) 
	return onFrameCallBack(delay) 
end

function openTimer()
	Stage._timerNow = Stage._timerNow or 0
	local scheduler = cc.Director:getInstance():getScheduler()
	local a = StageTimerId
	StageTimerId = scheduler:scheduleScriptFunc(stageCallback, 0, false)
end

function closeTimer()
	local scheduler = cc.Director:getInstance():getScheduler()
    scheduler:unscheduleScriptEntry(StageTimerId)
	Stage._timerNow = 0
	Stage._timerEvents = {} 
end






