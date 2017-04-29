module("ShopRareUI",package.seeall)
setmetatable(_M,{__index = Control})
local ShopDefine = require("src/modules/shop/ShopDefine")
local Shop = require("src/modules/shop/Shop")
local LotteryConfig = require("src/config/LotteryConfig")
local HeroDefineConfig = require("src/config/HeroDefineConfig").Config
local Hero = require("src/modules/hero/Hero")

function new(isFree)
	local ctrl = Control.new(require("res/shop/ShopRareSkin.lua"),{"res/shop/ShopRare.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(isFree)
	return ctrl
end

function uiEffect()
	return UIManager.SECOND_TEMP
end

function onClose(self,event,target)
	UIManager.removeUI(self)
end

function init(self,isFree)
	local function onOnce(self,event,target)
		UIManager.removeUI(self)
		Network.sendMsg(PacketID.CG_SHOP_RARE_ONCE)
	end
	local function onTen(self,event,target)
		UIManager.removeUI(self)
		Network.sendMsg(PacketID.CG_SHOP_RARE_TEN)
	end
	self.close:addEventListener(Event.Click,onClose,self)
	self.once:addEventListener(Event.Click,onOnce,self)
	self.ten:addEventListener(Event.Click,onTen,self)
	local tenGold = LotteryConfig.ConstantConfig[1].tenCost
	self.goldten.num:setString(tenGold)
	CommonGrid.setCoinIcon(self.goldten.jbbicon,"rmb")
	if isFree then
		self.goldonce.num:setString("当前免费")
		self.goldonce.num:setAnchorPoint(0.5,0)
		self.goldonce.jbbicon:setVisible(false)
	else
		local onceGold = LotteryConfig.ConstantConfig[1].onceCost
		self.goldonce.num:setString(onceGold)
		CommonGrid.setCoinIcon(self.goldonce.jbbicon,"rmb")
	end
	local rareTimes = ShopDefine.RARE_TEN - Shop.getRareTimes()
	local content = string.format("再抽取%d次后，下次抽取必得",rareTimes - 1)
	if rareTimes <= 1 then
		content = string.format("下次抽取必得")
	end
	self.txtcq:setString(content)
	self.txtyxzi:setPositionX(self.txtcq:getPositionX()+self.txtcq:getContentSize().width)

	--TODO:
	local temp = {[1]="Shermie",[2]="Orochi",[3]="Iori"}
	for i = 1,3 do
		local res = string.format("res/hero/cicon/%s.jpg",temp[i])
		local heroicon = cc.Sprite:create(res)
		local bg = self["illustration"..i].illu.illustrationbg
		local size = bg:getContentSize()
		heroicon:setPosition(size.width/2,size.height/2)
		heroicon:setScale(0.58)
		bg._ccnode:addChild(heroicon)
		local cName = Hero.getCNameByName(temp[i])
		self["illustration"..i].heroname.txtname:setString(cName)
	end
end

return ShopRareUI
