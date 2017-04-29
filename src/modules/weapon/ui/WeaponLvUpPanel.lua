module(..., package.seeall)
setmetatable(_M, {__index = Control}) 

local Define = require("src/modules/weapon/WeaponDefine")
local Weapon = require("src/modules/weapon/Weapon")
local BagData = require("src/modules/bag/BagData")
local BaseMath = require("src/modules/public/BaseMath")

function new()
    local ctrl = Control.new(require("res/weapon/WeaponLvUpSkin"),{"res/weapon/WeaponLvUp.plist"})
    setmetatable(ctrl,{__index = _M})
    ctrl:init()
    return ctrl
end

function uiEffect()
	return UIManager.THIRD_TEMP
end

function init(self)
	_M.touch = Common.outSideTouch
	self.wepDecsList = {"八尺琼勾玉", "草雉剑", "八尺镜"}

	self.chongneng.txtexp:setDimensions(160,0)
	self.chongneng.txtexp:setHorizontalAlignment(Label.Alignment.Center)
	self.titleLabel:setDimensions(200, 0)
	self.titleLabel:setHorizontalAlignment(Label.Alignment.Center)
	self.chongneng.smallExpBtn:addEventListener(Event.TouchEvent, onUseSmallExp, self)
	self.chongneng.bigExpBtn:addEventListener(Event.TouchEvent, onUseBigExp, self)
end

function refreshWepLvUpInfo(self, wepId)
	self.currentWepId = wepId
	local wep = Weapon.getWep(self.currentWepId)
	local curMaxExp = Weapon.getLvConfig(wep.lv).exp

	if curMaxExp > 0 then
		self.chongneng.txtexp:setString(wep.exp .. "/" .. curMaxExp)
		if wep.exp >= curMaxExp then
			self.chongneng.expprog:setPercent(100)
		else
			self.chongneng.expprog:setPercent(100 * wep.exp / curMaxExp)
		end
	else
		self.chongneng.txtexp:setString("最大等级")
		self.chongneng.expprog:setPercent(100)
	end


	local smallNum = BagData.getItemNumByItemId(Define.WEP_UPLV_ITEM[1])
	local bigNum = BagData.getItemNumByItemId(Define.WEP_UPLV_ITEM[2])
	self.chongneng.smallExpBtn.txtnum:setString("X" .. smallNum)
	self.chongneng.bigExpBtn.txtnum:setString("X" .. bigNum)
	self.titleLabel:setString(self.wepDecsList[self.currentWepId] .. '(' .. wep.quality .. '阶)')

	self.chongneng.left.curLvTxt:setString(wep.lv .. '级')	
	self.chongneng.right.nextLvTxt:setString((wep.lv + 1) .. '级')	
	local cfg = Weapon.getWeaponConfig(wepId, wep.quality, wep.lv)
	if cfg then
		local txt = self:attrString(cfg)
		self.chongneng.left.maxHp2:setString(txt)
		self.chongneng.left.maxHp2:setPositionY(self.chongneng.left.order:getPositionY() - self.chongneng.left.maxHp2:getContentSize().height)
	end
	local nextCfg = Weapon.getWeaponConfig(wepId, wep.quality, wep.lv + 1)
	if nextCfg then
		local txt = self:attrString(nextCfg)
		self.chongneng.right.maxHp2:setString(txt)
		self.chongneng.right.maxHp2:setPositionY(self.chongneng.right.order:getPositionY() - self.chongneng.right.maxHp2:getContentSize().height)
	else
		self.chongneng.right.maxHp2:setString('已达最大等级')
	end
end

local attr = 
{
atk="技能攻击", finalAtk="必杀攻击", def="技能防御", finalDef="必杀防御", maxHp="血量",
atkSpeed="攻速", crthit="暴击", antiCrthit="防爆", block="格挡", antiBlock="破挡",
assist="援助次数", rageR="怒气回复", hpR="血量回复"
}
function attrString(self, cfgLv)
	local txt = ""
	for k, v in pairs(cfgLv.attr) do
		txt = txt .. (attr[k] or "攻") .. " +" .. v .. "\n" 
	end
	return txt
end

function addStage(self)
	--self:setScale(Stage.uiScale)
	--self:setPositionY(Stage.uiBottom)
	self:marginCenter()
end

function onCloseUp(self, event)
	UIManager.removeUI(self)
end

function onUseSmallExp(self, event, target)
	if event.etype == Event.Touch_began then
		if target.holdTimer then
			target:delTimer(target.holdTimer)
		end
		target.holdTimer = target:addTimer(onContinueUseSmallExp,0.2,-1,self)
		target:openTimer()
	elseif event.etype == Event.Touch_ended then
		self:onContinueUseSmallExp()
		if target.holdTimer then
			target:delTimer(target.holdTimer)
			target.holdTimer = nil
		end
	elseif event.etype == Event.Touch_out then
		if target.holdTimer then
			target:delTimer(target.holdTimer)
			target.holdTimer = nil
		end
	end
end

function onContinueUseSmallExp(self, event, target)
	local itemNum = BagData.getItemNumByItemId(Define.WEP_UPLV_ITEM[1])
	local cnt = Common.getTouchUseCount(event, itemNum)
	Network.sendMsg(PacketID.CG_WEAPON_UP_LV, self.currentWepId, Define.WEP_UPLV_ITEM[1], cnt)
end

function onUseBigExp(self, event, target)
	if event.etype == Event.Touch_began then
		if target.holdTimer then
			target:delTimer(target.holdTimer)
		end
		target.holdTimer = target:addTimer(onContinueUseBigExp,0.2,-1,self)
		target:openTimer()
	elseif event.etype == Event.Touch_ended then
		self:onContinueUseBigExp()
		if target.holdTimer then
			target:delTimer(target.holdTimer)
			target.holdTimer = nil
		end
	elseif event.etype == Event.Touch_out then
		if target.holdTimer then
			target:delTimer(target.holdTimer)
			target.holdTimer = nil
		end
	end
end

function onContinueUseBigExp(self, event)
	local itemNum = BagData.getItemNumByItemId(Define.WEP_UPLV_ITEM[2])
	local cnt = Common.getTouchUseCount(event, itemNum)
	Network.sendMsg(PacketID.CG_WEAPON_UP_LV, self.currentWepId, Define.WEP_UPLV_ITEM[2], cnt)
end
