module("PartnerComposeUI",package.seeall)
local ItemConfig = require("src/config/ItemConfig").Config
local PartnerConfig = require("src/config/PartnerConfig").Config
local ChainConfig = require("src/config/PartnerChainConfig").Config
local PartnerData = require("src/modules/partner/PartnerData")
local HeroDefine = require("src/modules/hero/HeroDefine")
local BagData = require("src/modules/bag/BagData")
setmetatable(_M,{__index = Control})

function new(chainId,partnerId)
	local ctrl = Control.new(require("res/partner/PartnerComposeSkin.lua"),{"res/partner/PartnerCompose.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(chainId,partnerId)
	return ctrl
end

function uiEffect()
	--return UIManager.SECOND_TEMP
	return UIManager.FIRST_TEMP_RAW
end

function init(self,chainId,partnerId)
	self:addArmatureFrame("res/strength/effect/compose/StrengthCompose.ExportJson")
	self.chainId = chainId
	self.partnerId = partnerId
	local function onClose(self,event,target)
		UIManager.removeUI(self)
	end
	self.close:addEventListener(Event.Click, onClose, self)
	local function onCompose(self,event,target)
		Network.sendMsg(PacketID.CG_PARTNER_COMPOSE,self.partnerId)
	end
	self.compose:addEventListener(Event.Click,onCompose,self)
	CommonGrid.bind(self.partnerBg)
	local function onTips(self,event,target)
		UIManager.addChildUI("src/modules/partner/ui/PartnerTipsUI",target.id)
	end
	for i = 1,6 do
		CommonGrid.bind(self.material["grid"..i].bg)
		self.material["grid"..i].num:setFontSize(20)
		self.material["grid"..i].num:setAnchorPoint(1,0)
		local bg = self.material["grid"..i].bg
		self.material["grid"..i].num:setPositionX(bg:getPositionX()+bg:getContentSize().width-10)
	end
	for i = 1,3 do
		for j = 1,4 do
			CommonGrid.bind(self["chain"..i]["hero"..j].jnBG,"tips")
			--self["chain"..i]["hero"..j]:addEventListener(Event.TouchEvent,onTips,self)
		end
	end
	self:refreshInfo()
end

function refreshChainInfo(self)
	local id = self.partnerId
	local partnerCfg = PartnerConfig[id]
	local heroName = partnerCfg.hero
	local hero2PartnerCfg = PartnerData.getHero2PartnerCfg()[heroName]
	for i = 1,3 do
		local chainId = hero2PartnerCfg.chain[i]
		local chainInfo = self["chain"..i]
		if chainId then
			local chainCfg = ChainConfig[chainId]
			local attr
			local val 
			for k,v in pairs(chainCfg.attr) do
				attr = k
				val = v
				break
			end
			local str = string.format("%d.%s:%s",i,chainCfg.name,HeroDefine.DyAttrCName[attr])
			chainInfo.txtAttr:setString(str)
			chainInfo.attrVal:setString(string.format("+%d%%",val))
			chainInfo.attrVal:setPositionX(chainInfo.txtAttr:getPositionX()+chainInfo.txtAttr:getContentSize().width)
			local group = chainCfg.group
			for j = 1,4 do
				local partnerId = group[j]
				if partnerId then
					chainInfo["hero"..j].id = partnerId
					chainInfo["hero"..j].jnBG:setItemIcon(partnerId)
					if not PartnerData.hasPartner(chainId,partnerId) then
						chainInfo["hero"..j].jnBG:setShader("Gray")
					end
				else
					chainInfo["hero"..j]:setVisible(false)
				end
			end
		else
			chainInfo:setVisible(false)
		end
	end
end

function refreshMaterialInfo(self)
	if not PartnerData.hasPartner(self.chainId,self.partnerId) then
		self.material:setVisible(true)
		self.compose:setVisible(true)
		local id = self.partnerId
		local partnerCfg = PartnerConfig[id]
		local need = partnerCfg.need
		local gridId = 1
		for k,v in pairs(need) do
			self.material["grid"..gridId].id = k
			self.material["grid"..gridId].bg:setItemIcon(k)
			local num = BagData.getItemNumByItemId(k)
			self.material["grid"..gridId].num:setString(num.."/"..v)
			if num < v then
				self.material["grid"..gridId].bg:setShader("Gray")
				self.material["grid"..gridId].num:setColor(255,0,0)
			else
				self.material["grid"..gridId].bg:resetShader()
				self.material["grid"..gridId].num:setColor(0,255,0)
			end
			gridId = gridId + 1
		end
		for i = gridId,6 do
			self.material["grid"..i]:setVisible(false)
		end
	else
		self.material:setVisible(false)
		self.compose:setVisible(false)
	end
end

function refreshPartnerInfo(self)
	local id = self.partnerId
	local itemCfg = ItemConfig[id]
	self.txtname:setAnchorPoint(0.5,0)
	self.txtname:setString(itemCfg.name)
	self.partnerBg:setItemIcon(id)
	if PartnerData.hasPartner(self.chainId,self.partnerId) then
		self.weijihuozi:setVisible(false)
		self.txtDesc:setVisible(true)
		self.txtDesc:setAnchorPoint(0.5,0)
		self.txtDesc:setString(string.format("传说中的%s已激活",itemCfg.name))
	else
		self.weijihuozi:setVisible(true)
		self.txtDesc:setVisible(false)
	end
end

function refreshInfo(self)
	self:refreshPartnerInfo()
	self:refreshMaterialInfo()
	self:refreshChainInfo()
end

function playEffect(self)
	Common.setBtnAnimation(self.material.grid2.bg._ccnode,"StrengthCompose","middle")
	Common.setBtnAnimation(self.material.grid2.bg._ccnode,"StrengthCompose","left",{x=5})
	Common.setBtnAnimation(self.material.grid2.bg._ccnode,"StrengthCompose","right",{x=-5})
	Common.setBtnAnimation(self.material.grid2.bg._ccnode,"StrengthCompose","top",{y=20})
end

return PartnerComposeUI
