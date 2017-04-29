module("HeroInfoUI", package.seeall)
setmetatable(HeroInfoUI, {__index = Control})

local Def = require("src/modules/hero/HeroDefine")
local BagData = require("src/modules/bag/BagData")
local BagLogic = require("src/modules/bag/BagLogic")
local HeroQualityConfig = require("src/config/HeroQualityConfig").Config
local Hero = require("src/modules/hero/Hero")
local SkillLogic = require("src/modules/skill/SkillLogic")
local SkillDefine = require("src/modules/skill/SkillDefine")
local SkillGroupConfig = require("src/config/SkillGroupConfig").Config
local ItemConfig = require("src/config/ItemConfig").Config
local BaseMath = require("src/modules/public/BaseMath")
local StrengthDefine = require("src/modules/strength/StrengthDefine")
local StrengthLabel = require("src/modules/strength/ui/StrengthLabel")
local StrengthGrid = require("src/modules/strength/ui/StrengthGrid")
local StrengthLogic = require("src/modules/strength/StrengthLogic")
local PartnerData = require("src/modules/partner/PartnerData")
local ChainConfig = require("src/config/PartnerChainConfig").Config
local FightDefine = require("src/modules/fight/Define")
local ShopDefine = require("src/modules/shop/ShopDefine")
local GiftLogic = require("src/modules/gift/GiftLogic")
local TrainData = require("src/modules/train/TrainData")
local TrainLogic = require("src/modules/train/TrainLogic")
local TrainDefine = require("src/modules/train/TrainDefine")
local HeroBTConfig = require("src/config/HeroBreakthroughConfig").Config
local HeroCapacityConfig = require("src/config/HeroCapacityConfig").Config
local TrainConstConfig = require("src/config/TrainConstConfig").Config
local BagDefine = require("src/modules/bag/BagDefine")
local EquipLogic = require("src/modules/equip/EquipLogic")
local EquipItemConfig = require("src/config/EquipItemConfig").Config
local EquipOpenLvConfig = require("src/config/EquipOpenLvConfig").Config

function new(name,status)
	local ctrl = Control.new(require("res/hero/HeroInfoSkin"),{"res/hero/HeroInfo.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(name,status)
	Instance = ctrl
	return ctrl
end

function uiEffect()
	return UIManager.FIRST_TEMP_LABEL
end

function addStage(self)
	-- self:setWinCenter()
	self:setPositionY(Stage.uiBottom)
	--GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 1, groupId = GuideDefine.GUIDE_PARTNER_TALK})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 3, groupId = GuideDefine.GUIDE_EQUIP})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 7, groupId = GuideDefine.GUIDE_HERO_LV_UP})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 10, groupId = GuideDefine.GUIDE_HERO_LV_UP})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 4, groupId = GuideDefine.GUIDE_TRAIN})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 6, groupId = GuideDefine.GUIDE_TRAIN})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 8, groupId = GuideDefine.GUIDE_TRAIN})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 10, groupId = GuideDefine.GUIDE_TRAIN})
end

function refreshPartner(self,name)
	self:refreshBase()
	self:showCard()
	local list = self.attrgroup.partner.desc
	list:setBgVisiable(false)
	local hero2PartnerCfg = PartnerData.getHero2PartnerCfg()[name]
	if not hero2PartnerCfg or not hero2PartnerCfg.chain then
		return 
	end
	local cap = #hero2PartnerCfg.chain
	list:setItemNum(cap)
	for i = 1,cap do
		local chainId = hero2PartnerCfg.chain[i]
		if chainId then
			local chainCfg = ChainConfig[chainId]
			local attr
			local val 
			for k,v in pairs(chainCfg.attr) do
				attr = k
				val = v
				break
			end
			local str = string.format("【%s】：%s+%d%%",chainCfg.name,Def.DyAttrCName[attr],val)
			local ctrl = list:getItemByNum(i)
			ctrl.txtdesc1:setString(str)
			if PartnerData.checkChainActive(chainId) then
				ctrl.txtdesc1:setColor(168,86,38)
			else
				ctrl.txtdesc1:setColor(104,104,104)
			end
		end
	end
end
function prepareRadar(self)
	local name = self.name
	--单位值的半径
	local radar_skin = self.radar.radarBG1._skin
	local radius = ((radar_skin.width/2)/math.cos(math.pi/10))/10
	--圆心坐标
	local x,y = radar_skin.x+radar_skin.width/2,radar_skin.y+  radius*10*math.cos(math.pi/5)
	local radar_value = Def.DefineConfig[name].radar

	local conf = Def.DefineConfig[name]
	self.radar.txtweakness:setDimensions(self.radar.txtweakness._skin.width,0)
	self.radar.txtweakness:setHorizontalAlignment(Label.Alignment.Left)
	self.radar.txtweakness:setPositionY(self.radar.txtweakness._skin.y + self.radar.txtweakness._skin.height)
	self.radar.txtweakness:setAnchorPoint(0,1)
	self.radar.txtweakness:setString(conf.weakness)



	self.radar.txtadvantage:setString(conf.advantage)
	self.radar.txtscore:setString(conf.score)


	--转成世界坐标
	local worldPos = self.radar.radarBG1._ccnode:convertToWorldSpace(cc.p(x,y))

	local allPos = {}
	function getPos(length,angle)
		return cc.p(length*math.cos(angle),length*math.sin(angle))
	end
	table.insert(allPos,getPos(radius*radar_value.skill,math.pi/10))
	table.insert(allPos,getPos(radius*radar_value.final,math.pi/2))
	table.insert(allPos,getPos(radius*radar_value.recover,math.pi*9/10))
	table.insert(allPos,getPos(radius*radar_value.hp,math.pi*234/180))
	table.insert(allPos,getPos(radius*radar_value.atkSpeed,math.pi*306/180))

	self.radar._ccnode:removeChildByTag(1,true)
    local glNode  = gl.glNodeCreate()
    glNode:setContentSize(cc.size(radar_skin.width, radar_skin.height))
    glNode:setPosition(x,y)
    glNode:setAnchorPoint(cc.p(0, 0))
    function radarDraw(transform, transformUpdated)
       kmGLPushMatrix()
       kmGLLoadMatrix(transform)
       local color = cc.c4f(0.5, 0.5, 0, 0.1)
       for i=1,5 do 
       	cc.DrawPrimitives.drawSolidPoly( {allPos[i],allPos[i%5+1],cc.p(0,0)}, 3,  color)
       end
    	cc.DrawPrimitives.drawColor4B(255, 255, 0, 5)
    	cc.DrawPrimitives.drawPoly( allPos, 5, true)
       kmGLPopMatrix()
    end
    glNode:registerScriptDrawHandler(radarDraw)
    self.radar._ccnode:addChild(glNode,1,1)
end

function showBigCard(self,event,target)
	if event.etype == Event.Touch_began then
		self.touchCardBegan = true
	elseif event.etype == Event.Touch_out then
		self.touchCardBegan = false
	elseif self.touchCardBegan and event.etype == Event.Touch_ended then
		UIManager.setUITop(false)
		local hname = target.hname
		local spr = Sprite.new('bighero','res/hero/hicon/'..hname..".jpg")
		if spr then
			local mask = LayerColor.new('mask',0,0,0,255,Stage.width,Stage.height)
			mask.touchParent = false
			self:addChild(mask)
			mask:setTop()
			mask:setPositionY((self._skin.height-Stage.height)/2)
			local bigSize = spr:getContentSize()
			local smallSize = target:getContentSize()
			local initialScale = (smallSize.height) /bigSize.height
			local finalScale = (Stage.width/Stage.uiScale) / bigSize.height
			spr:setScale(initialScale)
			local x,y = target._ccnode:getPosition()
			local smallPos = cc.p(x,y)
			-- local smallWorldPos = self.illustration._ccnode:convertToWorldSpace(smallPos)
			-- Stage.currentScene:addChild(spr)
			-- spr:setPosition(smallWorldPos.x,smallWorldPos.y)
			self:addChild(spr)
			spr:setTop()
			spr:setPositionY(x/Stage.uiScale,y)
			spr.touchParent = false
			local fullScreenWidth = Stage.width
			local targetScale = target._skin
			local actionTime = 0.5
			local action01 = cc.RotateBy:create(actionTime,-90)
			-- local sineOut = cc.EaseSineOut:create(action01)
			local action02 = cc.MoveTo:create(actionTime,cc.p(fullScreenWidth/Stage.uiScale,0))

			local action03 = cc.ScaleTo:create(actionTime,finalScale)
			local action04 = cc.FadeIn:create(actionTime)
			spr:runAction(cc.Spawn:create({action01, action02,action03,action04}))

			local function onTouchCard(self,event,target)
				if event.etype == Event.Touch_ended and target._ccnode:getNumberOfRunningActions() == 0 then
					local a1 = cc.RotateBy:create(actionTime,90)
					local a2 = cc.MoveTo:create(actionTime,smallPos)
					local a3 = cc.ScaleTo:create(actionTime,initialScale)
					local a4 = cc.FadeOut:create(actionTime)
					local function cb(sender)
						spr:removeFromParent(true)
						UIManager.setUITop(true)
					end
					spr:runAction(cc.Sequence:create(cc.Spawn:create({a1, a2,a3,a4}),cc.CallFunc:create(cb)))

					self:removeChildByName('mask')
				end
			end
			spr:addEventListener(Event.TouchEvent,onTouchCard,self)
		end
	end
end

function showCard(self)
	local name = self.name
	local conf = Def.DefineConfig[name]
	local illu = self.illustration
	Common.setLabelCenter(illu.txtname)
	-- illu.txtname:setString(conf.cname)
	self.hero:showHeroNameLabel(illu.txtname)
	illu:removeChildByName('heroicon')
	
	for i=1,2 do 
		if conf.trendLocation == i then
			self.illustration['group'..i]:setVisible(true)
		else
			self.illustration['group'..i]:setVisible(false)
		end
	end
	for i=1,4 do 
		if i == conf.wanfa then
			self.illustration['group'..conf.trendLocation]['wanfa'..i]:setVisible(true)
		else
			self.illustration['group'..conf.trendLocation]['wanfa'..i]:setVisible(false)
		end
	end
	for i=1,6 do 
		local t = self.illustration['group'..conf.trendLocation]['trend'..i]
		if i == conf.trend then
			t:setVisible(true)
		else
			t:setVisible(false)
		end
	end
	for i=1,5 do 
		local b = self.illustration['group'..conf.trendLocation]['sbg'..i]
		if i == self.hero.quality then
			b:setVisible(true)
		else
			b:setVisible(false)
		end
	end
	if illu:getChild('heroicon') == nil then
		local spr = Sprite.new('heroicon','res/hero/cicon/'..name..".jpg")
		if spr then
			illu:addChild(spr)
			local size = illu:getContentSize()
			spr:setPosition(size.width/2,size.height/2)
			spr:setAnchorPoint(0.5,0.5)
			spr._ccnode:setLocalZOrder(-1)
			spr:setScale(0.99)
			spr.hname = name
			spr:addEventListener(Event.TouchEvent,showBigCard,self)
		end
	end
	for i=1,5 do
		if i == conf.career then
			illu.careericon['careericon'..i]:setVisible(true)
		else
			illu.careericon['careericon'..i]:setVisible(false)
		end
	end
	local hero = Hero.getHero(name)
	for i=1,5 do
		if i <= hero.quality then
			illu.staricon['star'..i]:setVisible(true)
		else
			illu.staricon['star'..i]:setVisible(false)
		end
	end
	illu:removeChildByName("qualitybg")
	--local transferLv = hero.strength.transferLv + 1
	local bgspr = Sprite.new("qualitybg","res/hero/cicon/qualitybg"..hero.quality..".png")
	if bgspr then
		illu:addChild(bgspr)
		bgspr:setPosition(illu.herobg:getPosition())
		bgspr.touchEnabled = false
	end
	illu.txtlv:setString(hero.lv)
	illu.staricon:setTop()
	illu.careericon:setTop()
	illu.txtname:setTop()
	-- local q = Def.HERO_QUALITY[hero.quality]
	-- illu.txtname:setColor(q.r,q.g,q.b)
	illu.txtlv:setTop()
end

function refreshStar(self)
	local hero = self.hero
	local attr = self.attrgroup
	if hero.quality >= Def.MAX_QUALITY then
		-- attr.frag.upgrade:setEnabled(false)
		attr.frag.txtfrag:setVisible(false)
		attr.frag.expprog:setPercent(100)
		attr.frag.maxstar:setVisible(true)
		attr.frag.upgrade:setVisible(false)
	else
		-- attr.frag.upgrade:setEnabled(true)
		local fragment = BaseMath.getHeroQualityFrag(name,hero.quality+1)
		local fragNum = BagData.getItemNumByItemId(hero.fragId)
		attr.frag.txtfrag:setString(fragNum.."/"..fragment)
		attr.frag.txtfrag:setVisible(true)
		local percent = math.min(fragNum/fragment*100,100)
		attr.frag.expprog:setPercent(percent)
		attr.frag.maxstar:setVisible(false)
		attr.frag.upgrade:setVisible(true)
	end
end

function refreshBase(self)
	local hero = self.hero
	local name = self.name
	local attr = self.attrgroup
	local conf = Def.DefineConfig[self.name]
	if Dot.check(self.heroinforbg.diamond,"strengthHero",self.hero)
		or Dot.check(self.heroinforbg.diamond,"transferHero",self.hero) then
	end
	self:refreshStar()
	attr.lv.txtlv:setString(tostring(hero.lv))
	-- attr.career.txtcareer:setString(hero.careerName)
	attr.fragtips:setVisible(false)
	local fightPower = hero:getFight()
	attr.power.txtpower:setString(tostring(fightPower))
	-- attr.txtname:setString(hero.cname)
	hero:showHeroNameLabel(attr.txtname)
	attr.txtexp:setString(hero.exp..'/'..(hero:getExpForNextLv() or "*"))
	for i=1,Def.MAX_QUALITY do
		attr.staricon['star'..i]:setVisible(false)
		if hero.quality >= i then
			attr.staricon['star'..i]:setVisible(true)
		end
	end
	Dot.check(self.attrgroup.frag.upgrade,'isStarUpEnabled',name)
	Dot.check(self.heroinforbg.base,'isStarUpEnabled',name)
	Dot.check(self.heroinforbg.bt,"isBreakThroughEnabled",name)
	self:refreshEquip()
	--self:refreshSkill()
	self:showCard()
	self:loadArm(name)

	-- for i=1,6 do
	-- 	if conf.trend == i then
	-- 		attr.zhaoshi['zs'..i]:setVisible(true)
	-- 	else
	-- 		attr.zhaoshi['zs'..i]:setVisible(false)
	-- 	end
	-- end
end


-- function playArmActionCB(self,name)
-- 	self.actionReady = true
-- 	playArm(self,name)
-- end

-- function playArm(self,name)
-- 	if self.actionReady then
-- 		local loader = AsyncLoader.new()
-- 		self.loaderReady = false
-- 		loader:addEventListener(loader.Event.Load,function(self,event) 
-- 		if event.etype == AsyncLoader.Event.Finish then
-- 			if self.alive then
-- 				self:addArmatureFrame(string.format("res/armature/%s/%s.ExportJson",string.lower(name),name))
-- 				if self.arm then
-- 					self.attrgroup._ccnode:removeChild(self.arm)
-- 				end
-- 				self.arm = ccs.Armature:create(name)
-- 				local armScale = 150/self.arm:getContentSize().width
-- 				armScale = 0.75
-- 				self.arm:setScale(armScale)
-- 				self.attrgroup._ccnode:addChild(self.arm)
-- 				local bgposx,bgposy = self.attrgroup.armbg:getPosition()
-- 				local armposx = bgposx + self.attrgroup.armbg:getContentSize().width/2
-- 				local armposy = bgposy + 20
-- 				self.arm:setPosition(cc.p(armposx,armposy))
-- 				self.armAniFlag = true
-- 				local function onTouchArm(self,event,target)
-- 					if event.etype == Event.Touch_ended then
-- 						if self.armAniFlag then
-- 							self.arm:getAnimation():playWithNames({'胜利'},0,false)
-- 						else
-- 							self.arm:getAnimation():playWithNames({'胜利'},0,false)
-- 						end
-- 						self.armAniFlag = not self.armAniFlag
-- 					end
-- 				end
-- 				local px,py = self.attrgroup.armbg:getPosition()
-- 				local size = self.attrgroup.armbg:getContentSize()
-- 				self.herolvupEffect:retain()
-- 				self.herolvupEffect:removeFromParent()
-- 				self.attrgroup._ccnode:addChild(self.herolvupEffect)
-- 				self.herolvupEffect:release()
-- 				self.herolvupEffect:setPosition(px+size.width/2-6,py+size.height/8)


-- 				self.arm:getAnimation():playWithNames({'胜利'},0,false)
-- 				self.attrgroup.armbg.touchEnabled = true
-- 				self.attrgroup.armbg.touchParent = true
-- 				self.attrgroup.armbg:addEventListener(Event.TouchEvent,onTouchArm,self)
-- 				self.attrgroup.armbg:dispatchEvent(Event.TouchEvent,{etype=Event.Touch_ended})
-- 				self.arm:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID) 
-- 					if movementType == ccs.MovementEventType.complete then
-- 						self.arm:getAnimation():playWithNames({'待机'},0,true)
-- 					end
-- 				end)
-- 			else
-- 				loader:removeAllArmatureFileInfo()
-- 			end
-- 		end
-- 	end,self)
-- 	loader:addArmatureFileInfo(string.format("res/armature/%s/%s.ExportJson",string.lower(name),name))
-- 	loader:start()
-- 	end
-- end

function refreshHero(self,name)
	cc.Director:getInstance():getTextureCache():removeTextureForKey(png)
	self.name = name
	self.hero = Hero.getHero(name)
	if self.status == "base" then
		self.attrgroup.fragtips:setVisible(false)
		self:refreshBase()
	elseif self.status == "up" then
		self:refreshLvUp()
	elseif self.status == "partner" then
		self:refreshPartner(self.name)
	elseif self.status == "diamond" then
		self:refreshStrength()
	elseif self.status == "gift" then
		GiftLogic.refreshGift(self)
	elseif self.status == "details" then
		self:refreshDetails()
	elseif self.status == "break" then
		self:refreshBreak()
	elseif self.status == "train" then
		self:refreshTrain()
	end
end

function setOldAttr(self)
	self.oldHp = self.hero.dyAttr.maxHp
	self.oldAtkSpeed = self.hero.dyAttr.atkSpeed
	self.oldAtk = self.hero.dyAttr.atk
	self.oldDef = self.hero.dyAttr.def
	self.oldFight = self.hero:getFight()
end
function showQualityUpPanel(self,newQuality)
	local btnAnimation = ccs.Armature:create('heroup')
	local rSize = self.attrgroup.armbg:getContentSize()
	btnAnimation:getAnimation():playWithNames({"成功进阶"},0,false)
	btnAnimation:setAnchorPoint(0.5,0)
	btnAnimation:setPosition(rSize.width/2,20)
	self.attrgroup.armbg._ccnode:addChild(btnAnimation)
	UIManager.playMusic('expUp')



	-- self.heroupEffect:getAnimation():playWithNames({"成功进阶"},0,false)
    btnAnimation:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID) 
		if movementType == ccs.MovementEventType.complete then
			--self.qualityuppanel:setVisible(true)
			-- ActionUI.show(self.qualityuppanel,"scale")
			local ui = require("src/modules/hero/ui/HeroInfoUI").Instance
			if ui then
				ui:refreshHero(self.name)
				local hero = Hero.getHero(self.name)
				--ui:showQualityUpPanel(quality)
				local attrs = {
					{name="star",src=hero.quality-1,dst=hero.quality},
					{name="atkSpeed",src=ui.oldAtkSpeed,dst=ui.hero.dyAttr.atkSpeed},
					{name="maxHp",src=ui.oldHp,dst=ui.hero.dyAttr.maxHp},
					{name="atk",src=ui.oldAtk,dst=ui.hero.dyAttr.atk},
					{name="def",src=ui.oldDef,dst=ui.hero.dyAttr.def},
				}
				local ui = require("src/ui/LvUpUI").new(self.name,attrs,"starup")
				UIManager.playMusic('lvUp')
				Stage.currentScene:addChild(ui)
			end
		end
	end)
    Dot.check(self.attrgroup.frag.upgrade,'isStarUpEnabled',self.name)
    Dot.check(self.heroinforbg.base,'isStarUpEnabled',name)
	
end

function onOpenEquip(self, event, target)
	if event.etype == Event.Touch_ended then
		UIManager.addChildUI("src/modules/equip/ui/EquipInfoUI", self.name, target.pos)
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_EQUIP, step = 4})
		--print("UIManager.addChildUI src/modules/equip/ui/EquipInfoUI", self.name, target.pos)
	end
end

function refreshEquip(self)
	local eq = self.attrgroup.zhuangbei
	local hero = self.hero
	local name = self.name
	local cfg = EquipItemConfig[name]
	for i = 1, 4 do 
		local zb = eq["zb" .. i]
		zb.pos = i

		local grid = zb.herobg2
		CommonGrid.bind(grid, "tips")
		local id = cfg["item" .. i]
		if not ItemConfig[id] then
			id = 1101001 --缺配置
		end
		grid:setItemIcon(id)
		local equip = EquipLogic.getEquip(name, i)
		grid:setItemColor(equip.c)
		--grid:setItemNum(equip.lv)

		zb:removeEventListener(Event.TouchEvent, onOpenEquip)
		if i == 1 then
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=zb, step = 4, groupId = GuideDefine.GUIDE_EQUIP})
		end

		local openlv = EquipOpenLvConfig[i].openlv
		if not zb.dj then
			local lvTxt = cc.Label:createWithBMFont("res/common/vipLevelNum.fnt", openlv)
			--local lvTxt = cc.LabelAtlas:_create("7698325401", "res/common/vipLevelNum.png", 13, 19, string.byte('0'))
			--lvTxt:setString(tostring(openlv))
			lvTxt:setPosition(zb.ji._skin.x, zb.ji._skin.y)
			lvTxt:setAnchorPoint(1.0, 0)
			zb._ccnode:addChild(lvTxt)
			zb.dj = lvTxt
		end

		if hero.lv < openlv then
			zb.zhedang:setVisible(true)
			zb.dj:setVisible(true)
			zb.kq:setVisible(true)
			zb.ji:setVisible(true)
			zb.txtlv:setVisible(false)
		else
			zb.zhedang:setVisible(false)
			zb.dj:setVisible(false)
			zb.kq:setVisible(false)
			zb.ji:setVisible(false)
			zb.txtlv:setVisible(true)
			zb.txtlv:setString(equip.lv)
			local skin = zb.txtlv:getSkin()
			zb.txtlv:setPositionX(skin.x + skin.width - zb.txtlv:getContentSize().width)
			zb:addEventListener(Event.TouchEvent, onOpenEquip, self)
		end
	end
end

function refreshSkill(self)
	local skillList = SkillLogic.getEquipSkillGroup(self.hero)
	for i=1,3 do
		if skillList[i] then
			CommonGrid.bind(self.attrgroup.skill['skill'..i].skillbg)
			self.attrgroup.skill['skill'..i].skillbg:setSkillGroupIcon(skillList[i].groupId,65)
			self.attrgroup.skill['skill'..i].skillbg:setItemNum(skillList[i].lv)
			self.attrgroup.skill['skill'..i].skillbg._num:setPositionY(48)
			self.attrgroup.skill['skill'..i].skillbg:addEventListener(Event.TouchEvent,function (self,event,target) 
				if event.etype == Event.Touch_ended then
					UIManager.addUI("src/modules/skill/ui/SkillListUI",self.name,"normal")
				end
			end,self)
		end
	end
	if skillList[4] then
		local comboSkill = SkillLogic.getSkillGroup(self.hero,SkillDefine.TYPE_COMBO)
		CommonGrid.bind(self.attrgroup.skill.skill4.skillbg)
		self.attrgroup.skill.skill4.skillbg:setSkillGroupIcon(comboSkill.groupId,65)
		self.attrgroup.skill.skill4.skillbg:setItemNum(comboSkill.lv)
		self.attrgroup.skill.skill4.skillbg._num:setPositionY(48)
		self.attrgroup.skill.skill4.skillbg:addEventListener(Event.TouchEvent,function (self,event,target) 
			if event.etype == Event.Touch_ended then
				UIManager.addUI("src/modules/skill/ui/SkillListUI",self.name,"rage")
			end
		end,self)
	end

	local finalSkill = SkillLogic.getSkillGroup(self.hero,SkillDefine.TYPE_FINAL)
	CommonGrid.bind(self.attrgroup.skill.skill5.skillbg)
	if finalSkill then
		self.attrgroup.skill.skill5.skillbg:setSkillGroupIcon(finalSkill.groupId,65)
		self.attrgroup.skill.skill5.skillbg:setItemNum(finalSkill.lv)
		self.attrgroup.skill.skill5.skillbg._num:setPositionY(48)
		self.attrgroup.skill.skill5.skillbg:addEventListener(Event.TouchEvent,function (self,event,target) 
			if event.etype == Event.Touch_ended then
				UIManager.addUI("src/modules/skill/ui/SkillListUI",self.name,"rage")
			end
		end,self)
	end
	local assistSkill = SkillLogic.getSkillGroup(self.hero,SkillDefine.TYPE_ASSIST)
	CommonGrid.bind(self.attrgroup.skill.skill6.skillbg)
	if assistSkill then
		self.attrgroup.skill.skill6.skillbg:setSkillGroupIcon(assistSkill.groupId,65)
		self.attrgroup.skill.skill6.skillbg:setItemNum(assistSkill.lv)
		self.attrgroup.skill.skill6.skillbg._num:setPositionY(48)
		self.attrgroup.skill.skill6.skillbg:addEventListener(Event.TouchEvent,function (self,event,target) 
			if event.etype == Event.Touch_ended then
				UIManager.addUI("src/modules/skill/ui/SkillListUI",self.name,"assist")
			end
		end,self)
	end
end

function refreshLvUp(self)
	local hero = self.hero
	self:showCard()
	self:refreshBase()
	local percent = 100*self.hero.exp/self.hero:getExpForNextLv()
	self.attrgroup.lvup.txtexp:setString(self.hero.exp.."/"..self.hero:getExpForNextLv())
	self.attrgroup.lvup.explongprog:setPercent(percent)
	self.attrgroup.lvup.txtlv:setString('lv'..self.hero.lv)
	local nextExp = hero:getExpForNextLv()
	if hero.lv >= Def.MAX_LEVEL then
		self.attrgroup.lvup.fullexp:setVisible(false)
		self.attrgroup.lvup.maxlv:setVisible(true)
	elseif hero.lv >= Master:getInstance().lv and hero.exp == nextExp then
		self.attrgroup.lvup.fullexp:setVisible(true)
		self.attrgroup.lvup.maxlv:setVisible(false)
	else
		self.attrgroup.lvup.fullexp:setVisible(false)
		self.attrgroup.lvup.maxlv:setVisible(false)
	end

	self.attrgroup.lvup.maxlv:setVisible(false)
	self.attrgroup.lvup.fullexp:setVisible(false)

	self:refreshItemCnt()
end



function onBagRefresh(self,event,target)
	self:refreshItemCnt()
end

function refreshItemCnt(self)
	-- local up = self.attrgroup.lvup
	-- for i=1,3 do
	-- 	local itemId = Def.EXP_MEDICINE[i]
	-- 	local num = BagData.getItemNumByItemId(itemId)
	-- 	up['exp'..i].txtnum:setString(tostring(num))
	-- end
	if self.train then
		local num = BagData.getItemNumByItemId(TrainDefine.ITEM_ID)
		self.train.down.txtyynljh:setString(string.format("%d",num))
	end
end

function initBreak(self)
	if self.capacity then
		self.capacity:removeFromParent()
		self.capacity = nil
	end
	if self.breakthrough then
		self.breakthrough:removeFromParent()
		self.breakthrough = nil
	end
	if self.breakNode then
		Control.clear(self.breakNode)
		self.breakNode = nil
	end
		local name = self.name
		local hero = self.hero
		self.breakNode = Control.new(require("res/hero/HeroInfobreakSkin"),{"res/hero/HeroInfobreak.plist","res/common/an.plist"})
		self:addArmatureFrame("res/hero/effect/break/breakEffect.ExportJson")
		self.capacity = self.breakNode.capacity
		self.capacity._ccnode:retain()
		self.breakNode:removeChild(self.capacity,false)
		self:addChild(self.capacity)
		self.capacity._ccnode:release()

		self.breakthrough = self.breakNode.breakthrough
		self.breakthrough._ccnode:retain()
		self.breakNode:removeChild(self.breakthrough,false)
		self:addChild(self.breakthrough)
		self.breakthrough._ccnode:release()

		CommonGrid.bind(self.breakthrough.bottom.stonegrid,true)
		self.breakthrough.bottom.stonegrid:setItemIcon(Def.BREAK_STONE_ID)
		Common.setLabelCenter(self.breakthrough.prevhero.namelv)
		Common.setLabelCenter(self.breakthrough.posthero.namelv)
		Common.setLabelCenter(self.breakthrough.prevhero.txtlvdemand)
		Common.setLabelCenter(self.breakthrough.prevhero.txtstardemand)
		Common.setLabelCenter(self.breakthrough.posthero.txtinfo)

		self.breakthrough.posthero.txtunlock:setDimensions(self.breakthrough.posthero.txtunlock._skin.width,0)
		self.breakthrough.posthero.txtunlock:setHorizontalAlignment(Label.Alignment.Center)
		function onBreak(self,event,target)
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_HERO_LV_UP, step = 9})
			local hero = self.hero
			if hero.btLv >= Def.MAX_BT then
				Common.showMsg("本英雄已达到最高突破等级")
				return
			end
			local targetLv = hero.btLv + 1
			local heroLvRequired,stoneCntRequired,moneyRequired,heroStarRequired = Hero.getBTLvInfo(targetLv)

			if hero.lv < heroLvRequired then
				Common.showMsg("需要英雄等级达到"..heroLvRequired.."级")
				return
			end
			if hero.quality < heroStarRequired then
				Common.showMsg("需要英雄星级达到"..heroStarRequired.."级")
				return
			end
			local stoneCnt = BagData.getItemNumByItemId(Def.BREAK_STONE_ID)
			if stoneCnt < stoneCntRequired then
				Common.showMsg("突破石不足")
				return
			end
			if Master.getInstance().money < moneyRequired then
				Common.showMsg("金币不足")
				return
			end
			Network.sendMsg(PacketID.CG_HERO_BREAKTHROUGH,hero.name)
		end
		self.breakthrough.bottom.breakthrough:addEventListener(Event.Click,onBreak,self)
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.breakthrough.bottom.breakthrough, nextTime = 0.3, step = 9, groupId = GuideDefine.GUIDE_HERO_LV_UP})
		self.capacity.qianli:setBgVisiable(false)
		-- Control.clear(self.breakNode)
		-- self.breakNode = nil
end

function showBreakSuccess(self,name,btLv)
	UIManager.addChildUI("src/modules/hero/ui/HeroBTUI",self.name,btLv)
end
function refreshBreak(self)
	Dot.check(self.heroinforbg.bt,"isBreakThroughEnabled",self.name)
	local name = self.name
	if self.capacity == nil or self.breakthrough == nil then
		self:initBreak()
	end
	local hero = Hero.getHero(name)
	local conf = Def.DefineConfig[name]

	local curBreak = hero.btLv
	local nextBreak = hero.btLv + 1

	if nextBreak > Def.MAX_BT then
		nextBreak = Def.MAX_BT
	end
	local master = Master.getInstance()
	local heroLv,stoneNum,money,heroStar = Hero.getBTLvInfo(curBreak+1)
	if heroLv then
		local stoneCnt = BagData.getItemNumByItemId(Def.BREAK_STONE_ID)
		self.breakthrough.bottom.txtstone:setString(stoneCnt.."/"..stoneNum)
		self.breakthrough.bottom.money:setString(money)
		if stoneCnt >= stoneNum then
			self.breakthrough.bottom.txtstone:setColor(68,160,0)
		else
			self.breakthrough.bottom.txtstone:setColor(203,76,63)
		end

		if master.money >= money then
			self.breakthrough.bottom.money:setColor(68,160,0)
		else
			self.breakthrough.bottom.money:setColor(203,76,63)
		end
	end
	
	local function heroCtrl(ctrl,conf,btLv)
		self.hero:showHeroNameLabel(ctrl.namelv,btLv)
		-- ctrl.namelv:setString(conf.cname.." +"..btLv)
		-- local q = Def.HERO_QUALITY[self.hero.quality]
		-- ctrl.namelv:setColor(q.r,q.g,q.b)
		attrGroup = {}
		for i,attr in ipairs({"atk","def","finalAtk","finalDef","maxHp"}) do
			if attrGroup[attr] == nil then attrGroup[attr] = 0 end
			attrGroup[attr] = Hero.getBTAttr(attr,btLv)
			ctrl.attrgroup[attr]:setString(attrGroup[attr])
		end

		self:addArmatureFrame(string.format("res/armature/%s/small/%s.ExportJson",string.lower(name),name))
		if ctrl.arm then
			ctrl._ccnode:removeChild(ctrl.arm)
		end
		ctrl.arm = ccs.Armature:create(name)
		ctrl.arm:setScale(0.6)

		if ctrl.effect then
			ctrl._ccnode:removeChild(ctrl.effect)
			ctrl.effect = nil
		end
		local aniName = Hero.getBTAnimation(btLv)
		if aniName then
			local px,py = ctrl.armbg:getPosition()
			local size = ctrl.armbg:getContentSize()
			ctrl.effect= ccs.Armature:create('breakEffect')
			ctrl._ccnode:addChild(ctrl.effect)
			ctrl.effect:getAnimation():playWithNames({aniName},0,true)
			ctrl.effect:setPosition(px+size.width/2,py+size.height/2)
			ctrl.effect:setScale(0.6)
		end





		ctrl._ccnode:addChild(ctrl.arm)
		local bgposx,bgposy = ctrl.armbg:getPosition()
		local armposx = bgposx + ctrl.armbg:getContentSize().width/2
		local armposy = bgposy + 20
		ctrl.arm:setPosition(cc.p(armposx,armposy+10))
		ctrl.arm:getAnimation():playWithNames({'待机'},0,true)
	end
	heroCtrl(self.breakthrough.prevhero,conf,curBreak)
	heroCtrl(self.breakthrough.posthero,conf,nextBreak,true)
	local lvstr = '需要等级：'..heroLv
	self.breakthrough.prevhero.txtlvdemand:setString(lvstr)
	if hero.lv < heroLv then
		self.breakthrough.prevhero.txtlvdemand:setColor(203,76,63)
	else
		self.breakthrough.prevhero.txtlvdemand:setColor(68,160,0)
	end
	local starstr = '需要星级：'..heroStar
	self.breakthrough.prevhero.txtstardemand:setString(starstr)
	if hero.quality < heroStar then
		self.breakthrough.prevhero.txtstardemand:setColor(203,76,63)
	else
		self.breakthrough.prevhero.txtstardemand:setColor(68,160,0)
	end
	local capacity = Hero.getHeroBTList(name)[nextBreak]
	if capacity and capacity > 0 then
		self.breakthrough.posthero.txtinfo:setString(HeroCapacityConfig[capacity].desc)
		-- self.breakthrough.posthero.txtinfo:setDimensions(self.breakthrough.posthero.txtinfo._skin.width,0)
		-- self.breakthrough.posthero.txtinfo:setHorizontalAlignment(Label.Alignment.Left)
		-- self.breakthrough.posthero.txtinfo:setPositionY(self.breakthrough.posthero.txtinfo._skin.y + self.breakthrough.posthero.txtinfo._skin.height)
		-- self.breakthrough.posthero.txtinfo:setAnchorPoint(0,1)
		
		
		self.breakthrough.posthero.txtunlock:setString("解锁潜力 ︵"..HeroCapacityConfig[capacity].name.."︶")
	end

	self.capacity.qianli:setItemNum(0)
	local btList = Hero.getHeroBTList(name)
	for i,capacityId in ipairs(btList) do
		if capacityId > 0 then
			local no = self.capacity.qianli:addItem()
			local item = self.capacity.qianli.itemContainer[no]
			item.txttitle:setString(HeroCapacityConfig[capacityId].name)
			item.txtcontent:setString(HeroCapacityConfig[capacityId].desc)
			item.txtcontent:setDimensions(item.txtcontent._skin.width,0)
			item.txtcontent:setHorizontalAlignment(Label.Alignment.Left)
			item.txtcontent:setPositionY(item.txtcontent._skin.y + item.txtcontent._skin.height)
			item.txtcontent:setAnchorPoint(0,1)
			if i > curBreak then
				item.txttitle:setColor(205,184,166)
				item.txtcontent:setColor(205,184,166)
			end
			-- if i == curBreak and i < #btList then
			-- 	item.ge2:setVisible(true)
			-- else
			-- 	item.ge2:setVisible(false)
			-- end
			item.ge2:setVisible(false)
		end
	end


end


function initDetail(self)
	if self.radar == nil or self.detailpanel==nil then
		self.detailNode = Control.new(require("res/hero/HeroInfoDetailSkin"),{"res/hero/HeroInfoDetail.plist","res/common/an.plist"})
		local radar = self.detailNode.radar
		radar._ccnode:retain()
		self.detailNode:removeChild(radar,false)
		self:addChild(radar)
		radar._ccnode:release()
		self.radar = radar
		
		local detailpanel = self.detailNode.detailpanel
		detailpanel._ccnode:retain()
		self.detailNode:removeChild(detailpanel,false)
		detailpanel._ccnode:release()
		self.detailpanel = detailpanel
		self:addChild(self.detailpanel)
		self.heroinforbg:setTop()
	end
end


function refreshDetails(self)
	local name = self.name
	self:initDetail()
	local hero = Hero.getHero(name)
	local d = self.detailpanel
	d.maxhp:setString(hero.dyAttr.maxHp)
	d.rageR:setString(hero.dyAttr.rageR)
	-- d.assistR:setString(hero.dyAttr.assist)
	d.hpR:setString(hero.dyAttr.hpR)
	d.atk:setString(hero.dyAttr.atk)
	d.def:setString(hero.dyAttr.def)
	d.atkspeed:setString(hero.dyAttr.atkSpeed)
	d.crthit:setString(hero.dyAttr.crthit)
	d.anticrthit:setString(hero.dyAttr.antiCrthit)
	d.block:setString(hero.dyAttr.block)
	d.antiblock:setString(hero.dyAttr.antiBlock)
	d.finalatk:setString(hero.dyAttr.finalAtk)
	d.finaldef:setString(hero.dyAttr.finalDef)

	local conf = Def.DefineConfig[hero.name]
	local width = d.intro._skin.width - 10
	local skin = 
    {name="introSV",type="Label",x=10,y=0,width=width,height=0,
        {name="txtexp",status="",txt="经验：4578/9876",font="HYe3gj",size=17,bold=false,italic=false,color={177,67,0}},
    }
	local txt = Label.new(skin)
	txt:setDimensions(skin.width,0)
	txt:setString(conf.intro)
	d.intro:clearMoveNode()
	d.intro:setMoveNode(txt)
	d.intro:getChild("introbg"):setVisible(false)
	
	Common.setLabelCenter(d.txtname)
	hero:showHeroNameLabel(d.txtname)
	-- d.txtname:setString(hero.cname)
	self:prepareRadar()
end

function initTrain(self)
	if self.train == nil then
		self:addArmatureFrame('res/train/effect/Train.ExportJson')
		self:addArmatureFrame('res/train/effect/TrainBar.ExportJson')
		self.trainNode = Control.new(require("res/train/HeroInfoTrainSkin"),{"res/train/HeroInfoTrain.plist","res/common/an.plist"})
		local train = self.trainNode.train
		train._ccnode:retain()
		self.trainNode:removeChild(train,false)
		self:addChild(train)
		train._ccnode:release()
		self.train = train
		self.heroinforbg:setTop()
		function onTrain(self,event,target)
			local cnt = self.train.down.sz:getString()
			Network.sendMsg(PacketID.CG_TRAIN,self.name,self.train.selectId,tonumber(cnt))
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_TRAIN, step = 5})
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_TRAIN, step = 7})
		end
		function onAdd(self,event,target)
			Network.sendMsg(PacketID.CG_TRAIN_ADD,self.name)
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_TRAIN, step = 9})
		end
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.train.down.train, step = 5, groupId = GuideDefine.GUIDE_TRAIN})
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.train.down.train, step = 7, groupId = GuideDefine.GUIDE_TRAIN})
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.train.down.add, step = 9, groupId = GuideDefine.GUIDE_TRAIN})
		self.train.down.train:addEventListener(Event.Click,onTrain,self)
		self.train.down.add:addEventListener(Event.Click,onAdd,self)
		function onSelectOption(self,event,target)
			self.train.selectId = target.regionId
		end
		for i = 1,3 do
			self.train.down.selecttype["region"..i]:addEventListener(Event.Click,onSelectOption,self)
			self.train.down.selecttype['region'..i].regionId = i
		end

		local function setCostCnt(self,cnt)
			local num = TrainConstConfig[1]['material1'][BagDefine.ITEM_ID_TRAIN]
			self.train.down.selecttype['region1'].ptpy.txtsz:setString(num*cnt)
			local num2 = TrainConstConfig[1]['material2'][BagDefine.ITEM_ID_TRAIN]
			self.train.down.selecttype['region2'].jbpy.txtsz:setString(num2*cnt)
			local money = TrainConstConfig[1]['material2'][BagDefine.ITEM_ID_MONEY]
			self.train.down.selecttype['region2'].jbpy.txtjb:setString(money*cnt)
			local num3 = TrainConstConfig[1]['material3'][BagDefine.ITEM_ID_TRAIN]
			self.train.down.selecttype['region3'].zspy.txtsz:setString(num3*cnt)
			local rmb = TrainConstConfig[1]['material3'][BagDefine.ITEM_ID_RMB]
			self.train.down.selecttype['region3'].zspy.txtzssl:setString(rmb*cnt)
		end
		setCostCnt(self,1)

		self.train.selectId = 1
		self.train.down.selecttype['region1']:setSelected(true)
		local function onLeft(self,event,target)
			if self.train.cntId > 1 then
				self.train.cntId = self.train.cntId - 1
			end
			local cnt = TrainDefine.TrainCnt[self.train.cntId]
			self.train.down.sz:setString(cnt)
			setCostCnt(self,cnt)
		end
		local function onRight(self,event,target)
			if self.train.cntId < 3 then
				self.train.cntId = self.train.cntId + 1
			end
			local cnt = TrainDefine.TrainCnt[self.train.cntId]
			self.train.down.sz:setString(cnt)
			setCostCnt(self,cnt)
		end
		self.train.down.sz:setAnchorPoint(0.5,0)
		self.train.down.left:addEventListener(Event.Click,onLeft,self)
		self.train.down.right:addEventListener(Event.Click,onRight,self)
		local num = BagData.getItemNumByItemId(TrainDefine.ITEM_ID)
		self.train.down.txtyynljh:setString(string.format("%d",num))
		self.train.cntId = 1
		local cnt = TrainDefine.TrainCnt[self.train.cntId]
		self.train.down.sz:setString(cnt)
		local up = self.train.up
		for i = 1,5 do
			up["nature"..i].tips = Common.setBtnAnimation(up["nature"..i]._ccnode,"Train","提升",{x=26,y=47})
			up["nature"..i].tips:setVisible(false)
			local clipNode = cc.ClippingNode:create()
			clipNode:setInverted(false)
			stencil = Sprite.new('bg','res/train/bgClip.png')
			clipNode:setStencil(stencil._ccnode)
			clipNode:setAlphaThreshold(0.05)
			up["nature"..i].expprog.clipNode = clipNode
			up["nature"..i].expprog._ccnode:addChild(clipNode)
		end
	end
end

function refreshTrain(self,name)
	local name = self.name
	self:showCard()
	self:initTrain()
	self:refreshTrainInfo()
end

function refreshTrainInfo(self)
	local cName = Hero.getCNameByName(self.name)
	-- self.train.txtname:setString(cName)
	self.hero:showHeroNameLabel(self.train.txtname)
	local up = self.train.up
	if not TrainLogic.getTrainLimitConfig()[self.name] then
		return 
	end
	local base = TrainData.getBase(self.name)
	local cfg = TrainLogic.getTrainLimitConfig()[self.name][self.hero.lv]
	if cfg then
		local hasDown = false
		local hasUp = false
		for i = 1,5 do
			local limit = cfg.limit
			local baseMax = limit[base[i].name]
			up["nature"..i].pt:setAnchorPoint(0.5,0)
			up["nature"..i].pt:setString(string.format("%d/%d",base[i].val,baseMax))
			up["nature"..i].expprog:setBarChangeRate(cc.p(0,1))
			local percent = base[i].val/baseMax
			up["nature"..i].expprog:setPercent(percent*100)
			local rSize = up["nature"..i].expprog:getContentSize()
			if not up["nature"..i].expprog.ani then
				up["nature"..i].expprog.ani = Common.setBtnAnimation(up["nature"..i]._ccnode,"TrainBar","泡",{x=-10,y=-10})
				up["nature"..i].expprog.ani2 = Common.setBtnAnimation(up["nature"..i].expprog.clipNode,"TrainBar","波动",{x=40,y=rSize.height/2-60+percent*65})
			else
				up["nature"..i].expprog.ani:getAnimation():play("泡",1,-1)
				up["nature"..i].expprog.ani2:getAnimation():play("波动",1,-1)
				up["nature"..i].expprog.ani2:setPositionY(rSize.height/2-60+percent*65)
			end
			local current = TrainData.getCurrent(self.name)
			if current[i].val > 0 then
				up["nature"..i].jia:setString("+"..current[i].val)
				up["nature"..i].jian:setString("")
				up["nature"..i].tips:setVisible(true)
				up["nature"..i].tips:getAnimation():play("提升")
				hasUp = true
			elseif current[i].val == 0 then
				up["nature"..i].jia:setString("")
				up["nature"..i].jian:setString("")
				up["nature"..i].tips:setVisible(false)
			else
				up["nature"..i].jian:setString(current[i].val)
				up["nature"..i].jia:setString("")
				up["nature"..i].tips:setVisible(true)
				up["nature"..i].tips:getAnimation():play("下降")
				hasDown = true
			end
		end
		if hasUp and not hasDown then
			self.train.down.add:setPositionY(52)
		else
			self.train.down.add:setPositionY(0)
		end
	end
end

function loadArm(self,name)
	self:addArmatureFrame(string.format("res/armature/%s/small/%s.ExportJson",string.lower(name),name))
	if self.arm then
		self.attrgroup._ccnode:removeChild(self.arm)
	end
	self.arm = ccs.Armature:create(name)
	local armScale = 150/self.arm:getContentSize().width
	armScale = 0.75
	self.arm:setScale(armScale)
	self.attrgroup._ccnode:addChild(self.arm)
	local bgposx,bgposy = self.attrgroup.armbg:getPosition()
	local armposx = bgposx + self.attrgroup.armbg:getContentSize().width/2
	local armposy = bgposy + 20
	self.arm:setPosition(cc.p(armposx,armposy))
	self.armAniFlag = true
	local function onTouchArm(self,event,target)
		if event.etype == Event.Touch_ended then
			if self.armAniFlag then
				self.arm:getAnimation():playWithNames({'胜利'},0,false)
			else
				self.arm:getAnimation():playWithNames({'胜利'},0,false)
			end
			self.armAniFlag = not self.armAniFlag
		end
	end
	local px,py = self.attrgroup.armbg:getPosition()
	local size = self.attrgroup.armbg:getContentSize()
	self.herolvupEffect:retain()
	self.herolvupEffect:removeFromParent()
	self.attrgroup._ccnode:addChild(self.herolvupEffect)
	self.herolvupEffect:release()
	self.herolvupEffect:setPosition(px+size.width/2-6,py+size.height/8)


	self.arm:getAnimation():playWithNames({'胜利'},0,false)
	self.attrgroup.armbg.touchEnabled = true
	self.attrgroup.armbg.touchParent = true
	self.attrgroup.armbg:addEventListener(Event.TouchEvent,onTouchArm,self)
	self.attrgroup.armbg:dispatchEvent(Event.TouchEvent,{etype=Event.Touch_ended})
	self.arm:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID) 
		if movementType == ccs.MovementEventType.complete then
			self.arm:getAnimation():playWithNames({'待机'},0,true)
		end
	end)
end

function initBase(self)
	local name = self.name
	local hero = Hero.getHero(name)

	self:addArmatureFrame("res/common/effect/complete/Complete.ExportJson")
	
	self:addArmatureFrame("res/common/effect/lvPb/lvPb.ExportJson")
	self:addArmatureFrame("res/common/effect/lvUpTxt/lvUpTxt.ExportJson")
	self:addArmatureFrame('res/hero/effect/heroup/heroup.ExportJson')
	
	self.heroupEffect = ccs.Armature:create('heroup')
	self.attrgroup._ccnode:addChild(self.heroupEffect)
	self.heroupEffect:setPositionY(self.attrgroup.armbg:getPositionY())
	self.heroupEffect:setPositionX(self.attrgroup.armbg:getPositionX()+self.attrgroup.armbg:getContentSize().width/2)

	
	self.progressEffect = ccs.Armature:create('heroup')
	self.attrgroup.frag._ccnode:addChild(self.progressEffect)
	local psize = self.attrgroup.frag.expprog:getContentSize()
	local px,py = self.attrgroup.frag.expprog:getPosition()
	self.progressEffect:setPosition(px + psize.width/2,py+psize.height/2)

	Common.setLabelCenter(self.attrgroup.lv.txtlv,'left')
	Common.setLabelCenter(self.attrgroup.power.txtpower)
	Common.setLabelCenter(self.attrgroup.frag.txtfrag)
	Common.setLabelCenter(self.illustration.txtname)



	Common.setLabelCenter(self.attrgroup.txtname)
	Common.setLabelCenter(self.illustration.txtlv)

	-- 详情
	-- local function onSkill(self,event,target)
	-- 	UIManager.addUI("src/modules/skill/ui/SkillListUI",self.name)
	-- end
	-- self.attrgroup.skill.heroskill:addEventListener(Event.Click,onSkill,self)

  	--进阶
  	function onUpgrade(self,event,target)
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_UP_STAR, step = 2})
  		local star = self.hero.quality + 1
  		if star > Def.MAX_QUALITY then
  			-- local tips = TipsUI.showTipsOnlyConfirm()
  			Common.showMsg("英雄已经满星，无法再升星")
  			return
  		end
  		-- UIManager.addChildUI("src/modules/hero/ui/HeroStarUpUI",self.name,star)

		local fragNum = BaseMath.getHeroQualityFrag(self.name,star)
		local fragId = Def.DefineConfig[self.name].fragId

  		if BagData.getItemNumByItemId(fragId) < fragNum then
  			self.attrgroup.fragtips:setVisible(true)
  			self.attrgroup.fragtips:openTimer()
  			local function hideFragTips(self)
  				self.attrgroup.fragtips:setVisible(false)
  			end
  			self.fragTipsTimer = self.attrgroup.fragtips:addTimer(hideFragTips,2,1,self)
  			-- local tips = TipsUI.showTipsOnlyConfirm("英雄碎片不足，无法升星")
  		else
  			local nextLvMoney = HeroQualityConfig[star].qualityMoney
  			local tips = TipsUI.showTips('确定花费'..nextLvMoney..'金币升级到'..star.."星英雄，是否继续？")
  			tips:setBtnName("确定","取消")
			tips:addEventListener(Event.Confirm, function(self,event) 
				if event.etype == Event.Confirm_yes then
		  			if Master:getInstance().money < nextLvMoney then
		  				--ShopUI.virBuy(ShopDefine.K_SHOP_VIRTUAL_MONEY_ID)
		  				local t,rmb,m = ShopUI.getMoneyBuyCntAndCost(nextLvMoney)

						if rmb >= Master.getInstance().rmb then
							-- 钻石不足
							Common.showMsg("金币不足")
						elseif t < 0 then
							Common.showMsg("金币不足，请提升VIP等级，增加购买次数")
						else
							local rmbTip = TipsUI.showTips('金币不足，确定花费'..rmb..'钻石购买'..m.."金币用于升星？")
							rmbTip:addEventListener(Event.Confirm,function(self,event)
									if event.etype == Event.Confirm_yes then
										self:setOldAttr()
										Network.sendMsg(PacketID.CG_HERO_QUALITY_UP,self.name,t)
									end
								end,self)
						end
		  			else
		  				self:setOldAttr()
				    	Network.sendMsg(PacketID.CG_HERO_QUALITY_UP,self.name)
					end
				end
			end,self)
		end
  	end
 	self.attrgroup.frag.upgrade:addEventListener(Event.Click,onUpgrade,self)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.attrgroup.frag.upgrade, step = 2, groupId = GuideDefine.GUIDE_UP_STAR})

  	--进阶
  -- 	function onAddFrag(self,event,target)
  --   	-- Network.sendMsg(PacketID.CG_HERO_QUALITY_UP,name)
  -- 	end
 	-- self.attrgroup.frag.addfrag:addEventListener(Event.Click,onAddFrag,self)

	local function onAddFrag(self,event,target)
		UIManager.addChildUI('src/modules/hero/ui/HeroFragUI',self.name)
		-- UIManager.addChildUI('src/modules/hero/ui/HeroExchangeUI',self.name)
	end
	self.attrgroup.frag.addfrag:addEventListener(Event.Click,onAddFrag,self)

 	function onHeroup(self,event,target)
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_HERO_LV_UP, step = 3})
 		UIManager.addChildUI("src/modules/hero/ui/HerolvupUI",self.name)
 	end
 	self.attrgroup.heroup:addEventListener(Event.Click,onHeroup,self)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.attrgroup.heroup, step = 3, delayTime = 0.3, groupId = GuideDefine.GUIDE_HERO_LV_UP})


	self.herolvupEffect = ccs.Armature:create('heroup')
	self.attrgroup._ccnode:addChild(self.herolvupEffect)
	local px,py = self.attrgroup.armbg:getPosition()
	local size = self.attrgroup.armbg:getContentSize()
	self.herolvupEffect:setPosition(px+size.width/2,py)

	
end

function init(self,name,status)
	if status == nil then
		status = 'base'
	end
	self.name = name
	local hero = Hero.getHero(name)
	self.hero = hero
	self:setOldAttr()
	-- self.detailpanel:setVisible(false)
	self:initBase()
	self:openTimer()
	function onRBBase(self,event,target)
		self.illustration:setVisible(true)
		self.attrgroup:setVisible(true)
		self.attrgroup.frag:setVisible(true)
		--self.attrgroup.skill:setVisible(true)
		self.attrgroup.zhuangbei:setVisible(true)
		-- self.attrgroup.lvup:setVisible(false)

		if self.train then
			self.train:setVisible(false)
		end
		if self.gift then
			self.gift:setVisible(false)
		end
		self.status = 'base'
		self:refreshBase()
		if self.hero:isStarUpEnabled() then
			GuideManager.dispatchEvent(GuideDefine.GUIDE_START, {groupId = GuideDefine.GUIDE_UP_STAR}) 
		end
		GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 1, groupId = GuideDefine.GUIDE_UP_STAR})
		GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 4, groupId = GuideDefine.GUIDE_UP_STAR})
	end
	-- function onRBLvUp(self,event,target)
	-- 	self.illustration:setVisible(true)
	-- 	self.attrgroup:setVisible(true)
	-- 	self.attrgroup.frag:setVisible(false)
	---- 	self.attrgroup.skill:setVisible(false)
	-- 	self.attrgroup.zhuangbei:setVisible(false)
	-- 	self.attrgroup.lvup:setVisible(true)
		
	-- 	if self.strength then
	-- 		self.strength:setVisible(false)
	-- 	end
	-- 	if self.train then
	-- 		self.train:setVisible(false)
	-- 	end
	-- 	if self.detailpanel then
	-- 		self.detailpanel:setVisible(false)
	-- 	end
	-- 	if self.radar then
	-- 		self.radar:setVisible(false)
	-- 	end
	-- 	self:refreshLvUp()

	-- 	self.status = 'up'
	-- end

	-- function onRBPartner(self,event,target)
	-- 	self:refreshPartner(self.name)

	-- 	self.illustration:setVisible(true)
	-- 	self.attrgroup:setVisible(true)
	-- 	self.attrgroup.frag:setVisible(true)
	---- 	self.attrgroup.skill:setVisible(false)
	-- 	self.attrgroup.zhuangbei:setVisible(false)
	-- 	self.attrgroup.lvup:setVisible(false)
		
	-- 	if self.strength then
	-- 		self.strength:setVisible(false)
	-- 	end
	-- 	if self.train then
	-- 		self.train:setVisible(false)
	-- 	end
	-- 	if self.detailpanel then
	-- 		self.detailpanel:setVisible(false)
	-- 	end
	-- 	if self.radar then
	-- 		self.radar:setVisible(false)
	-- 	end
	-- 	self.status = 'partner'
	-- end
	function onRBDiamond(self,event,target)
		self:refreshStrength()
		if self.radar then
			self.radar:setVisible(false)
		end

		self.illustration:setVisible(true)
		self.attrgroup:setVisible(false)

		self.strength:setVisible(true)

		if self.train then
			self.train:setVisible(false)
		end
		self.status = 'diamond'

		GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 1, groupId = GuideDefine.GUIDE_TRANSFER})
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.strength.transfer, step = 2, groupId = GuideDefine.GUIDE_TRANSFER})
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.strength.transfer, delayTime = 0.2, addFinishFun = function()
			if not StrengthLogic.checkCanTransfer(self.hero.strength) then
				print('enter strength =================')
				GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_GEM_QUICK, step = 5})
			end
		end,step = 5, groupId = GuideDefine.GUIDE_GEM_QUICK})

		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_POWER, step = 3})
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_GEM_QUICK, step = 3})
		StrengthLogic.judgeUp(self.hero.strength.cells)
	end

	-- function onRBGift(self,event,target)
	-- 	GiftLogic.refreshGift(self)
	-- 	if self.radar then
	-- 		self.radar:setVisible(false)
	-- 	end

	-- 	self.illustration:setVisible(true)
	-- 	self.attrgroup:setVisible(false)

	-- 	self.gift:setVisible(true)
	-- 	if self.detailpanel then
	-- 		self.detailpanel:setVisible(false)
	-- 	end
	-- 	if self.strength then
	-- 		self.strength:setVisible(false)
	-- 	end
	-- 	if self.capacity then
	-- 		self.capacity:setVisible(false)
	-- 	end
	-- 	if self.breakthrough then
	-- 		self.breakthrough:setVisible(false)
	-- 	end
	-- 	self.status = 'gift'
	-- end


	function onRBDetail(self,event,target)
		self.illustration:setVisible(false)
		self.attrgroup:setVisible(false)

		self.status = 'details'
		self:refreshDetails()
		if self.detailpanel then
			self.detailpanel:setVisible(true)
		end
		if self.radar then
			self.radar:setVisible(true)
		end

	end
	function onRBBreak(self,event,target)
		self.illustration:setVisible(false)
		self.attrgroup:setVisible(false)

		self.status = 'break'
		self:refreshBreak()

		if self.capacity then
			self.capacity:setVisible(true)
		end
		if self.breakthrough then
			self.breakthrough:setVisible(true)
		end
		self.heroinforbg:setTop()
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_HERO_LV_UP, step = 8})
	end
	function closeAllRB(self,event,target)
		self.illustration:setVisible(false)
		self.attrgroup:setVisible(false)
		if self.detailpanel then
			self.detailpanel:setVisible(false)
		end
		if self.radar then
			self.radar:setVisible(false)
		end
		if self.strength then
			self.strength:setVisible(false)
		end
		if self.train then
			self.train:setVisible(false)
		end
		if self.capacity then
			self.capacity:setVisible(false)
		end
		if self.breakthrough then
			self.breakthrough:setVisible(false)
		end
	end
	function onRBDevelop(self,event,target)
		self:refreshTrain()
		if self.radar then
			self.radar:setVisible(false)
		end
		self.illustration:setVisible(true)
		self.attrgroup:setVisible(false)
		self.train:setVisible(true)
		if self.detailpanel then
			self.detailpanel:setVisible(false)
		end
		if self.strength then
			self.strength:setVisible(false)
		end
		self.status = 'train'
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_TRAIN, step = 3})
	end
	self.heroinforbg:addEventListener(Event.Change,closeAllRB,self)
	self.heroinforbg.base:addEventListener(Event.Click,onRBBase,self)
	self.heroinforbg.diamond:addEventListener(Event.Click,onRBDiamond,self)
	-- self.heroinforbg.inborn:addEventListener(Event.Click,onRBGift,self)
	self.heroinforbg.details:addEventListener(Event.Click,onRBDetail,self)
	-- self.heroinforbg.up:addEventListener(Event.Click,onRBLvUp,self)
	self.heroinforbg.develop:addEventListener(Event.Click,onRBDevelop,self)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.heroinforbg.develop, delayTime = 0.3, step = 3, groupId = GuideDefine.GUIDE_TRAIN})
	self.heroinforbg.bt:addEventListener(Event.Click,onRBBreak,self)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.heroinforbg.bt, step = 8, groupId = GuideDefine.GUIDE_HERO_LV_UP})
	if status == 'diamond' then
		self.heroinforbg.diamond:dispatchEvent(Event.Click,{etype=Event.Click})
		self.heroinforbg.diamond:setSelected(true)
	elseif status == 'details' then
		self.heroinforbg.details:dispatchEvent(Event.Click,{etype=Event.Click})
		self.heroinforbg.details:setSelected(true)
	elseif status == 'train' then
		self.heroinforbg.develop:dispatchEvent(Event.Click,{etype=Event.Click})
		self.heroinforbg.develop:setSelected(true)
	elseif status == 'break' then
		self.heroinforbg.bt:dispatchEvent(Event.Click,{etype=Event.Click})
		self.heroinforbg.bt:setSelected(true)
	else
		self.heroinforbg.base:dispatchEvent(Event.Click,{etype=Event.Click})
		self.heroinforbg.base:setSelected(true)
	end





	-- self:showDetails(name)




	-- self:refreshPartner(name)
	-- self:initStrength(name)
	-- self:refreshStrength(name)

	-- self:prepareRadar(name)
	-- self:refreshHero(name)




	-- function onPartner(self,event,target)
	-- 	UIManager.addUI("src/modules/partner/ui/PartnerChainUI",self.name)
	-- end
	-- Dot.check(self.attrgroup.partner.hbtj,"partnerHero",self.name)
	-- self.attrgroup.partner.hbtj:addEventListener(Event.Click,onPartner,self)

	function onClose(self,event,target)
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_POWER, step = 7})
		UIManager.removeUI(self)
		-- require("src/modules/hero/ui/HeroListUI").targetHero = self.name
	end
	self.back:addEventListener(Event.Click,onClose,self)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.back, step = 7, groupId = GuideDefine.GUIDE_POWER})

	-- 向左，向右切换英雄
	
	local function onNeighbour(self,event,target)
		local left,right = Hero.getNeighbours(self.name)
		self.actionReady = false
		if target.name == 'left' and left ~= nil then
			-- UIManager.replaceUI('src/modules/hero/ui/HeroInfoUI',left,self.status)
			UIManager.setTopParams(left,self.status)
			self:refreshHero(left)
		elseif target.name == 'right' and right ~= nil then
			-- UIManager.replaceUI('src/modules/hero/ui/HeroInfoUI',right,self.status)
			UIManager.setTopParams(right,self.status)
			self:refreshHero(right)
		end
		ActionUI.joint({["left"] = {self.illustration}})
	end
	self.left:addEventListener(Event.Click,onNeighbour,self)
	self.right:addEventListener(Event.Click,onNeighbour,self)

	if Hero.getHeroCount() == 1 then
		self.left:setVisible(false)
		self.right:setVisible(false)
	end


	
	-- self:refreshLvUp()
	Bag.getInstance():addEventListener(Event.BagRefresh,onBagRefresh,self)



	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.heroinforbg.diamond, delayTime = 0.2, step = 3, groupId = GuideDefine.GUIDE_POWER})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.heroinforbg.diamond, delayTime = 0.2, step = 3, groupId = GuideDefine.GUIDE_GEM_QUICK})
	

	self.actionReady = false
	ActionUI.joint({["left"] = {self.illustration},["right"] = {self.attrgroup,self.heroinforbg}})


	Master.getInstance():addEventListener(Event.LvUpUIEnd,onStarWakeUp,self)
	Master.getInstance():addEventListener(Event.MasterRefresh,onMasterRefresh,self)
end
function onMasterRefresh(self,event,target)
	Dot.check(self.heroinforbg.bt,"isBreakThroughEnabled",self.name)
end
function onStarWakeUp(self,event)
	local name = event.heroName
	local attrs = event.attrs
	local uiname = event.effectName
	if uiname == 'starup' and attrs[1].name == 'star' then
		-- 暂时去掉这个界面
		-- UIManager.addUI("src/modules/hero/ui/HeroStarUI",name,attrs[1].dst)
	end
end
function clear(self)
	Instance = nil
	if self.fragTipsTimer then
		self.attrgroup.fragtips:delTimer(self.fragTipsTimer)
		self.fragTipsTimer = nil
	end
	Master.getInstance():removeEventListener(Event.LvUpUIEnd,onStarWakeUp)
	Master.getInstance():removeEventListener(Event.MasterRefresh,onMasterRefresh)
	if self.detailNode then
		self.detailNode:clear()
		self.detailNode = nil
	end
	if self.strengthNode then
		self.strengthNode:clear()
		self.strengthNode = nil
	end
	if self.breakNode then
		self.breakNode:clear()
		self.breakNode = nil
	end
	Control.clear(self)
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
	Bag.getInstance():removeEventListener(Event.BagRefresh,onBagRefresh)

	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 3, groupId = GuideDefine.GUIDE_GEM_QUICK})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 4, groupId = GuideDefine.GUIDE_GEM_QUICK})

	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 3, groupId = GuideDefine.GUIDE_POWER})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 5, groupId = GuideDefine.GUIDE_POWER})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 7, groupId = GuideDefine.GUIDE_POWER})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 3, groupId = GuideDefine.GUIDE_HERO_LV_UP})

	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 1, groupId = GuideDefine.GUIDE_TRANSFER})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 2, groupId = GuideDefine.GUIDE_TRANSFER})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 1, groupId = GuideDefine.GUIDE_UP_STAR})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 2, groupId = GuideDefine.GUIDE_UP_STAR})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 4, groupId = GuideDefine.GUIDE_UP_STAR})

	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 3, groupId = GuideDefine.GUIDE_TRAIN})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 5, groupId = GuideDefine.GUIDE_TRAIN})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 7, groupId = GuideDefine.GUIDE_TRAIN})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 9, groupId = GuideDefine.GUIDE_TRAIN})
end

-- 力量 start --
function initStrength(self,name)
	if self.strength == nil then
		self.strengthNode = Control.new(require("res/hero/HeroInfoDiamondSkin"),{"res/hero/HeroInfoDiamond.plist","res/common/an.plist"})
		local strength = self.strengthNode.strength
		strength._ccnode:retain()
		self.strengthNode:removeChild(strength,false)
		self:addChild(strength)
		strength._ccnode:release()
		self.strength = strength

		self:addArmatureFrame("res/strength/effect/equip/StrengthEquip.ExportJson")
		self:addArmatureFrame("res/strength/effect/transfer/TransferLvUp.ExportJson")
		self.heroName = name
		function onGridClick(self,event,target)
			if event.etype == Event.Touch_ended then
				local grid = self.strength["cell"..target.cellPos]
				local state = grid.node:getActiveState()
				local child = UIManager.addChildUI("src/modules/strength/ui/StrengthOperate",state,self.name,target.cellPos,1)
				child:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)

				if target.cellPos == 1 then
					GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_POWER, step = 4})
				end
			end
		end
		function onLvUp(self,event,target)
	    	Network.sendMsg(PacketID.CG_STRENGTH_LV_UP,name,self.pos)
		end
		function onTransfer(self,event,target)
	    	Network.sendMsg(PacketID.CG_STRENGTH_TRANSFER,self.name)
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_TRANSFER, step = 2})
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_GEM_QUICK, step = 5})
		end
		self.strength.transfer:addEventListener(Event.Click,onTransfer,self)
		self.strength.tips:setVisible(false)
		local function onTips(self,event,target)
			if event.etype == Event.Touch_began or 	event.etype == Event.Touch_moved then
				self.strength.tips:setVisible(true)
			else
				self.strength.tips:setVisible(false)
			end
		end
		self.strength.tips.txtdesc1:setString("“一键装备”只能装备当前角色所需要的最高阶宝石，高阶宝石可合成时请先合成，再使用“一键装备”")
		self.strength.tips.txtdesc1:setDimensions(300,0)
		self.strength.info:addEventListener(Event.TouchEvent,onTips,self)
		local function onQuickEquip(self,event,target)
			Network.sendMsg(PacketID.CG_STRENGTH_QUICK_EQUIP,self.heroName)
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_GEM_QUICK, step = 4})
		end
		self.strength.auto:addEventListener(Event.Click,onQuickEquip,self)
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.strength.auto, addFinishFun = function()
			local hasQuickEquip = self:canQucikEquip(self.hero)
			if hasQuickEquip == false then
				GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_GEM_QUICK, step = 4})
			end
		end,step=4, groupId=GuideDefine.GUIDE_GEM_QUICK}) 
		for i = 1,StrengthDefine.kMaxStrengthCellCap do
			local cell = self.strength["cell"..i]
			cell.pos = i
			local grid = StrengthGrid.new()
			grid.cellPos = i
			grid:addEventListener(Event.TouchEvent,onGridClick,self)
			cell.node = grid
			grid:setPositionX(grid:getPositionX()+grid:getContentSize().width/2)
			grid:setPositionY(grid:getPositionY()+grid:getContentSize().height/2)
			grid:setAnchorPoint(0.5,0.5)
			cell:addChild(grid)
			self.strength["desc"..i]:setColor(255,255,255)
			local d = 2
			self.strength["desc"..i]:enableShadow(d,-d)
			self.strength["desc"..i]:enableStroke(200,0,0,d)
			Common.setLabelCenter(self.strength["desc"..i])
			if i == 1 then
				GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=grid, step = 4, groupId = GuideDefine.GUIDE_POWER})
			end
		end
		local function onStrengthShop(self,event,target)
			UIManager.setUIStatus({"diamond"})
			UIManager.addUI("src/modules/shop/ui/StrengthShopUI")
		end
		self.strength.liliangshop:addEventListener(Event.Click,onStrengthShop,self)
		self.strength.liliangshop:setVisible(false)		
		self.heroinforbg:setTop()
	end

end


function setTransferButton(self,hero)
	--local strengthView = self.strength
	--strengthView.transGray:setVisible(false)
	--strengthView.transfer.transLabel:setVisible(false)
	--strengthView.transfer.maxLvLabel:setVisible(false)
	--strengthView.transfer:setVisible(false)
	--local strength = hero.strength
	--if StrengthLogic.isMaxTransfer(strength) then
	--	strengthView.transfer.maxLvLabel:setVisible(true)
	--	strengthView.transfer:setVisible(true)
	--elseif StrengthLogic.checkCanTransfer(strength) then
	--	strengthView.transfer.transLabel:setVisible(true)
	--	strengthView.transfer:setVisible(true)
	--else
	--	strengthView.transGray:setVisible(true)
	--end
	local strengthView = self.strength
	local strength = hero.strength
	strengthView.transfer:setVisible(false)
	strengthView.transGray:setVisible(false)
	strengthView.full:setVisible(false)
	Dot.check(strengthView.transfer,'transferHero',hero)
	if StrengthLogic.checkCanTransfer(strength) then
		strengthView.transfer:setVisible(true)
		Common.setBtnAnimation(strengthView.transfer._ccnode,"TransferLvUp","转职可点")
	elseif strength.transferLv >= StrengthDefine.kMaxTransferLv then
		strengthView.full:setVisible(true)
	else
		strengthView.transGray:setVisible(true)
	end
end

function setStrengthCell(self,hero,pos)
	--local cellView = self.strength["cell"..pos]
	--cellView.lvup:setVisible(false)
	--cellView.highest:setVisible(false)
	--local strength = hero.strength
	--local cell = strength.cells[pos]
	--local cfg = StrengthLogic.getStrengthConfig(hero.name,pos)
	--cellView.textLabel:setLabel(cfg.id,cell.lv)
	--local attr = cfg.lvCfg[cell.lv+1].attr
	--local attrName = ""
	--for k,v in pairs(attr) do
	--	attrName = Hero.getAttrCName(k)
	--	break
	--end
	--cellView.material.desc:setString("开启后增加"..attrName)
	--if StrengthLogic.isMaxLv(strength,pos) then
	--	cellView.highest:setVisible(true)
	--else
	--	if StrengthLogic.checkLvUp(strength,hero,pos) then
	--		cellView.lvup:setVisible(true)
	--		cellView.highest:setVisible(true)
	--	end
	--	local need = cfg.lvCfg[cell.lv+1].need
	--	for i = 1,#need do
	--		cellView.material["grid"..i].node:setIcon(need[i])
	--		local state = StrengthLogic.checkGridState(hero,cell.grids[i].id,need[i])
	--		cellView.material["grid"..i].node:setActiveState(state)
	--	end
	--end
	local cellView = self.strength["cell"..pos]
	local strength = hero.strength
	local cell = strength.cells[pos]
	local cfg = StrengthLogic.getStrengthConfig(hero.name,pos)
	if not cfg then
		return 
	end
	local need 
	local attr
	if cell.lv <= strength.transferLv and not StrengthLogic.isMaxLv(strength,pos) then
		need = cfg.lvCfg[cell.lv+1].need
		attr= cfg.lvCfg[cell.lv+1].append
	else
		need = cfg.lvCfg[cell.lv].need
		attr= cfg.lvCfg[cell.lv].append
	end
	local hasQuickEquip = false
	for i = 1,#need do
		cellView.node:setIcon(need[i])
		local state = StrengthLogic.checkGridState(hero,cell.grids[i].id,need[i])
		Dot.check(cellView,"strengthGrid",state)
		cellView.node:setActiveState(state)
		if state == StrengthDefine.GRID_STATE.canActive then
			hasQuickEquip = true
		end
	end
	for k,v in pairs(attr) do
		local attrName = Hero.getAttrCName(k)
		self.strength["desc"..pos]:setString(attrName.."+"..v)
		break
	end
	return hasQuickEquip
end

function setStrengthState(self,hero)
	local hasQuickEquip = self:canQucikEquip(hero)
	if hasQuickEquip then
		self.strength.auto:setState(Button.UI_BUTTON_NORMAL)
		self.strength.auto:setEnabled(true)
	else
		self.strength.auto:setState(Button.UI_BUTTON_DISABLE)
		self.strength.auto:setEnabled(false)
	end
end

function canQucikEquip(self, hero)
	local hasQuickEquip = false
	for i = 1,StrengthDefine.kMaxStrengthCellCap do
		if self:setStrengthCell(hero,i) then
			hasQuickEquip = true
		end
	end
	return hasQuickEquip
end

function refreshStrength(self,name)
	self:showCard()
	self:initStrength()
	local heroName = name or self.name
	local hero = Hero.heroes[heroName]
	self.heroName = heroName
	if Dot.check(self.heroinforbg.diamond,"strengthHero",hero)
		or Dot.check(self.heroinforbg.diamond,"transferHero",hero) then
	end
	self.strength.jieshu2:setString(string.format("%d阶",hero.strength.transferLv))
	self:setTransferButton(hero)
	self:setStrengthState(hero)
end
-- 力量 end--

function setView(self,view)
	self.left:setVisible(false)
	self.radar:setVisible(false)
	self.attrgroup:setVisible(false)
	self.strength:setVisible(false)
	self[view]:setVisible(true)
	if view == "radar" or view == "attrgroup" then
		self.left:setVisible(true)
	end
end

function setUIStatus(self,status)
	self.heroinforbg.base:setSelected(false)
	self.heroinforbg.diamond:setSelected(false)
	self.heroinforbg.details:setSelected(false)
	self.heroinforbg.bt:setSelected(false)
	self.heroinforbg.develop:setSelected(false)
	--self.heroinforbg.up:setSelected(false)
	self.heroinforbg[status]:setSelected(true)
	self.heroinforbg[status]:dispatchEvent(Event.Click)
end

return HeroInfoUI
