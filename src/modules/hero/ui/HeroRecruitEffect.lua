module("HeroRecruitEffect", package.seeall)
setmetatable(HeroRecruitEffect, {__index = Control})

local FightDefine = require("src/modules/fight/Define")
local Def = require("src/modules/hero/HeroDefine")
local Hero = require("src/modules/hero/Hero")
function new(name,star,lv)
	local skin = {
		name="HeroRecruitEffect",type="Container",x=0,y=0,width=854,height=480,
		children={}
	}
	local ctrl = Control.new(skin)
	setmetatable(ctrl,{__index = _M})
	ctrl:init(name,star,lv)
	return ctrl
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
end


function uiEffect()
	return UIManager.FIRST_TEMP_FULL
end

function init(self,name,star,lv)
	if not star then star = 1 end
	if not lv then lv = 1 end
	local hero = Hero.getHero(name)
	self:addArmatureFrame("res/hero/effect/herorecruit/herorecruit.ExportJson")
	self.recruitEffect_bg = ccs.Armature:create("herorecruit")
	self.recruitEffect_card = ccs.Armature:create("herorecruit")
	self._ccnode:addChild(self.recruitEffect_bg)
	self.recruitEffect_bg:setPosition(cc.p(self._skin.width/2,self._skin.height/2))
	self._ccnode:addChild(self.recruitEffect_card)
	self.recruitEffect_card:setPosition(cc.p(self._skin.width/2,self._skin.height/2))
	local skin = ccs.Skin:create("res/hero/cicon/" .. name .. ".jpg")
	self.recruitEffect_card:getBone("Layer2"):setScale(0.99)
	self.recruitEffect_card:getBone('Layer2'):addDisplay(skin,0)

	local conf = Def.DefineConfig[name]
	local career = conf.career
	local career_skin = ccs.Skin:create("res/hero/career/"..career..".png")
	self.recruitEffect_card:getBone("h"):addDisplay(career_skin,0)
	for i=1,star do
		local starstr = 'star'
		if i> 1 then
			starstr = starstr .. i
		end

		local star_skin = ccs.Skin:create("res/hero/career/star.png")
		self.recruitEffect_card:getBone(starstr):addDisplay(star_skin,0)
	end

	-- local star2_skin = ccs.Skin:create("res/hero/career/star.png")
	-- self.recruitEffect_card:getBone("star2"):addDisplay(star2_skin,0)
	




	local career_x,career_y = self.recruitEffect_card:getBone("h"):getPosition()
	-- local label_skin = 
 --    {name="heroname",type="Label",x=career_x,y=career_y,width=50,height=0,
 --        {name="txteheroname",status="",txt="xxxxxx",font="SimHei",size=20,bold=false,italic=false,color={255,255,255}},
 --    }
	-- local txtLabel = Label.new(label_skin)
	-- txtLabel:setString(conf.cname)
	-- txtLabel:setS
	local tt = cc.LabelTTF:create(conf.cname,Label.UI_DEFAULT_FONT,20,cc.size(0,0),0,2)
	-- tt:setScale(0.5)
	-- local t = Label.new(Label.UI_LABEL_DEFAULT_SKIN)
	
	-- t:setString(conf.cname)
	-- t:setFontSize(20)
	-- local s = Sprite.new('aa','res/hero/bicon/Terry.png')
	-- s._ccnode:addChild(tt)
	local ttskin = ccs.Skin:create()
	-- local bone = ccs.Bone:create()
	-- bone:addDisplay(tt,-1)
	-- self.recruitEffect_card:addBone(bone,"k")


	local bone  = ccs.Bone:create("name1")
	bone:setAnchorPoint(0,0)
	-- bone:setAnchorPoint(0.5,0.5)
    bone:addDisplay(tt, 0)
    bone:changeDisplayWithIndex(0, true)
    bone:setIgnoreMovementBoneData(true)
    bone:setLocalZOrder(100)
    bone:setScale(1)
    self.recruitEffect_card:addBone(bone, "name")
	-- self.recruitEffect_card:getBone("k")

	local lvtxt = cc.LabelTTF:create(tostring(lv),Label.UI_DEFAULT_FONT,20,cc.size(0,0),0,2)

	local lvbone  = ccs.Bone:create("lv1")
	lvbone:setAnchorPoint(0,0)
	-- bone:setAnchorPoint(0.5,0.5)
    lvbone:addDisplay(lvtxt, 0)
    lvbone:changeDisplayWithIndex(0, true)
    lvbone:setIgnoreMovementBoneData(true)
    lvbone:setLocalZOrder(100)
    lvbone:setScale(1)
    self.recruitEffect_card:addBone(lvbone, "lv")

	self.heroUI = Control.new(require("res/hero/HeroRecruitEffectSkin"),{"res/hero/HeroRecruitEffect.plist","res/common/an.plist"})
	self.heroUI.txtdesc:setVisible(false)
	self.heroUI.txtdesc2:setVisible(false)
	self:addChild(self.heroUI)
	self.heroUI:setVisible(false)
	self:addArmatureFrame(string.format("res/armature/%s/%s.ExportJson",string.lower(name),name))
	self.char = ccs.Armature:create(name)
	local armScale = 500/self.char:getContentSize().height
	self.char:setScale(armScale)
	
	Common.setLabelCenter(self.heroUI.txtname)
	self.heroUI.txtname:setString(conf.cname)
	self.heroUI.heroicon:setVisible(false)
	self.heroUI._ccnode:addChild(self.char)
	local x,y = self.heroUI.heroicon:getPosition()
	self.char:setPosition(x+self.heroUI.heroicon._skin.width/2,y+10)
	self.step = 0

	UIManager.playMusic('recruitHero')

	self.heroUI.confirm:addEventListener(Event.TouchEvent,onClose,self)

	hero:showHeroNameLabel(self.heroUI.txtname2)
	self.heroUI.txtpower:setString(hero:getFight())
	self.heroUI.txttrend:setString(conf.advantage.."型")
	local d = 2
	self.heroUI.txtpower:enableShadow(d,-d)
	self.heroUI.txtpower:enableStroke(200,0,0,d)
	self.heroUI.txttrend:enableShadow(d,-d)
	self.heroUI.txttrend:enableStroke(200,0,0,d)
end

function onClose(self,event,target)
	if event.etype == Event.Touch_ended then
		UIManager.removeUI(self)
		Stage.currentScene:dispatchEvent(Event.HeroRecruitRemove)
	end
end


function touch(self,event)
	Control.touch(self,event)
	if event.etype == Event.Touch_ended then
		if self.step == 1 then
			self.recruitEffect_card:setVisible(false)
			self.heroUI:setVisible(true)
			self.char:getAnimation():playWithNames({'待机'},0,true)
			self.step = 2
		elseif self.step == 2 then
			-- UIManager.removeUI(self)
			-- Stage.currentScene:dispatchEvent(Event.HeroRecruitRemove)
		end
	end
end

function playEffect(self)
	self.recruitEffect_bg:getAnimation():playWithNames({'背景'},0,true)
	self.recruitEffect_card:getAnimation():playWithNames({'卡牌'},0,false)
    self.recruitEffect_card:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID) 
		if movementType == ccs.MovementEventType.complete then
			self.step = 1
		end
	end)
end






return HeroRecruitEffect
