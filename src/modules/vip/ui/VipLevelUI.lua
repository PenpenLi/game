module(...,package.seeall)
setmetatable(_M, {__index = Control})
 
local VipConfig = require("src/config/VipConfig").Config
local VipDefine = require("src/modules/vip/VipDefine")
local VipLogic = require("src/modules/vip/VipLogic")
local VipLevelConfig = require("src/config/VipLevelConfig").Config
local VipLevelLogic = require("src/modules/vip/VipLevelLogic")
local ShopDefine = require("src/modules/shop/ShopDefine")


function new()
	local ctrl = Control.new(require("res/vip/VipLevelSkin"), {"res/vip/VipLevel.plist"})
	setmetatable(ctrl, {__index = _M})
	ctrl:init()
	return ctrl
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
end

function uiEffect(self)
	return UIManager.FIRST_TEMP_RAW
end

function init(self)
	self.vipcg:addItem()
	self.vipcg:setDirection(List.UI_LIST_HORIZONTAL)
	self.vipcg:setBgVisiable(false)
	local master = Master.getInstance()
	local vipLv = master.vipLv
	local item = self.vipcg:getItemByNum(1)
	local levelNum = 0

	local function onFight(self,event,target)
		if event.etype == Event.Touch_ended then
			local master = Master.getInstance()
			if master.vipLv < target.vipLv then
				Common.showMsg("vip等级不足")
				return
			end
			if VipLevelLogic.fightTimes >= VipLogic.getVipAddCount("vipLevelFreeCount") then
				ShopUI.virBuy(ShopDefine.K_SHOP_VIRTUAL_VIPLEVELTIMES)
			else
				local id = target.id
				Network.sendMsg(PacketID.CG_VIP_LEVEL_START,id)
				print("onFight"..id)
			end
		end
	end
	for id,cfg in ipairs(VipLevelConfig) do 
		if item['lv'..id] then
			local level = item['lv'..id]
			level.vipLv = cfg.vipLv
			if cfg.vipLv > vipLv then
				level['vipcg'..id]:shader(Shader.SHADER_TYPE_GRAY)
			end
			level.fight.id = id
			level.fight.vipLv = cfg.vipLv
			levelNum = id
			level.vipnum:setVisible(false)
			if vipLv >= cfg.vipLv then
				level.vipzi:setVisible(true)
				level.kq:setVisible(false)
				local v = cc.Label:createWithBMFont("res/common/VipNum.fnt", cfg.vipLv)
				level._ccnode:addChild(v)
				local x,y = level.vipnum:getPosition()
				v:setPosition(x+2,y+3)
			else
				level.vipzi:setVisible(false)
				level.kq:setVisible(true)
				local v = cc.Label:createWithBMFont("res/common/vipLevelNum.fnt", cfg.vipLv)
				v:setAnchorPoint(0,0)
				level._ccnode:addChild(v)
				v:setPosition(level.vipnum:getPosition())
			end
			item['lv'..id].fight:addEventListener(Event.TouchEvent,onFight,self)
		end
	end
	local function clearLevels(self)
		for i=1,levelNum do 
			item['lv'..i]['vipcg'..i]:shader()
			item['lv'..i].fight:setVisible(false)
		end
	end
	clearLevels(self)
	for i=1,6 do 
		CommonGrid.bind(self.reward['grid'..i],true)
	end
	local function setLevel(self,no)
		clearLevels(self)
		item['lv'..no]['vipcg'..no]:shader(Shader.SHADER_TYPE_BLINK)
		item['lv'..no].fight:setVisible(true)
		local cfg = VipLevelConfig[no]
		local r = {}
		for itemId,item in pairs(cfg.randReward) do 
			if type(itemId) == "number" then
				table.insert(r,itemId)
			end
		end
		for itemId,_ in pairs(cfg.fixReward) do 
			table.insert(r,itemId)
		end
		for i=1,6 do 
			if r[i] then
				self.reward['grid'..i]:setItemIcon(r[i],"",57)
			else
				self.reward['grid'..i]:setItemIcon()
			end
		end
		-- local ui = UIManager.addChildUI("src/ui/HeroRec2UI")
		-- if ui then
		-- 	local hero = {}
		-- 	for i,relation in ipairs(cfg.relation) do 
		-- 		table.insert(hero,relation[1])
		-- 	end

		-- 	ui:setRec("","",hero)
		-- end

	end
	setLevel(self,1)
	item.touch = 
	function(item,event)
		if event.etype == Event.Touch_ended then
			local worldPoint = event.p
			local touchLocation = item._ccnode:convertToNodeSpace(worldPoint)
			for i=1,levelNum do
				local level = item['lv'..i]
				local bound = level._ccnode:getBoundingBox()
				if cc.rectContainsPoint(bound, touchLocation) then
					local loc = level['vipcg'..i]._ccnode:convertToNodeSpace(worldPoint)
					local ret,r,g,b,a = level['vipcg'..i]._ccnode:getPixelRGBA(loc.x,loc.y)
					if ret and a > 0 then

						local child = Control.getTouchedChild(level,worldPoint)
						if child and child.name == 'fight' then
							child:touch(event)
						else
							setLevel(self,i)
						end
					end
				end
			end
		end
	end
	
	local function onClose(self,event,target)
		UIManager.removeUI(self)
	end
	self.back:addEventListener(Event.Click,onClose,self)
	self:refreshTimes()
	local function onAddTimes(self,event,target)
		if VipLevelLogic.fightTimes <= 0 then
			Common.showMsg("挑战次数达到最大值，无法购买！")
		else
			ShopUI.virBuy(ShopDefine.K_SHOP_VIRTUAL_VIPLEVELTIMES)
		end
	end
	self.times.add:addEventListener(Event.Click,onAddTimes,self)
end

function refreshTimes(self)
	self.times.txttimes:setString(math.max(0,VipLogic.getVipAddCount("vipLevelFreeCount") - VipLevelLogic.fightTimes))
end