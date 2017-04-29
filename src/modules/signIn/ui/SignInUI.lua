module("SignInUI",package.seeall)
setmetatable(_M,{__index = Control})
local SignIn = require("src/modules/signIn/SignIn")
local ItemConfig = require("src/config/ItemConfig").Config
local BagData = require("src/modules/bag/BagData")
local Cfg = require("src/config/SignInActivityConfig").Config

local kCol = 6

function new()
	local ctrl = Control.new(require("res/signIn/SignInSkin.lua"),{"res/signIn/SignIn.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function uiEffect(self)
	--return UIManager.FIRST_TEMP_RAW
	return UIManager.THIRD_TEMP
end

function addStage(self)
	--self:setPositionY(Stage.uiBottom)
	self:adjustTouchBox(0,Stage.uiBottom,0,2*Stage.uiBottom)
end

function touch(self,event)
	Common.outSideTouch(self, event)
end

function init(self)
	local list = self.register
	list.lq:setVisible(false)
	list:setBtwSpace(-15)
	SignIn.checkInfo()
	self.explain:addEventListener(Event.Click, function()
		local ui = UIManager.addChildUI("src/ui/RuleScrollUI")
		ui:setId(RuleScrollUI.SignIn)
	end)
	self.frameN = 1
	self:addEventListener(Event.Frame, refresh, self)
	self:openTimer()
end

function refresh(self)
	local now = Master.getServerTime()
	local t = os.date('*t', now)
	local cap = tonumber(os.date("%d",os.time({year = t.year, month=t.month + 1,day = 0})))
	local list = self.register
	local i = self.frameN
	local cols = math.ceil(i/kCol)
	list:setItemNum(cols)

	local ctrl = list:getItemByNum(cols)
	local item 
	if i%kCol == 0 then
		item = ctrl["register"..kCol]
	else
		item = ctrl["register"..i%kCol]
	end
	item.qualitybg2:setVisible(false)
	item.day:setAnchorPoint(0.3,0)
	item.day:setString("第" .. i .. "天")
	local isSignIn, day = SignIn.isSignIn(i, t.day)
	local isOut = day < t.day
	item.gou:setVisible(isSignIn)
	item.mcbg:setVisible(isOut)
	item:removeEventListener(Event.TouchEvent, onSignIn)
	item:stopAllActions()
	item:setAnchorPoint(0.5,0)
	local skin = item._skin
	item:setPositionX(skin.x + skin.width / 2)
	item:setScale(1.0)
	if day == t.day then
		item:addEventListener(Event.TouchEvent, onSignIn)
		item.tsbg:setVisible(true)
		item.dqlqgx:setVisible(true)
		if not isSignIn then 
			ActionUI.bounce({item})
		end
	else
		item.tsbg:setVisible(false)
		item.dqlqgx:setVisible(false)
	end

	local conf = Cfg[t.month*100 + i] 
	if not conf then --没有？取4月份暂代
		conf = Cfg[400 + i] 
	end
	if not conf then
		conf = Cfg[401]
	end

	if conf.vipLv == 0 or conf.vipLv == 99 then
		item.vipsb:setVisible(false)
	else
		item.vipsb:setVisible(true)
		for n = 1, 13 do 
			if conf.vipLv == n then
				item.vipsb["vip" .. n]:setVisible(true)
			else
				item.vipsb["vip" .. n]:setVisible(false)
			end
		end
	end

	if i == 1 then
		self.txtqdcs:setString("本月累计签到次数：" .. SignIn.getCount())
	end
	self.frameN = self.frameN + 1
	if i == cap then
		if cap % kCol ~= 0 then
			for j = cap % kCol + 1, kCol do
				ctrl["register"..j]:setVisible(false)
			end
		end
		self:closeTimer()
	end

	local grid = item.sbexp2
	for id, cnt in pairs(conf.reward) do 
		CommonGrid.bind(grid, "tips")
		grid:setItemIcon(id)
		grid:setItemNum(cnt)
		break
	end

	if cols == 1 and i == 1 then
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=list:getItemByNum(1)["register1"], step = 2, delayTime = 0.35, addFinishFun = function() 
			local isSign,d = SignIn.isSignIn(1, 1)
			if isSign then
				GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_SIGN_IN, step = 2})
				Stage.currentScene:getUI():runAction(cc.Sequence:create(
				cc.DelayTime:create(0.1),
				cc.CallFunc:create(function()
					GuideManager.dispatchEvent(GuideDefine.GUIDE_DO_STEP, {groupId = GuideDefine.GUIDE_SIGN_IN, step = 4})	
				end)
				))
			end
		end,clickFun = function()
		end,groupId = GuideDefine.GUIDE_SIGN_IN})
	end
end

function onSignIn(self, event)
	if event.etype == Event.Touch_ended then
		Network.sendMsg(PacketID.CG_SIGN_IN)
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_SIGN_IN, step = 2})
	end
end

function clear(self)
	Control.clear(self)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 2, groupId = GuideDefine.GUIDE_SIGN_IN})
end

return SignInUI
