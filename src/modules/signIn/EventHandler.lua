module(...,package.seeall)
local SignIn = require("src/modules/signIn/SignIn")
local SignInConfig = require("src/config/SignInActivityConfig").Config

function onGCSignInInfo(month, info)
	Common.printR(info)
	SignIn.setInfo(month, info)
	local ui = Stage.currentScene:getUI():getChild("SignIn")
	if ui then
		ui.frameN = 1
		ui:openTimer()
		local mainUI = require("src/modules/master/ui/MainUI").Instance
		if mainUI then
			Dot.check(mainUI.mainBtn1.register,"signInRefresh")
		end
	end
end

function onGCSignIn(ret)
	if ret == 0 then
		--Common.showMsg("成功领取签到奖励！")
	elseif ret == 1 then
		Common.showMsg("签到奖励已经领取了，无法重复领取")
	end
end
