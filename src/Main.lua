local host = 'localhost' -- please change localhost to your PC's IP for on-device debugging
--require('src/mobdebug').start(host)

trace = function(...)
    print(string.format(...))
end
require("src/init")
--trace = function() end
--[[
print = function(...)
end
--]]

-- 程序启动
function main()
	-- avoid memory leak
	collectgarbage("setpause", 100) 
	collectgarbage("setstepmul", 5000)

	--初始化随机种子
	math.randomseed(os.time())

	cc.Director:getInstance():setDisplayStats(Config.Debug)

	Network.init()
	Stage.init(540, 960) -- ipad 4:3
	--Stage.init(1136, 640) -- ip5 16:9
	
	--SDK
	UserSDK.init()
	
	--local isRestart = cc.UserDefault:getInstance():getBoolForKey("isRestart",false)
	--cc.UserDefault:getInstance():setBoolForKey("isRestart",false)
	--local scene
	--if isRestart then
	--	scene = require("src/scene/LoginScene").new()
	--else
	--	scene = require("src/scene/LogoScene").new()
	--end
	local scene = require("src/scene/FaceScene").new()
	--local scene = require("src/scene/LoginScene").new()
	--local scene = require("src/scene/FightScene").new()
	--local scene = require("src/scene/MainScene").new()
	--scene = require("src/scene/TestScene").new()
	--local scene = require("src/scene/LeakScene").new()
	if cc.Director:getInstance():getRunningScene() then 
		Stage.replaceScene(scene)
	else
		Stage.runWithScene(scene)
	end
end

function restartGame()
	print("restartGame=================>")
	AudioEngine.stopMusic(true)
	local userDefault = cc.UserDefault:getInstance()
	userDefault:setBoolForKey("isRestart",true)
	userDefault:flush()
	if Master then
		Master.getInstance():release()
	end
	Stage.closeTimer()
	_restart()
end

function enterForeground()
	if Stage.currentScene then
		AudioEngine.pauseMusic()
		Stage.addTimer(function() 
			AudioEngine.resumeMusic()
		end, 2, 1)
	end

	if Master and Master.getInstance():enterForeground() then
		return
	end
	--检查版本
	--[[
	if Config.CheckVersion then
		local downer = AsyncDownloadManager.getInstance()
		if not downer.isWorking then
			local check = function(self,event) 
				if event.etype == AsyncDownloadManager.Event.newVersion then
					--local tips = TipsUI.showTips("有新版本，是否立刻更新?")
					local tips = TipsUI.showTopTips("有新版本，是否立刻更新?")
					tips:addEventListener(Event.Confirm,function(self,event) 
						if event.etype == Event.Confirm_yes then
							restartGame()
						end
					end)
				end
			end
			downer:removeEventListener(AsyncDownloadManager.Event.needUpdate,check)
			downer:addEventListener(AsyncDownloadManager.Event.needUpdate,check)
			downer:checkVersion()
		end
	end
	--]]
end

function enterBackground()
	if Master then
		Master.getInstance():enterBackground()
	end
	AudioEngine.pauseMusic()
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
	local errMsg = "LUA ERROR: " .. tostring(msg) .. "\n"
	errMsg = errMsg .. debug.traceback()
	trace("----------------------------------------")
	trace(errMsg)
	trace("----------------------------------------")
	if Config.Debug then
		if not UIManager.getUI("Rule") then
			local ui = UIManager.addUI("src/ui/RuleUI")
			ui:setTitle("报错")
			ui:setContent(errMsg)
		end
	end
	--report
	if Config.ReportURL and Config.ReportURL:len() > 0 then
		local ver = Device.getFullVersion() 
		local msg = Common.urlEncode(string.format("[%s][%s][%s]%s",ver,Config.PlatformName,os.date("%X"),errMsg))
		local xhr = cc.XMLHttpRequest:new()
		local time = os.time()
		local url = string.format("%s?c=%s&t=%d&s=%s",Config.ReportURL,msg,time,Common.cUtil():MD5(time .. Config.ReportKey))
		xhr:open("GET", url)
		xhr:send()
	end
end

xpcall(main, __G__TRACKBACK__)



