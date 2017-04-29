module("HeroExchangeUI", package.seeall)
setmetatable(HeroExchangeUI, {__index = Control})





local Def = require("src/modules/hero/HeroDefine")
local HeroQualityConfig = require("src/config/HeroQualityConfig").Config
local Hero = require("src/modules/hero/Hero")
local BagData = require("src/modules/bag/BagData")
local Chapter = require("src/modules/chapter/Chapter")
local ChapterDefine = require("src/modules/chapter/ChapterDefine")
local BaseMath = require("src/modules/public/BaseMath")
local PublicLogic = require("src/modules/public/PublicLogic")
local ItemConfig = require("src/config/ItemConfig").Config






function new(name)
	local ctrl = Control.new(require("res/hero/HeroExchangeSkin"),{"res/hero/HeroExchange.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(name)
	return ctrl
end

function uiEffect()
	return UIManager.THIRD_TEMP
end

function init(self,name)
	_M.touch = Common.outSideTouch
	local hero = Hero.getHero(name)
	local star = hero.quality + 1
	if star > Def.MAX_QUALITY then
		star = Def.MAX_QUALITY
	end
	local conf = Def.DefineConfig[name]
	local hero = Hero.getHero(name)
	--self.heroGrid = HeroGridS.new(self.iconbg)
	--self.heroGrid:setHero(hero)
	CommonGrid.bind(self.iconbg)
	local fragId = conf.fragId
	self.iconbg:setItemIcon(fragId,"descIcon")


	local itemCfg = ItemConfig[fragId]
	local rate = conf.exchangeCoin[1]
	local master = Master.getInstance()
	-- self:showCard(name)
	Common.setLabelCenter(self.txtheroname)
	self.txtheroname:setString(itemCfg.name)


	local owncoin = master.exchangeCoin
	local coinLimit = conf.exchangeCoin[star]
	local fragLimit = math.min(math.floor(owncoin/rate),coinLimit)

	local curFrag = hero.exchange[star] or 0
	local fragLimit2 = math.min(math.floor(curFrag+owncoin/rate),coinLimit)
	Common.setLabelCenter(self.txtowncoin)
	--self.txtowncoin:setString("拥有"..owncoin.."个积分")
	local ownNum = BagData.getItemNumByItemId(fragId)
	self.txtowncoin:setString(ownNum)

	self.txtmaxcoin:setString(owncoin)

	local function setExchange(frag)
		if frag  >= curFrag and  frag <= fragLimit2 then
			self.txtcoin2:setString(frag*rate.."/"..coinLimit*rate)
			self.frag = frag
			self.txtcoin:setString(frag*rate)
		end


	end

	local function onJia(self,event,target)
		setExchange(self.frag + 1)

	end

	local function onJian(self,event,target)
		setExchange(self.frag - 1)
	end

	local function onMax(self,event,target)
		setExchange(fragLimit)
	end
	self.jiahao:addEventListener(Event.Click,onJia,self)
	self.jianhao:addEventListener(Event.Click,onJian,self)
	self.zuida:addEventListener(Event.Click,onMax,self)


	setExchange(fragLimit)

	local function onDuihuan(self,event,target)
		if self.frag - curFrag > 0 then
			Network.sendMsg(PacketID.CG_HERO_EXCHANGE,name,self.frag - curFrag)
			UIManager.removeUI(self)
		else
			Common.showMsg("兑换积分不足")
			UIManager.removeUI(self)
		end
	end
	self.duihuan:addEventListener(Event.Click,onDuihuan,self)
	
	setExchange(curFrag)

	local function hideStarTip()
		self.startip:setVisible(false)
		self:removeChildByName('starmask')
	end
	for i=0,4 do 
		Common.setLabelCenter(self.startip['txtdesc'..i],"left")
	end
	Common.setLabelCenter(self.startip.title)
	self.startip.title:setString(conf.cname.."兑换规则")
	local function showTip()
		local mask = LayerColor.new('starmask',0,0,0,100,Stage.frameSize.width,Stage.frameSize.height)
		self:addChild(mask)
		self.startip:setTop()
		self.startip:setVisible(true)
		self.startip.txtdesc0:setString(rate.."个积分兑换1个碎片")
		for i=1,4 do 
			self.startip['txtdesc'..i]:setString(i.."星最多兑换"..conf.exchangeCoin[i+1].."个碎片")
		end
		mask:addEventListener(Event.TouchEvent,function(self,event) 
			if event.etype == Event.Touch_began then
				hideStarTip() 
			end
			end,
			self )
	end
	hideStarTip()
	self.tip:addEventListener(Event.Click,showTip,self)

end


return HeroExchangeUI
