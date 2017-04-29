module(...,package.seeall)

local MasterDefine = require("src/modules/master/MasterDefine")
local PushLogic = require("src/modules/push/Logic")


function onGCAskLogin(result,account,name,svrName,token,isNew,msvrIP,msvrPort)
	print("onGCAskLogin>>>>>>",result,svrName)
	if result == MasterDefine.OK then
		local master = Master.getInstance() 
		if master.isRelogin then
			master:onReLogin()
			return
		end
		master:onLogin(result,account,name,token)
		UserSDK.enterGamerServer()
		--StatisSDK.setPlayerInfo(account,name,0,1,,0)
		StatisSDK.setPlayerInfo(master.account,master.name,StatisSDK.Account_type_register,master.lv,0,StatisSDK.Gender_male,Config.SvrId)
		StatisSDK.onEvent(StatisSDK.Event_LoginOK)
		if isNew == 1 then
			UserSDK.createRole()
		end
		if isNew == 1 and Config.isGuideNil == nil then 
			startMovie()
		else
			--[[
			local scene = require("src/scene/MainScene").new()
			Stage.replaceScene(scene)
			scene:addEventListener(Event.InitEnd, function()
				GuideManager.triggerGuide()
			end)
			--]]
		end
	else
		TipsUI.showTipsOnlyConfirm(MasterDefine.ASK_LOGIN_ERR_MSG[result] or "登录失败")
	end
end

function onGCHumanInfo(info)
	local master = Master.getInstance()
	master:refreshInfo(info)
end

--断线
function onGCDisconnect(reason)
	--Common.showMsg("断线了!")
	--@todo master是否已退出?
	Master.getInstance():onDisconnect(reason)
end

function onGCReLogin()
	Master.getInstance():onReLogin()
end

function onGCRename(ret,name)
	if ret == MasterDefine.OK then
		if  Master.getInstance().name:len() < 1 then
			--创角
			UIManager.removeUI(UIManager.getUI("Name"))
		end
		Master.getInstance().name = name
		Master.getInstance():refreshInfo()
	else
		if ret == MasterDefine.RET_NAME_NORMB then
			Common.showRechargeTips()
		else
			local ui = UIManager.getUI("Name")
			if ui then
				ui:showTip(MasterDefine.RET_NAME_TXT[ret])
			end
		end
	end
	local ui = Stage.currentScene:getUI():getChild("Setting")
	if ui then
		ui:onFinishRename(ret == MasterDefine.OK,MasterDefine.RET_NAME_TXT[ret])
	end
end

function onGCChangeBody(ret,bodyId)
	if ret == MasterDefine.OK then
		Common.showMsg("成功更换头像")
		Master.getInstance().bodyId = bodyId
		Master.getInstance():refreshInfo()
		local ui = Stage.currentScene:getUI():getChild("Setting")
		if ui then
			ui:onFinishChkBody()
		end
	end
end

function onGCSettings(music,effect,pushSettings)
	local master = Master.getInstance()
	master.settings.music = music == 1
	master.settings.effect = effect == 1
	for _,v in pairs(pushSettings) do
		if v.isOpen == nil then v.isOpen = true end
		master.settings.pushSettings[v.id] = v.isOpen == 1
	end
	PushLogic.addLocalPush()
	AudioEngine.setMusicOn(master:isMusicON())
	AudioEngine.setEffectOn(master:isEffectON())
end

function onGCError(errMsg)
	if Config.Debug then
		local ui = UIManager.addUI("src/ui/RuleUI")
		ui:setTitle("后端报错")
		ui:setContent(errMsg)
	end
end

function onGCAddPhysics(phy,time)
	Master.getInstance():onTimerAddPhy(phy,time)
end

--开场分镜
function startMovie()
	Stage.currentScene:removeAllChildren()
	Stage.currentScene:addArmatureFrame("res/start/GameStart.ExportJson")
	local bone = ccs.Armature:create("GameStart")
	bone:getAnimation():play("dong",-1,-1)
	bone:setAnchorPoint(0.5,0.5)
	bone:setPosition(Stage.width/2,Stage.height/2)
	Stage.currentScene._ccnode:addChild(bone)

	local b = bone:getBone("bj1")
	for i =1,3 do
		local skin = ccs.Skin:create(string.format("res/start/bj%s.jpg",i))
		b:addDisplay(skin, i-1)
	end

	AudioEngine.stopMusic(true, true)
	AudioEngine.playMusic(string.format("res/sound/loginScene/StartMusic.mp3"))

	bone:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID) 
		if movementType == ccs.MovementEventType.complete then
			AudioEngine.stopMusic()
			if GuideManager.hasFinishGuide(GuideDefine.GUIDE_FIGHT_SCENE) == true then
				local scene = require("src/scene/MainScene").new()
				Stage.replaceScene(scene)
				scene:addEventListener(Event.InitEnd, function()
					GuideManager.triggerGuide()
				end)
			else
				GuideManager.triggerGuide()
			end
		end
	end)

	local btn = Control.new(require("res/start/JumpStartSkin"), {"res/start/JumpStart.plist"})
	btn:setPosition(Stage.width - btn:getContentSize().width - 50, 50)
	Stage.currentScene:addChild(btn)
	btn:addEventListener(Event.TouchEvent, function(listener, evt)
		if evt.etype == Event.Touch_ended then
			AudioEngine.stopMusic()
			if GuideManager.hasFinishGuide(GuideDefine.GUIDE_FIGHT_SCENE) == true then
				local scene = require("src/scene/MainScene").new()
				Stage.replaceScene(scene)
				scene:addEventListener(Event.InitEnd, function()
					GuideManager.triggerGuide()
				end)
			else
				GuideManager.triggerGuide()
			end
		end
	end)

end

function onGCKick(reason)
	WaittingUI.cleanup()
	if Master then
		Master.getInstance():release()
	end
	local msg = MasterDefine.DISCONNECT_REASON_TXT[reason] or "被服务器踢下线"
	local tips = TipsUI.showTopTipsOnlyConfirm(msg)
	tips:addEventListener(Event.Confirm,function(self,event) 
		if event.etype == Event.Confirm_known then
			restartGame()
		end
	end)
end

function onGCLoginAuth(authKey)
	local master = Master.getInstance()
	master.authKey = authKey
	coroutine.resume(master.loginCo)
end

function onGCGiftCode(ret,msg)
	if ret == 0 then
	else
		local tips = TipsUI.showTopTipsOnlyConfirm(msg)
		tips:addEventListener(Event.Confirm,function(self,event) 
			if event.etype == Event.Confirm_known then
			end
		end)
	end
end


