module("ObjHuman", package.seeall)
setmetatable(ObjHuman, {__index = Object}) 
local RechargeDB = require("modules.recharge.RechargeDB")

TYPE_HUMAN = "human"

local ObjectManager = require("core.managers.ObjectManager")
local Msg = require("core.net.Msg")
local Json = require("core.utils.Json")
local Util = require("core.utils.Util")
local PacketID = require("PacketID")
local CommonDefine = require("core.base.CommonDefine")

local CharDB = require("modules.character.CharDB")
local Character = require("modules.character.Character")
local CharacterDefine = require("modules.character.CharacterDefine")

function new(fd, sn)
    local human = {
		id = ObjectManager.newId(),
		otype = TYPE_HUMAN,
		typeId = ObjectManager.OBJ_TYPE_HUMAN,
		fd = fd, 
		sn = sn,
		timerList = {},
		token = nil,		--登录序列
		reloginTimer = nil,

		--人物基本消息
		infoMsg = {},
	}

	setmetatable(human, {__index = ObjHuman})
	ObjectManager.add(human)
    human.db = CharDB.new()
	human:init()

    return human 
end

function init(self)
end

function sendHumanInfo(self)
	local msg = {}
	msg.name = self.name
	msg.timeServer = os.time()
	msg.createDate = self.db.createDate
	msg.money = self.db.money
	msg.rmb = self.db.rmb
	local sendMsg = {}
	if next(self.infoMsg) then
		for k,v in pairs(msg) do
			if not self.infoMsg[k] or self.infoMsg[k] ~= v then
				sendMsg[k] = v
			end
		end
	else
		sendMsg = msg
	end
	self.infoMsg = msg
	if next(sendMsg) then
    	Msg.SendMsg(PacketID.GC_HUMAN_INFO,self,sendMsg)
	end
end

function sendSettings(self)
	local settings = self.db.settings
	Msg.SendMsg(PacketID.GC_SETTINGS,self,settings.music,settings.effect,settings.pushSettings)
end

function resetMeta(self) 
	setmetatable(self, {__index = ObjHuman})
    self.db:resetMeta();
end

function load(self, account )
    local ret = self.db:loadByAccount(account)
	HumanManager:dispatchEvent(HumanManager.Event_HumanDBLoad,self)
    return ret
end

function addTimer(self,timer)
	self.timerList[#self.timerList+1] = timer 
end

function stopTimer(self)
	for _,timer in pairs(self.timerList) do
		--@todo 设置了maxtimes的timer可能已停止
		--maxtimes跑完前玩家已释放
		timer:stop()
	end
	self:stopReloginTimer()
end

function disconnect(self, reason )
	print("ObjHuman:disconnect")
	--服务端不主动断开
    --Character.sendGCDisconnect(self)  
	Msg.SendMsg(PacketID.GC_KICK,self,reason)
	self:release(reason)
end

function exit(self)
	self:disconnect(Define.DISCONNECT_REASON_SERVER_CLOSE)
end

function startReloginTimer(self)
	self:stopReloginTimer()
	self.reloginTimer = Timer.new(CharacterDefine.TIMER_RE_LOGIN_TIMEOUT,1)
	self.reloginTimer:setRunner(onCheckReLogin,self)
	self.reloginTimer:start()
end

function stopReloginTimer(self)
	if self.reloginTimer then
		self.reloginTimer:stop()
		self.reloginTimer = nil
	end
end

function onDisconnect(self,reason)
	--重新登录
	--断线重连
	--玩家主动断开,还是会保持？
	--c++层已释放fd
	ObjectManager.removeFd(self)
	HumanManager:dispatchEvent(HumanManager.Event_HumanDisconnect, self)
	if true or reason == CommonDefine.DISCONNECT_REASON_TIMEOUT then
		self:startReloginTimer()
	else
		--self:release(reason)
	end
end

function onCheckReLogin(self)
	--有效时间内重新连上
	if not self.fd then
		self:release()
	end
end

function release(self, reason)
	self:stopTimer()
	ObjectManager.remove(self)
	HumanManager.delOnline(self.db.account)
	
    self.db.lastLogout = os.time()
    local aliveTime = self.db.lastLogout - self:getLoginTime()
    self.db.olDayTime = self.db.olDayTime+aliveTime
    self.db.olTime = self.db.olTime+aliveTime
    self.db.isOnline = 0
    self:save()
end

function save(self,isSync)
	self.db.lastSaveTime = os.time()
	local ret = self.db:save(isSync)
    print("ObjHuman save ok:", self:getAccount())
    return ret
end

function getAccumulateDays(self)
    return self.db.accumulateDays
end

function incAccumulateDays(self)
    self.db.accumulateDays = self.db.accumulateDays + 1
end

function getLoginTime(self)
    return self.db.lastLogin
end

function setSvrName(self,svrName)
    self.db.svrName = svrName
end

function getSvrName(self)
    return self.db.svrName
end

function setAccount(self,account)
    self.db.account = account
end

function getAccount(self)
	return self.db.account 
end

function getPAccount(self)
	return self.db.pAccount 
end


function setName(self,name)
	self.db.name = name
end

function getName(self)
	return self.db.name
end

function getToken(self,token)
	return self.token
end

function setToken(self,token)
	self.token = token
end

function addUser(self)
    return self.db:add()
end

function getSex(self)
	return self.db.sex
end

function setSex(self,val)
	self.db.sex = val
end

function getMoney(self)
	return self.db.money
end

function incMoney(self,val,way)
	assert(val >= 0,"error incMoney======>>>" .. val)
	assert(way,"error need way!!!!")
	self.db.money = self.db.money + val
	HumanManager:dispatchEvent(HumanManager.Event_HumanMoneySumChange,{human=self})
end

function decMoney(self,val,way)
	assert(val >= 0,"error decMoney======>>>" .. val)
	assert(self.db.money >= val,"error decMoney  < val")
	assert(way,"error need way!!!!")
	self.db.money = self.db.money - val
end

function getRmb(self)
	return self.db.rmb
end

function incRmb(self,val,way)
	assert(val >= 0,"error incMoney======>>>" .. val)
	assert(way,"error need way!!!!")
	self.db.rmb = self.db.rmb + val
end

function decRmb(self,val,note,way)
	assert(val >= 0,"error decRmb======>>>" .. val)
	assert(self.db.rmb >= val,"error decRmb  < val")
	assert(way,"error need way!!!!")
	self.db.rmb = self.db.rmb - val
end

return ObjHuman
