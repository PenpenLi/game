module("Network", package.seeall)

DISCONNECT_REASON_SERVER_CLOSE = 100
DISCONNECT_REASON_ERROR = 101

lastMsg = {}

local ProtoTemplate = {}
local ProtoName = {}
local ProtoHandler = {} --包含所有GC协议的handler
local MsgHandler = {}		--消息分发容器

local function protoName2PacketId(str)
	res = str:sub(1, 2) .. "_"
	for i = 3, #str do
		if str:byte(i, i) < 97 and 96 < str:byte(i - 1, i - 1) then
			res = res .. "_"
		end
		res = res .. str:sub(i, i):upper()
	end
	return res
end

local function RegisterProto(packetId, template, protoName,protoHandler)
	if not ProtoTemplate[packetId] then
--		print("Register packetId:", packetId, protoName)
		ProtoTemplate[packetId] = template
		ProtoName[packetId] = protoName 
		ProtoHandler[packetId] = protoHandler
		_protoTemplateToTree(packetId, template)
	end
end

--注册模块协议（模版，处理回调）
function RegisterOneModuleProtos(moduleName)
	local EventHandler = require("src/modules/"..moduleName .. "/EventHandler")
	local Protocol = require("src/modules/"..moduleName .. "/Protocol")
	for protoName, template in pairs(Protocol) do
		local prefix = protoName:sub(1, 2)
		if prefix == "CG" or prefix == "GC"  then
			local pName= protoName2PacketId(protoName)
			local packetId = PacketID[pName]
			assert(packetId, pName .. " not exist")
			local handler = EventHandler["on" .. protoName]
			assert(prefix == "CG" or handler, protoName .. " handler is nil !")
			RegisterProto(packetId, template, pName, handler)
		end
	end
end


function sendMsg(packetId, ...)
	print("send:", packetId, ProtoName[packetId], ...)
	local master = Master.getInstance() 
	if master.connected then
		_sendMsg(packetId, ...)
	else
		local lastMsg = {}
		lastMsg.packetId = packetId
		lastMsg.params = {...}
		master:tryReLogin(lastMsg)
	end
end

local function networkHandler(packetId,...)
	print("recv:", packetId, ProtoName[packetId], ...)

	--WaittingUI.remove(packetId)

	local handler = ProtoHandler[packetId]
	if handler then
		handler(...)
	else
		trace("packet " .. tostring(packetId) .. ") has no handler!!")
	end
	--[[
	if MsgHandler[packetId] then
	for func,listener in pairs(MsgHandler[packetId]) do
	func(listener,...)
	end
	end
	--]]
end

function init()
	local net = MX.CNetWork:getInst()
	net:registerScriptHandler(networkHandler)
end

function connect(host,port)
	local net = MX.CNetWork:getInst()
	return net:connect(host,port)
end

function disconnect()
	local net = MX.CNetWork:getInst()
	net:setConnected(false)
	return net:disconnect()
end


function addMsgListener(packetId,func,listener)
	trace("addMsgListener: " .. packetId) 
	if not MsgHandler[packetId] then
		MsgHandler[packetId] = {}
	end

	if not MsgHandler[packetId][func] then
		MsgHandler[packetId][func] = listener or Network
	else
		assert(false,"func had exist")
	end
end

function removeMsgListenr(packetId,func)
	if MsgHandler[packetId] and MsgHandler[packetId][func] then
		MsgHandler[packetId][func] = nil
	else
		assert(false,"func not exist")
	end
end


return Network


