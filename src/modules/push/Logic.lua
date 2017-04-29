module(...,package.seeall)
local Push = require("src/core/utils/Push")


function init(master)
	--appid
	Push.init(Config.PushAppId,Config.ChannelId,Config.Debug)
	--account
	master:addEventListener(Event.LoginSuccess,function(m) 
		Push.startPush()
		Push.setAccount(m.account)
	end)
end

function addLocalPush()
	local PushConfig = require("src/config/PushConfig").Config
	local master = Master.getInstance()
	Push.cancelAllLocalTimer()
	local settings = master:getPushSettings()
	for id,v in pairs(PushConfig) do
		if tonumber(v.isOpen) == 1 and master:getPushSettingById(id) then
			print("addLocalPush==>setAlarmTimer====>",id,v.title,v.content,v.hour,v.min)
			Push.setAlarmTimer(id,v.title,v.content,v.hour,v.min)
		end
	end
end




