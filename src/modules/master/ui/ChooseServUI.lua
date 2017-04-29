module("ChooseServUI", package.seeall)
setmetatable(ChooseServUI, {__index = Control})
Config = require("src/Config")

local ServerList = {}

function new()
	--if UIInstance then return UIInstance end
	local ctrl = { 
		name = "ChooseServUI",
		uiType = UI_CONTROL_TYPE,
		_ccnode = nil,
	}
	setmetatable(ctrl, {__index = ChooseServUI})
	ctrl:addSpriteFrames("res/master/chooseServ.plist")

	local skin = require("res/master/chooseServSkin")
	ctrl._skin = skin
	ctrl:init(skin)
	ctrl:createChildren(skin)
	ctrl:start()
	return ctrl
end


function init(self, skin)
	local node = cc.Node:create()
	node:setAnchorPoint(cc.p(0.5,0.5))
	node:setPosition(cc.p(Stage.width/2,Stage.height/2))
	node:setContentSize(cc.size(skin.width,skin.height))

	self._ccnode = node 
end

function addServ(self,servname,ip,port)
	local no = self.chooseServ:addItem()
	local item = self.chooseServ.itemContainer[no]
	item.serv.servname:setString(servname)
	item.ip = ip
	item.port = port
	function onServClick(self,event,target)
		if event.etype == Event.Touch_ended then
			---[[
			local ret = Master:getInstance():login(ip,port)
			if not ret then
				print("master >>>>>login>>>",ret)
				Common.showMsg("登陆失败")
			else
				Common.showMsg("登陆成功")
			end
			--]]
		    --Stage.replaceScene(require("src/scene/FightScene").new())
		end
	end
	item.serv:addEventListener(Event.TouchEvent,onServClick,self)
end

function start(self)
	self:addServ("test","127.0.0.1",52520)
	self:addServ("test","127.0.0.1",52520)
	self:addServ("test","127.0.0.1",52520)
	self:addServ("test","127.0.0.1",52520)
	self:addServ("test","127.0.0.1",52520)
	self:addServ("test","127.0.0.1",52520)
	self:addServ("test","127.0.0.1",52520)
	self:addServ("test","127.0.0.1",52520)
	self:addServ("test","127.0.0.1",52520)
	self:addServ("test","127.0.0.1",52520)
	--[[
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("GET", Config.ServerURL)
	xhr:registerScriptHandler(function() 
		print(xhr.response)
		print(xhr.status)
		if xhr.status ~= 200 then
			return
		end
		local response = Common.urlDecode(xhr.response)
		ServerList = Json.decode(response) 
		for i,v in ipairs(ServerList) do 
			self:addServ(v[3],v[1],v[2])
		end
	end)
	xhr:send()
	]]
end
return ChooseServUI

