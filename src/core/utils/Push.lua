module(..., package.seeall) 

local classsName = "com/mxgame/util/Push"

function init(appId,channelId,isDebug)
	channelId = channelId or "0"
	isDebug = isDebug or false
	if Device.platform == "android" then
		local args = {tostring(appId),tostring(channelId),isDebug}
		LuaJ.callStaticMethod(classsName, "init" ,args)
	elseif Device.platform == "ios" then
		--LuaOC.callStaticMethod("Push","initPush",{appId="1100001040",channelId="0",isDebug=true})
		LuaOC.callStaticMethod("Push","initPush",{appId=appId,channelId=channelId,isDebug=isDebug})
	end
end

function startPush() 
	if Device.platform == "android" then
		LuaJ.callStaticMethod(classsName, "startPush" )
	elseif Device.platform == "ios" then
		LuaOC.callStaticMethod("Push","setPushSwitchState",{state=true})
	end
end

function stopPush()
	if Device.platform == "android" then
		LuaJ.callStaticMethod(classsName, "stopPush" )
	elseif Device.platform == "ios" then
		LuaOC.callStaticMethod("Push","setPushSwitchState",{state=false})
	end
end

function setAccount(account)
	if Device.platform == "android" then
		local args = {account}
		LuaJ.callStaticMethod(classsName, "setAccount" ,args)
	elseif Device.platform == "ios" then
		LuaOC.callStaticMethod("Push","setAccount",{account=account})
	end
end

function delAccount()
	if Device.platform == "android" then
		LuaJ.callStaticMethod(classsName, "delAccount" )
	elseif Device.platform == "ios" then
		LuaOC.callStaticMethod("Push","setAccount",{account=""})
	end
end

function setTags(tagList)
	local tagStr = ""
	for _,v in ipairs(tagList) do
		tagStr = tagStr .. v .. ","
	end
	tagStr = tagStr:sub(1,tagStr:len()-1)
	if Device.platform == "android" then
		local args = {tagStr}
		LuaJ.callStaticMethod(classsName, "setTags",args )
	elseif Device.platform == "ios" then
		local tags = {}
		for i,v in ipairs(tagList) do
			tags[tostring(i)] = v
		end
		LuaOC.callStaticMethod("Push","setTags",tags)
	end
end

function delTags(tagList)
	local tagStr = ""
	for _,v in ipairs(tagList) do
		tagStr = tagStr .. v .. ","
	end
	tagStr = tagStr:sub(1,tagStr:len()-1)
	if Device.platform == "android" then
		local args = {tagStr}
		LuaJ.callStaticMethod(classsName, "delTags",args )
	elseif Device.platform == "ios" then
		local tags = {}
		for i,v in ipairs(tagList) do
			tags[tostring(i)] = v
		end
		LuaOC.callStaticMethod("Push","deleteTags",tags)
	end
end

--@timeStr:"yyyy-MM-dd HH:mm:ss"
function setLocalTimer(id,title,content,timeStr,isTimeOutAvailable,customParam)
	isTimeOutAvailable = isTimeOutAvailable or false
	customParam = customParam or ""
	if Device.platform == "android" then
		local args = {title,content,timeStr,isTimeOutAvailable,customParam}
		LuaJ.callStaticMethod(classsName, "setLocalTimer" ,args)
	elseif Device.platform == "ios" then
		local args = {timeId=tostring(id),text=content,timeStr=timeStr}
		LuaOC.callStaticMethod("Push","localNotificationWithFireDate",args)
	end
end

function cancelLocalTimer(id,title,content,timeStr,customParam)
	customParam = customParam or ""
	if Device.platform == "android" then
		local args = {title,content,timeStr,customParam}
		LuaJ.callStaticMethod(classsName, "cancelLocalTimer" ,args)
	elseif Device.platform == "ios" then
		LuaOC.callStaticMethod("Push","cancelLocalNotificationWithKey",{timeId=id})
	end
end

function cancelAllLocalTimer()
	if Device.platform == "android" then
		return LuaJ.callStaticMethod(classsName, "cancelAllLocalTimer" )
	elseif Device.platform == "ios" then
		LuaOC.callStaticMethod("Push","cancelAllLocalNotifications")
	end
end

function setSilentTime(startHour,startMinute,endHour,endMinute)
	if Device.platform == "android" then
		local args = {startHour,startMinute,endHour,endMinute}
		return LuaJ.callStaticMethod(classsName, "setSilentTime" ,args)
	elseif Device.platform == "ios" then
		--assert(false)
	end
end

function delSilentTime()
	if Device.platform == "android" then
		return LuaJ.callStaticMethod(classsName, "delSilentTime" )
	elseif Device.platform == "ios" then
		--assert(false)
	end
end

function setAlarmTimer(id,title,content,hour,min)
	if Device.platform == "android" then
		local args = {id,title,content,hour,min}
		return LuaJ.callStaticMethod(classsName, "setAlarmTimer" ,args)
	elseif Device.platform == "ios" then
		local d = os.date("*t")
		local time = os.time({year=d.year,month=d.month,day=d.day,hour=hour,min=min,sec=0})
		local timeStr = os.date("%H:%M:%S",time)
		local args = {timeId=tostring(id),text=content,timeStr=timeStr}
		return LuaOC.callStaticMethod("Push","setAlarmNotification",args)
	end
end

function cancelAlarmTimer(id)
	if Device.platform == "android" then
		return LuaJ.callStaticMethod(classsName, "cancelAlarmTimer" ,{id})
	elseif Device.platform == "ios" then
		return LuaOC.callStaticMethod("Push","cancelAlarmNotification",{timeId=tostring(id)})
	end
end

function addNotify(id,title,content)
	if Device.platform == "android" then
		local args = {id,title,content}
		return LuaJ.callStaticMethod(classsName, "addNotify" ,args)
	elseif Device.platform == "ios" then
	end
end










