module(..., package.seeall)
setmetatable(_M, {__index = Control})

local HeroInfoUI = require("src/modules/hero/ui/HeroInfoUI")
local Def = require("src/modules/hero/HeroDefine")
local Hero = require("src/modules/hero/Hero")
local BagData = require("src/modules/bag/BagData")
local BagLogic = require("src/modules/bag/BagLogic")
local Chapter = require("src/modules/chapter/Chapter")
local FBConfig = require("src/config/FBConfig").Config
local StrengthLogic = require("src/modules/strength/StrengthLogic")
local BaseMath = require("src/modules/public/BaseMath")
local ItemConfig = require("src/config/ItemConfig").Config

showFlag = 1  -- 1 或者 nil 表示显示已有的英雄，2表示显示未拥有的英雄
SHOW_RECRUITED = 1      -- 显示 已拥有的英雄
SHOW_UNRECRUITED = 2    -- 显示 未拥有的英雄

function setShowFlag(flag)
	showFlag = flag
end

-- Instance = nil 
targetHero = nil

--  mode = all (全部英雄)  recruited （已拥有的英雄） unrecruited (显示未拥有的英雄)
function new(mode,heroName,career)
	local ctrl = Control.new(require("res/hero/HeroListSkin"),{"res/hero/HeroList.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(mode,heroName,career)
	return ctrl
end


function addStage(self)
	self:setPositionY(Stage.uiBottom)
end

function uiEffect()
	return UIManager.FIRST_TEMP_RAW
end

function sortUnRecruited(a,b)
	local fragA = BagData.getItemNumByItemId(a.fragId)
	local fragB = BagData.getItemNumByItemId(b.fragId)
	if fragA ~= fragB then
		return fragA > fragB
	elseif a.fragment ~= b.fragment then
		return a.fragment < b.fragment
	else
		return a.heroId < b.heroId
	end 
end

function onClose(self,event,target)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_HERO_ACTIVE, step = 5})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_HERO_ACTIVE_SHOP, step = 4})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_POWER, step = 8})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_SKILL_STRENGTH, step = 15})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_PARTNER, step = 5})

	UIManager.removeUI(self)
end



--  子类需要继承一下函数

-- 点击已招募英雄的点击事件处理函数
function onClickRecruitedHero(self,event,target)

end

function onClickUnRecruitedHero(self,event,target)
end

function onClickComposeHero(self,event,target)

end

-- 需要刷新已拥有的英雄
function refreshRecruitedHero(self,item)

end



-----------------------------



function sortHeroes(self)
	local heroes = {}
	for _,h in pairs(Def.DefineConfig) do
		if h.tag == Def.HERO_TAG_HERO then
			heroes[h.name] = h
		end
	end

	self.sortedHeroes = {}
	

	for _,h in pairs(Hero.heroes) do
		if heroes[h.name] then
			if self.mode == "all" or self.mode == "recruited" then
				if not self.career or self.career == 0 or h.career == self.career then
					self.sortedHeroes[#self.sortedHeroes+1] = h
				end
			end
			heroes[h.name] = nil
		end
	end
	table.sort(self.sortedHeroes,Hero.sortRecruitedHero)
	
	if self.mode == 'all' or self.mode == "unrecruited" then
		local unrecruited = {}
		for _,h in pairs(heroes) do
			if not self.career or self.career == 0 or h.career == self.career then
				unrecruited[#unrecruited + 1] = h
			end
		end
		if #unrecruited > 0 and #self.sortedHeroes > 0 then
			self.sortedHeroes[#self.sortedHeroes+1] = {split=true}
		end
		table.sort(unrecruited,sortUnRecruited)
		for _,u in ipairs(unrecruited) do
			table.insert(self.sortedHeroes,u)
		end
	end

end

function setCareer(item,careerId)
	item.careericon:setVisible(true)
	for i=1,5 do
		if i == careerId then
			item.careericon['careericon'..i]:setVisible(true)
		else
			item.careericon['careericon'..i]:setVisible(false)
		end
	end
end

function addHeroSprite(item,name,gray)
	item:removeChildByName("heroicon")
	local spr = Sprite.new('heroicon','res/hero/nicon/'..name..".jpg")
	if spr then
		item:addChild(spr)
		local size = item:getContentSize()
		spr:setPosition(size.width/2,size.height/2)
		spr:setAnchorPoint(0.5,0.5)
		spr._ccnode:setLocalZOrder(-1)
		if gray then
			spr:shader(Shader.SHADER_TYPE_GRAY)
		end
		spr:setScale(0.97)
		spr.touchEnabled = false
		-- spr.touchParent = 
	end
end


function addHeroByFrame(self,event)
	local frameRate = 1
	if self.sortedHeroes and #self.sortedHeroes > 0 then
		for i=1,frameRate do
			if self.sortedHeroes[1] then
				local hero = self.sortedHeroes[1]
				table.remove(self.sortedHeroes,1)
				self:addHeroToList(hero)
			else
				break
			end
		end
	end
end

function addHeroToList(self,h)
	function onClickHero(self,event,target)
		if not target.split:isVisible() then
			self.onClickRecruitedHero(self,event,target)
		end
	end
	local no = self.herolist:addItem()
	local item = self.herolist.itemContainer[no]
	item.split:setVisible(false)
	item.selectIcon:setVisible(false)
	item.heroName = h.name
	Common.setLabelCenter(item.txtname)

	setCareer(item,h.career)
	if h.split then
		item.split:setVisible(true)
		item.unrecruited:setVisible(false)
		item.txtname:setVisible(false)
		item.recruited:setVisible(false)
		item.careericon:setVisible(false)
		item.herobg:setVisible(false)
	else
		if h.quality then
			-- 已拥有的英雄

			-- item.txtname:setString(h.cname)
			-- local q = Def.HERO_QUALITY[h.quality]
			-- item.txtname:setColor(q.r,q.g,q.b)
			h:showHeroNameLabel(item.txtname)
			curShow = 1
			item.recruited:setVisible(true)
			item.unrecruited:setVisible(false)
			addHeroSprite(item,h.name,false)
			-- 等级
			item.recruited.lv:setString("lv."..h.lv)	


			self:refreshRecruitedHero(item)
			self:refreshLvUp(item,h)
			item:addEventListener(Event.TouchEvent,onClickHero,self)
			for i=1,5 do
				if h.quality and h.quality >= i then
					item.recruited.star['star'..i]:setVisible(true)
				else
					item.recruited.star['star'..i]:setVisible(false)
				end
			end
			--local transferLv = h.strength.transferLv + 1
			local bgspr = Sprite.new("qualitybg",'res/hero/nicon/qualitybg'..h.quality..".png")
			item:addChild(bgspr)
			bgspr:setPosition(item.herobg:getPosition())
			item.touchParent = false
		else
			item.unrecruited:setVisible(true)
			item.recruited:setVisible(false)
			local frag = BagData.getItemNumByItemId(h.fragId)
			local fragment = BaseMath.getHeroRecruitFrag(h.name)
			if frag < fragment then
				item.unrecruited.prog:setVisible(true)
				item.unrecruited.activation:setVisible(false)
				Common.setLabelCenter(item.unrecruited.prog.txtprog)
				item.unrecruited.prog.txtprog:setString(frag..'/'..fragment)
				item:addEventListener(Event.TouchEvent,self.onClickUnRecruitedHero,self)
			else
				item.unrecruited.prog:setVisible(false)
				item.unrecruited.activation:setVisible(true)
				item.unrecruited.activation:addEventListener(Event.Click,self.onClickComposeHero,self)
			end
			addHeroSprite(item,h.name,true)
			item.txtname:setString(h.cname)
			item.touchParent = false
		end
		item.unrecruited:setTop()
		item.recruited:setTop()
		item.careericon:setTop()
		item.txtname:setTop()

		if self.heroName and  self.heroName == h.name then
			self.herolist:showTopItem(no,true)
		elseif targetHero and targetHero == h.name then
			self.herolist:showTopItem(no,true)
			targetHero = nil
		end

		if h.name == "Shingo" then
			local fun = function()
				self.herolist:showTopItem(item.num)
			end
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=item, delayTime=0.3, step = 2, groupId = GuideDefine.GUIDE_POWER, noDelayFun=fun})
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=item, delayTime=0.3, step = 2, groupId = GuideDefine.GUIDE_TRAIN, noDelayFun=fun})
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=item, delayTime=0.3, step = 2, groupId = GuideDefine.GUIDE_TALENT, noDelayFun=fun})
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=item, delayTime=0.3, step = 2, groupId = GuideDefine.GUIDE_SKILL_STRENGTH, noDelayFun=fun})
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=item, delayTime=0.3, step = 2, groupId = GuideDefine.GUIDE_PARTNER, noDelayFun=fun})
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=item, delayTime=0.3, step = 2, groupId = GuideDefine.GUIDE_HERO_LV_UP, noDelayFun=fun})
		end
		if h.lv and h.lv >= 10 then
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=item, delayTime=0.3, step = 2, groupId = GuideDefine.GUIDE_GEM_QUICK, noDelayFun=fun})
		end
		if h.lv and h.lv >= 11 then
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=item, delayTime = 0.3, step = 2, groupId = GuideDefine.GUIDE_EQUIP, noDelayFun=fun})
		end
		if h.name == "Chang" then
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=item.unrecruited.activation, delayTime = 0.3, step = 2, groupId = GuideDefine.GUIDE_HERO_ACTIVE, noDelayFun = function()
					self.herolist:showTopItem(item.num)
				end	
			})
		end
		if h.name == "Shingo" then
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=item.unrecruited.activation, delayTime = 0.3, step = 2, groupId = GuideDefine.GUIDE_HERO_ACTIVE_SHOP, noDelayFun = function()
					self.herolist:showTopItem(item.num)
				end	
			})
		end
	end
end


function showHeroCnt(self)
	Common.setLabelCenter(self.herocnt.txtnum)
	self.herocnt.txtnum:setString(Hero.getHeroCount())
end

function refreshLvUp(self,item,hero)
	local nextExp = hero:getExpForNextLv()
	item.recruited.lv:setString('lv.'..hero.lv)
	if hero.lv >= Def.MAX_LEVEL then
		-- item.recruited.txtjy:setString("满级")
		item.recruited.expprog:setPercent(100)
		item.recruited.max:setVisible(true)
	elseif hero.lv == Master:getInstance().lv and hero.exp == nextExp then
		item.recruited.expprog:setPercent(100)
		item.recruited.max:setVisible(false)
	else
		local percent = 100*hero.exp / nextExp
		item.recruited.expprog:setPercent(percent)
		item.recruited.max:setVisible(false)
	end
end
function refresh(self)
	self.herocnt.txtnum:setString(Hero.getHeroCount())
	self:sortHeroes()
end


function init(self,mode,heroName,career)
	self.mode = mode
	self.heroName = heroName
	self.career = career
	self.back:addEventListener(Event.Click,onClose,self)
	self:addArmatureFrame("res/common/effect/progup/progup.ExportJson")
	self:addArmatureFrame("res/common/effect/lvUpTxt/lvUpTxt.ExportJson")
	-- function onCloseHeroFragUI(self,event,target) 
	-- 	self:setVisible(false) 
	-- end 
	-- self.acquire.close:addEventListener(Event.Click,close,self.acquire)
	self.herolist:setDirection(List.UI_LIST_HORIZONTAL)
	self.herolist.UI_LIST_BTW_SPACE = 5
	self.herolist.UI_LIST_MOVE_DISTANCE = 5
	self.herolist:setBgVisiable(false)

	self:refresh()
	self:openTimer()
	self:addEventListener(Event.Frame, addHeroByFrame)
	self:showHeroCnt()

	self.ok:setVisible(false)
	self.herocnt.selCntTxt:setVisible(false)

	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.back, step = 5, groupId = GuideDefine.GUIDE_HERO_ACTIVE})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.back, step = 4, groupId = GuideDefine.GUIDE_HERO_ACTIVE_SHOP})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.back, step = 8, groupId = GuideDefine.GUIDE_POWER})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.back, step = 15, groupId = GuideDefine.GUIDE_SKILL_STRENGTH})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.back, step = 5, groupId = GuideDefine.GUIDE_PARTNER})
end

function clear(self)
	Control.clear(self)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 2, groupId = GuideDefine.GUIDE_GEM_QUICK})

	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 2, groupId = GuideDefine.GUIDE_HERO_ACTIVE})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 5, groupId = GuideDefine.GUIDE_HERO_ACTIVE})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 2, groupId = GuideDefine.GUIDE_HERO_ACTIVE_SHOP})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 4, groupId = GuideDefine.GUIDE_HERO_ACTIVE_SHOP})

	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 2, groupId = GuideDefine.GUIDE_HERO_LV_UP})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 2, groupId = GuideDefine.GUIDE_TRAIN})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 2, groupId = GuideDefine.GUIDE_TALENT})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 2, groupId = GuideDefine.GUIDE_SKILL_STRENGTH})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 9, groupId = GuideDefine.GUIDE_SKILL_STRENGTH})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 15, groupId = GuideDefine.GUIDE_SKILL_STRENGTH})

	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 2, groupId = GuideDefine.GUIDE_PARTNER})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 5, groupId = GuideDefine.GUIDE_PARTNER})

	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 2, groupId = GuideDefine.GUIDE_POWER})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 8, groupId = GuideDefine.GUIDE_POWER})

	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 2, groupId = GuideDefine.GUIDE_EQUIP})
end
