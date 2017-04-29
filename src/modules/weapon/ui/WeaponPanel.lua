module(..., package.seeall)
setmetatable(_M, {__index = Control}) 

local Define = require("src/modules/weapon/WeaponDefine")
local Weapon = require("src/modules/weapon/Weapon")
local BagData = require("src/modules/bag/BagData")
local ItemConfig = require("src/config/ItemConfig").Config
local ColorUtil = require("src/core/utils/ColorUtil")
local WeaponLvConfig = require("src/config/WeaponLvConfig").Config

local currentWepId = 1

function new()
    local ctrl = Control.new(require("res/weapon/WeaponSkin"),{"res/weapon/Weapon.plist"})
    setmetatable(ctrl,{__index = _M})
    ctrl:init()
    return ctrl
end

function uiEffect()
	return UIManager.FIRST_TEMP_FULL
end

function init(self)
	self:addArmatureFrame("res/armature/effect/skillNameEffect/SkillNameEffect.ExportJson")
	self.titleIconList = {self.jadeIcon, self.swordIcon, self.mirrorIcon}
	self.leftIconList = {self.suipian.mineId1big, self.suipian.mineId2big, self.suipian.mineId3big}
	self.chipDecsList = {"八尺琼勾玉精华:", "草雉剑精华:", "八尺镜精华:"}
	self.posXList = {120, 300, 480}
	self.posYList = {self._skin.height/2 + 80, self._skin.height/2, self._skin.height/2 + 80}

	self.acquire:setVisible(false)
	self.wuqi.fly:setVisible(false)
	self.weijihuo:setVisible(false)
	self.jihuo:setVisible(false)

	self.back:addEventListener(Event.TouchEvent, onClose, self)
	self.acquire.close:addEventListener(Event.TouchEvent, onCloseAcquire, self)
	self.wuqilist:addEventListener(Event.Change, onChangeWep, self)
	self.weijihuo.need.jihuo:addEventListener(Event.Click, onActiveWep, self)
	self.jihuo.need.shengjie:addEventListener(Event.Click, onWepUpQuality, self)
	self.jihuo.chongneng:addEventListener(Event.Click, onWepUpLv, self)
	self.suipian.addMoney:addEventListener(Event.Click, onShowFragUI, self)

	self.noActivePosY = self.weijihuo.txtadd:getPositionY()
	self.activePosY = self.jihuo.txtadd:getPositionY()

	self.btnList = {self.wuqilist.wq1, self.wuqilist.wq2, self.wuqilist.wq3}
	self:changeToWep(currentWepId)

	self:refreshDot()
end

function runArrowAction(self, icon)
	icon:stopAllActions()
	local moveAction = cc.MoveBy:create(1, cc.p(0, 30))
	icon:runAction(cc.RepeatForever:create(cc.Sequence:create({
		moveAction,
		moveAction:reverse()
	})))
end

function onShowFragUI(self, evt)
	local wep = Weapon.getWep(wepId)
	local needConfig = Weapon.getNeedConfig(currentWepId)
	local quality = 0	
	if wep then
		quality = wep.quality
	end
	local qualityConfig = Weapon.getQualityConfig(quality)
	local childUI = UIManager.addChildUI('src/modules/weapon/ui/FragUI', needConfig.fragItem, qualityConfig.fragNeed)
	childUI._ccnode:setLocalZOrder(10)
end
	
function refreshDot(self)
	if Weapon.hasActiveInAll() == false then
		Weapon.weaponRefresh = false
		Dot.checkToCache(DotDefine.DOT_C_WEAPON)
	end
	for k,v in ipairs(Define.WEP_LIST) do
		if Weapon.canActive(v) == true then
			Dot.check(self.btnList[k], DotDefine.DOT_C_WEAPON)	
			Dot.setDotAlignment(self.btnList[k], 'rTop', {x=30,y=30})
		else
			Dot.remove(self.btnList[k])
		end
	end
	if Weapon.canActive(currentWepId) == true then
		Dot.check(self.weijihuo.need.jihuo, DotDefine.DOT_C_WEAPON)
	else
		Dot.remove(self.weijihuo.need.jihuo)
	end
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
	local bgIcon = cc.Sprite:create("res/weapon/WeaponBg.jpg")
	bgIcon:setAnchorPoint(cc.p(0.5, 0))
	bgIcon.touchEnabled = false
	self._ccnode:addChild(bgIcon, -1)
	bgIcon:setPositionX(self:getContentSize().width / 2)
	bgIcon:setPositionY(-Stage.uiBottom)
	self:refresh()
end

local fcnt = 0
function flyText(self, txt)
	fcnt = fcnt + 1
	local fly = Control.new(self.wuqi.fly:getSkin()) 
	fly.name = fly.name .. fcnt
	fly.flytxt:setString(txt)
	fly.flytxt:marginCenter()
	self:addChild(fly)

	local action = cc.MoveBy:create(1,cc.p(fly:getPositionX(),200))
	local sineOut = cc.EaseSineOut:create(action)
	local call = cc.CallFunc:create(function()
		self:removeChild(fly)
	end)
	fly:runAction(cc.Sequence:create({sineOut, cc.DelayTime:create(0.5), sineOut, call}))
	--fly:runAction(sineOut)
end

function refresh(self)
	--self:refreshBtnLabelStatue()
	self:setWep(currentWepId)
end

function refreshBtnLabelStatue(self)
	--for i=1,3 do
	--	local icon = self.wuqilist["wq" .. i]
	--	local wep = Weapon.getWep(i)
	--	if wep then
	--		Shader.setShader(icon.rbBg._ccnode)
	--	else
	--		Shader.setShader(icon.rbBg._ccnode, Shader.SHADER_TYPE_GRAY)
	--	end
	--end
end

function setWep(self, wepId)
	currentWepId = wepId
	local wep = Weapon.getWep(wepId)
	local quality = 0 
	local wepLv = 1

	if wep then
		--激活
		self.jihuo:setVisible(true)
		self.weijihuo:setVisible(false)

		quality = wep.quality
		wepLv = wep.lv		

		self.jihuo.txtlv:setString(wep.lv) 
		--self.jihuo.txtpj:setString(Define.WEP_UPQUALITY_COLOR[wep.quality] or "黑")
		--self.jihuo.txtpj._ccnode:setColor(ColorUtil.COLOR_ARR[wep.quality] or ColorUtil.WHITE)
		for i=1,7 do
			self.jihuo['jie' .. i]:setVisible(false)
		end
		self.jihuo['jie' .. wep.quality]:setVisible(true)
	else
		--未激活
		self.weijihuo:setVisible(true)
		self.jihuo:setVisible(false)
	end

	local upPanel = self:getChild("WeaponLvUp")
	if upPanel then
		upPanel:refreshWepLvUpInfo(currentWepId)
	end

	local qualityConfig = Weapon.getQualityConfig(quality)
	local needConfig = Weapon.getNeedConfig(wepId)
	if qualityConfig.fragNeed > 0 then
		if quality == 0 then
			quality = 1
		end
		local nextCfg = Weapon.getWeaponConfig(wepId, quality, wepLv)
		local num = BagData.getItemNumByItemId(needConfig.fragItem)

		self.weijihuo.need.txtfrag:setString(num .. "/" .. qualityConfig.fragNeed)
		self.jihuo.need.txtfrag:setString(num .. "/" .. qualityConfig.fragNeed)

		if num < qualityConfig.fragNeed then
			self.weijihuo.need.txtfrag:setColor(255, 0, 0)
			self.jihuo.need.txtfrag:setColor(255, 0, 0)
		else
			self.weijihuo.need.txtfrag:setColor(0, 255, 0)
			self.jihuo.need.txtfrag:setColor(0, 255, 0)
		end
		local txt = self:attrString(nextCfg)

		self.weijihuo.txtadd:setString(txt)
		self.weijihuo.txtadd:setPositionY(self.noActivePosY - self.weijihuo.txtadd:getContentSize().height + 25)
		--self.weijihuo.need:setPositionY(self.weijihuo.txtadd:getPositionY() - self.weijihuo.txtadd:getContentSize().height/2 - 100)
		--self.weijihuo.need.txtfrag:setPositionX(chipTxt1:getPositionX() + chipTxt1:getContentSize().width)
		
		self.jihuo.txtadd:setString(txt)
		self.jihuo.txtadd:setPositionY(self.activePosY - self.jihuo.txtadd:getContentSize().height + 25)
		--self.jihuo.need:setPositionY(self.jihuo.txtadd:getPositionY() - self.jihuo.txtadd:getContentSize().height/2 - 60)
		--self.jihuo.need.txtfrag:setPositionX(chipTxt2:getPositionX() + chipTxt2:getContentSize().width)
	else
		local cfg = Weapon.getWeaponConfig(wepId, quality, wepLv)
		if cfg then
			local txt = self:attrString(cfg)
			self.jihuo.txtadd:setString(txt)
			self.jihuo.txtadd:setPositionY(self.activePosY - self.jihuo.txtadd:getContentSize().height + 25)
			self.jihuo.need.txtfrag:setString("已达顶阶")
		end
	end
	--self.weijihuo.txtadd:setString(txt)
	--self.weijihuo.txtadd:setPositionY(self.noActivePosY - self.weijihuo.txtadd:getContentSize().height + 20)
	--self.weijihuo.need:setPositionY(self.weijihuo.txtadd:getPositionY() - self.weijihuo.txtadd:getContentSize().height/2 - 100)

	--self.jihuo.txtadd:setString(txt)
	--
	--
	--
	--
	--self.jihuo.txtadd:setPositionY(self.activePosY - self.jihuo.txtadd:getContentSize().height + 20)
	--self.jihuo.need:setPositionY(self.jihuo.txtadd:getPositionY() - self.jihuo.txtadd:getContentSize().height/2 - 60)
	
	self:refreshBtnShow()
	self:showLeftIcon(currentWepId)
	self:showTitleIcon(currentWepId)
	self:showSmallIcon(currentWepId)
	self:showWeaponIcon(currentWepId, quality)
	self:refreshDot()
end

function refreshBtnShow(self)
	for i=1,3 do
		local icon = self.wuqilist["wq" .. i]
		icon._ccnode:setCascadeOpacityEnabled(true)
		if i == currentWepId then
			icon:setOpacity(255)
		else
			icon:setOpacity(100)
		end
	end
end

function showLeftIcon(self, currentWepId)
	local needConfig = Weapon.getNeedConfig(currentWepId)
	local num = BagData.getItemNumByItemId(needConfig.fragItem)
	for i=1,3 do
		self.leftIconList[i]:setVisible(false)
	end
	self.leftIconList[currentWepId]:setVisible(true)
	--self.suipian.rmbLabel:setDimensions(120,0)
	--self.suipian.rmbLabel:setHorizontalAlignment(Label.Alignment.Center)
	self.suipian.rmbLabel:setString(num)
end

function showTitleIcon(self, id)
	for _,icon in pairs(self.titleIconList) do
		icon:setVisible(false)
	end
	local icon = self.titleIconList[id]
	if icon ~= nil then
		icon:setVisible(true)
	end
end

function showSmallIcon(self, wepId)
	for i=1,3 do
		self.weijihuo.need['mineId' .. i]:setVisible(false)
		self.jihuo.need['mineId' .. i]:setVisible(false)
	end
	self.weijihuo.need['mineId' .. wepId]:setVisible(true)
	self.jihuo.need['mineId' .. wepId]:setVisible(true)
end

function showWeaponIcon(self, wepId, quality)
	local prefix = ''
	if wepId == Define.WEP_JADE then
		prefix = 'yu'
	elseif wepId == Define.WEP_SWORD then
		prefix = 'jian'
	else
		prefix = 'jing'
	end
	if quality == 0 then
		quality = 1
	end

	if self.weaponIcon ~= nil then
		self.weaponIcon:stopAllActions()
		self.weaponIcon:removeFromParent()
	end
	
	self:addArmatureFrame("res/armature/effect/weaponEff/" .. prefix .. quality .. ".ExportJson")
	self.weaponIcon = Sprite.new()
	self.weaponIcon.name = 'weapon_icon'
	self:addChild(self.weaponIcon)
	self:runArrowAction(self.weaponIcon)
	self.weaponIcon:setPosition(self._skin.width/2 - 140, self._skin.height/2 + 20)

	local bone = ccs.Armature:create(prefix .. quality)
	bone:getAnimation():play("神兵",-1,-1)
	bone:setAnchorPoint(0.5,0.5)
	bone:setPosition(0, 0)
	self.weaponIcon._ccnode:addChild(bone)
	local wep = Weapon.getWep(wepId)
	if wep then
		bone = ccs.Armature:create(prefix .. quality)
		bone:getAnimation():play("Animation1",-1,-1)
		bone:setAnchorPoint(0.5,0.5)
		bone:setPosition(0, 0)
		self.weaponIcon._ccnode:setLocalZOrder(-1)
		self.weaponIcon._ccnode:addChild(bone)
	else
		Shader.setCascadeShader(self.weaponIcon._ccnode, Shader.SHADER_TYPE_GRAY)
	end
end

function showAlert(self)
	self.acquire:setVisible(true)
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
function showActiveEff(self)
	self:addArmatureFrame("res/armature/effect/weaponEff/WeaponActiveEff.ExportJson")
	local bone = ccs.Armature:create("WeaponActiveEff")
	bone:getAnimation():play("Animation1",-1,0)
	bone:setAnchorPoint(0.5,0.5)
	bone:setPosition(self.posXList[2], self.posYList[2])
	bone:setLocalZOrder(10)
	self._ccnode:addChild(bone)
end

function showLvUpEff(self)
	self:addArmatureFrame("res/armature/effect/weaponEff/WeaponLvUpEff.ExportJson")
	local bone = ccs.Armature:create("WeaponLvUpEff")
	bone:getAnimation():play("Animation1",-1,0)
	bone:setAnchorPoint(0.5,0.5)
	bone:setPosition(self.posXList[2], self.posYList[2] - 60)
	bone:setLocalZOrder(10)
	self._ccnode:addChild(bone)
end

function showUpEff(self)
	self:addArmatureFrame("res/armature/effect/weaponEff/WeaponUpEff.ExportJson")
	local bone = ccs.Armature:create("WeaponUpEff")
	bone:getAnimation():play("Animation1",-1,0)
	bone:setAnchorPoint(0.5,0.5)
	bone:setPosition(self.posXList[2] - 10, self.posYList[2])
	bone:setLocalZOrder(10)
	self._ccnode:addChild(bone)
end

function showFlyEff(self)
	local bone = ccs.Armature:create("SkillNameEffect")
	bone:getAnimation():play("技能",-1,0)
	bone:setAnchorPoint(0.5,0.5)
	bone:setPosition(self._skin.width - 320, Stage.height/2)
	bone:setLocalZOrder(10)
	self._ccnode:addChild(bone)
end

function onActiveWep(self, event)
	--self:flyText("点击激活 ".. currentWepId)
	Network.sendMsg(PacketID.CG_WEAPON_OPEN, currentWepId)
end

function onWepUpLv(self, event)
	local ui = UIManager.addChildUI("src/modules/weapon/ui/WeaponLvUpPanel")
	ui._ccnode:setLocalZOrder(10)
	ui:refreshWepLvUpInfo(currentWepId)
end

function onWepUpQuality(self, event)
	--self:flyText("点击升品 ".. currentWepId)
	Network.sendMsg(PacketID.CG_WEAPON_UP_QUALITY, currentWepId)
end

function onChangeWep(self, event)
	if self.selTarget ~= nil then
		self.selTarget.sblight:setVisible(false)
	end
	self.selTarget = event.target
	self.selTarget.sblight:setVisible(true)
	if event.target.name == "wq1" then
		self:setWep(Define.WEP_JADE)
	elseif event.target.name == "wq2" then
		self:setWep(Define.WEP_SWORD)
	elseif event.target.name == "wq3" then
		self:setWep(Define.WEP_MIRROR)
	end
end

function changeToWep(self, wepId)
	self.selTarget = self.wuqilist:getChild('wq' .. wepId)
	for i=1,3 do
		if i ~= wepId then
			self.wuqilist:getChild('wq' .. i).sblight:setVisible(false)
			self.wuqilist:getChild('wq' .. i):setSelected(false)
		else
			self.wuqilist:getChild('wq' .. i).sblight:setVisible(true)
		end
	end

	self.wuqilist:getChild("wq" .. wepId):setSelected(true)
	self:setWep(wepId)
end

function onClose(self,event)
	if event.etype == Event.Touch_ended then
		UIManager.removeUI(self)
	end
end

function onCloseAcquire(self, evt)
	if evt.etype == Event.Touch_ended then
		self.acquire:setVisible(false)
	end
end
