module(..., package.seeall)
setmetatable(_M, {__index = Control})





local Def = require("src/modules/hero/HeroDefine")
local HeroQualityConfig = require("src/config/HeroQualityConfig").Config
local HeroStarConfig = require("src/config/HeroStarConfig").Config
local Hero = require("src/modules/hero/Hero")
local BagData = require("src/modules/bag/BagData")
local BaseMath = require("src/modules/public/BaseMath")

function new(name,star)
	-- star 2--5
	local ctrl = Control.new(require("res/hero/HeroStarUpSkin"),{"res/hero/HeroStarUp.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(name,star)
	return ctrl
end

function uiEffect()
	return UIManager.FIRST_TEMP_LABEL
end

function setExchange(self,fragCnt)
	local fragId = Def.DefineConfig[self.name].fragId
	local fragNum = BaseMath.getHeroQualityFrag(self.name,self.star)
	local fragLimit = self.exchangeCoin[self.star]



	local rate = self.exchangeCoin[1]
	local fragCurCnt = BagData.getItemNumByItemId(fragId)
	local coin = Master.getInstance().exchangeCoin
	if coin < fragCnt*rate then
		Common.showMsg("兑换积分不足")
		return
	end
	if fragCnt > fragLimit then
		Common.showMsg("超过兑换比例")
		return
	end
	self.frag = fragCnt
	self.exchange.progcoin:setPercent(100*fragCnt/fragNum)


	self.frags = math.min(fragCurCnt,fragNum - fragCnt)
	self.exchange.progfrag:setPercent(100*self.frags/fragNum)
	-- self.exchange.txtcoin:setString(fragCnt*rate.."/"..coin)


	self.head.txttotal:setString("/"..fragNum)
	Common.setLabelCenter(self.head.txtcur,"right")
	self.head.txtcur:setString(fragCurCnt+fragCnt)
	if fragCurCnt + fragCnt < fragNum then
		self.head.txtcur:setColor(192,0,0)
	else
		self.head.txtcur:setColor(59,31,24)
	end
	self.exchange.txtfragnum:setString(math.min(fragNum-fragCnt,fragCurCnt))
	self.exchange.txtcoinnum:setString("+"..fragCnt)

	self.exchange.txtdesc.txtcoin:setString(fragCnt)
	self.exchange.txtdesc.txtcoin:setColor(192,0,0)
	self.coinFrag = fragCnt
end


function init(self,name,star)
	self.name = name
	self.star = star
	self.hero = Hero.getHero(name)
	local master = Master.getInstance()
	self.exchangeCoin = Def.DefineConfig[name].exchangeCoin
	local fragNum = BaseMath.getHeroQualityFrag(name,star)
	local fragLimit = self.exchangeCoin[self.star]
	local fragId = Def.DefineConfig[self.name].fragId
	local fragCurCnt = BagData.getItemNumByItemId(fragId)
	local nextLvMoney = HeroQualityConfig[star].qualityMoney
	self.exchange.progcoin:setMidpoint(cc.p(1,0))
	self.exchange.progcoinbg:setMidpoint(cc.p(1,0))
	self.txtjb:setString(nextLvMoney)
	Common.setLabelCenter(self.txtname)
	self.txtname:setString(self.hero.cname)
	self.exchange.txtdesc.txtfrag:setString(fragCurCnt)
	self.coinnum = master.exchangeCoin
	self.exchange.txtdesc.txtvalidcoin:setString(math.min(self.coinnum,fragLimit*self.exchangeCoin[1])..")")
	
	Common.setLabelCenter(self.exchange.txtcoinnum,"right")
	Common.setLabelCenter(self.exchange.txtfragnum)
	Common.setLabelCenter(self.exchange.txtdesc.txtrate,"right")
	self.exchange.txtdesc.txtrate:setString("("..self.exchangeCoin[1])
	
	local coinBgPercent = 100*fragLimit/fragNum
	self.exchange.progcoinbg:setPercent(coinBgPercent)
	self.exchange.progfragbg:setPercent(100-coinBgPercent)
	-- Common.setLabelCenter(self.exchange.txtrate)
	-- self.exchange.txtrate:setString("("..self.exchangeCoin[1].."兑换积分=1个碎片)")

	-- Common.setLabelCenter(self.exchange.txtcoin)
	self.heady = self.head._skin.y
	local function onRBStar(self,event,target)
		self.exchange:setVisible(false)
		self.mode = "star"
		self:setExchange(0)
		local y = self.xxjn._skin.y + self.xxjn._skin.height/2 - self.head._skin.height/2
		self.head:setPositionY(y)
	end

	local function onRBExchange(self,event,target)
		self.exchange:setVisible(true)
		self.mode = "exchange"
		local maxFrag = math.min(self.exchangeCoin[star],math.floor(master.exchangeCoin/self.exchangeCoin[1]))
		self.head:setPositionY(self.heady)
		self:setExchange(maxFrag)
	end
	self.rbgtab.star:addEventListener(Event.Click,onRBStar,self)
	self.rbgtab.exchange:addEventListener(Event.Click,onRBExchange,self)
	self.rbgtab.star:dispatchEvent(Event.Click,{etype=Event.Click})
	self.rbgtab.star:setSelected(true)

	CommonGrid.bind(self.head.headnow)
	self.head.headnow:setHeroIcon(name,nil,72/92,star-1)
	CommonGrid.bind(self.head.headnext)
	self.head.headnext:setHeroIcon(name,nil,72/92,star)

	-- local function onPreview(self,event,target)
	-- 	if event.etype == Event.Touch_ended then
	-- 		UIManager.addUI("src/modules/hero/ui/HeroStarPreviewUI",name,star)
	-- 	end

	-- end
	-- self.head.headnext:addEventListener(Event.TouchEvent,onPreview,self)

	local function onJia(self,event,target)
		local fragNum = BaseMath.getHeroQualityFrag(self.name,self.star)
		local fragLimit = self.exchangeCoin[self.star]
		local rate = self.exchangeCoin[1]
		local fragCurCnt = BagData.getItemNumByItemId(fragId)
		local coin = Master.getInstance().exchangeCoin
		if coin < (self.frag+1)*rate then
			Common.showMsg("兑换积分不足")
			return
		end
		if (self.frag+1) > fragLimit then
			Common.showMsg("超过兑换比例")
			return
		end
		self:setExchange(self.frag + 1)
	end

	local function onJian(self,event,target)
		if self.frag > 0 then
			self:setExchange(self.frag -1)
		end
	end
	self.exchange.jiahao:addEventListener(Event.Click,onJia,self)
	self.exchange.jianhao:addEventListener(Event.Click,onJian,self)


	local function onClose(self,event,target)
		UIManager.removeUI(self)
	end
	self.close:addEventListener(Event.Click,onClose,self)

	local function onStarUp(self)
		local star = self.hero.quality + 1
		if star > Def.MAX_QUALITY then
			-- local tips = TipsUI.showTipsOnlyConfirm()
			Common.showMsg("英雄已经满星，无法再升星")
			return
		end
		local fragNum = BaseMath.getHeroQualityFrag(self.name,star)
		local fragId = Def.DefineConfig[self.name].fragId
		if BagData.getItemNumByItemId(fragId) + self.coinFrag < fragNum then
			-- self.attrgroup.fragtips:setVisible(true)
			-- self.attrgroup.fragtips:openTimer()
			-- local function hideFragTips(self)
			-- 	self.attrgroup.fragtips:setVisible(false)
			-- end
			-- self.fragTipsTimer = self.attrgroup.fragtips:addTimer(hideFragTips,2,1,self)
			local tips = TipsUI.showTipsOnlyConfirm("英雄碎片不足，无法升星")

		else
			local nextLvMoney = HeroQualityConfig[star].qualityMoney
			local infoUI = require("src/modules/hero/ui/HeroInfoUI").Instance
			if Master:getInstance().money < nextLvMoney then
				--ShopUI.virBuy(ShopDefine.K_SHOP_VIRTUAL_MONEY_ID)
				local t,rmb,m = ShopUI.getMoneyBuyCntAndCost(nextLvMoney)

				if rmb >= Master.getInstance().rmb then
					-- 钻石不足
					Common.showMsg("金币不足,无法升星")
				elseif t < 0 then
					Common.showMsg("金币不足，请提升VIP等级，增加购买次数")
				else
					local rmbTip = TipsUI.showTips('金币不足，确定花费'..rmb..'钻石购买'..m.."金币用于升星？")
					rmbTip:addEventListener(Event.Confirm,function(self,event)
						if event.etype == Event.Confirm_yes then
							if infoUI then
								infoUI:setOldAttr()
							end
							Network.sendMsg(PacketID.CG_HERO_QUALITY_UP,self.name,self.frags,self.coinFrag,t)
							UIManager.removeUI(self)
						end
					end,self)
				end
			else
				if infoUI then
					infoUI:setOldAttr()
				end
				Network.sendMsg(PacketID.CG_HERO_QUALITY_UP,self.name,self.frags,self.coinFrag)
				UIManager.removeUI(self)
			end
			-- 	local tips = TipsUI.showTips('确定花费'..nextLvMoney..'金币升级到'..star.."星英雄，是否继续？")
			-- 	tips:setBtnName("确定","取消")
			-- tips:addEventListener(Event.Confirm, function(self,event) 
			-- 	if event.etype == Event.Confirm_yes then

			-- 	end
		end
	end
	self.starup:addEventListener(Event.Click,onStarUp,self)

	local ui = Stage.currentScene:getUI()
	-- ui:setTopCoin(1,"money",BagData.getItemNumByItemId(9901001))
	-- ui:setTopCoin(2,"rmb",BagData.getItemNumByItemId(9901002))
	ui:setTopCoin(3,"exchangebig",self.coinnum)
end

function clear(self)
	local ui = Stage.currentScene:getUI()
	ui:resetTopCoin()
	Control.clear(self)
end
