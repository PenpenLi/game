module( "CommonGrid", package.seeall )
setmetatable(CommonGrid, {__index = Control})

local MonsterConfig = require("src/config/MonsterConfig").Config
local SkillConfig = require("src/config/SkillConfig").Config
local SkillGroupConfig = require("src/config/SkillGroupConfig").Config
local ItemConfig = require("src/config/ItemConfig").Config
local StrengthLabel = require("src/modules/strength/ui/StrengthLabel")
local BagLogic = require("src/modules/bag/BagLogic")
local ShopDefine = require("src/modules/shop/ShopDefine")
local ChapterDefine = require("src/modules/chapter/ChapterDefine")
local BodyConfig = require("src/config/BodyConfig").Config
local SkillIconSize = 56

--[[
-- 支持两种用法
-- 1、直接new() 精灵
-- 2、bind()到control上
--]]

function new()
	local instance = {}
	setmetatable(instance, {__index = CommonGrid})
	instance:init()
	return instance
end

function init(self)
	self.name = "CommonGrid"
	self._parent = nil
	self._children = nil

	self._ccnode = cc.Sprite:create()
	self._icon = self._ccnode

	self:setAnchorPoint(0, 0)
end

function onGridTouch(self,event,target)
	if event.etype == Event.Touch_began then
		local worldPoint = target._parent._ccnode:convertToWorldSpace(cc.p(target:getPosition())) 
		local pos = Stage.currentScene:getUI()._ccnode:convertToNodeSpace(worldPoint)
		local x = pos.x
		local y = pos.y + self:getContentSize().height
		ItemTips.show(self,{x=x,y=y})
	elseif event.etype == Event.Touch_ended 
		or event.etype == Event.Touch_out 
		or event.etype == Event.Touch_over 
		or event.etype == Event.Touch_cancelled
		then
		ItemTips.hide()
	end
end

function bind(grid,isTips)
	if grid._icon == nil then
		local icon = cc.Sprite:create()
		icon:setAnchorPoint(0, 0)
		grid._icon = icon
		grid._ccnode:addChild(icon)
		setmetatable(grid,{__index = _M})
	end
	if isTips then
		if not grid:hasEventListener(Event.TouchEvent,onGridTouch) then
			grid:addEventListener(Event.TouchEvent,onGridTouch,grid)
		end
	end
	return grid
end

function setName(self, name)
	self.name = name 
end

function setIcon(self, iconId)
	if iconId ~= nil then
		local res = "res/common/icon/" .. iconId .. ".png"
		self._icon:setTexture(res)
		self._icon:setVisible(true)
	else
		self._icon:setVisible(false)
	end
end

function shader(self,shaderName,...)
	Shader.setShader(self._ccnode, shaderName, ...)
	if self._icon then
		Shader.setShader(self._icon, shaderName, ...)
	end
end

function setShader(self,shader)
	Shader.setShader(self._icon,shader)
end
function resetShader(self)
	Shader.setShader(self._icon)
end

--主角头像
function setBodyIcon(self, bodyId,scale)
	if BodyConfig[bodyId] then
	--if BodyGrid.bodyConf[bodyId] then
		scale = scale or 1
		local res = "res/common/icon/master/" .. bodyId .. ".png"
		self._icon:setTexture(res)
		--local width = self._icon:getContentSize().width
		--self.scale = size/width
		self._icon:setScale(scale)
		self._icon:setVisible(true)
		self:setIconCenter()
		--@todo尺寸不太对啊
		--self._icon:setPositionY(self._icon:getPositionX()+10)
	else
		self._icon:setVisible(false)
	end
end

function setItemIcon(self,id,name,size)
	local cfg = ItemConfig[id]
	if cfg then
		self:setVisible(true)
		self._id = id
		--local res = "res/common/icon/item/" .. cfg[name or "icon"].. ".png"
		local res 
		if cfg.attr.addHero then
			res = "res/hero/sicon/" .. cfg.attr.addHero.name .. ".png"
		elseif cfg.clientCmd[1] and cfg.clientCmd[1].oHeroInfo then
			res = "res/hero/sicon/" .. cfg.clientCmd[1].oHeroInfo[1] .. ".png"
		else
			res = "res/common/icon/item/" .. cfg.descIcon .. ".png"
		end
		self._icon:setTexture(res)
		local width = self._icon:getContentSize().width
		local scale = 72
		if name == "descIcon" then
			scale = 92
		elseif name == "sIcon" then
			scale = 45
		elseif name == "mIcon" then
			scale = 55
		end
		if size then scale = size end
		self.size = scale
		self.scale = scale/width
		self._icon:setScale(self.scale)
		self._icon:setVisible(true)
		if BagLogic.isFragItem(id) then
			if not self._border then
				local borderRes = "res/common/icon/item/120/frag.png"
				self._border = cc.Sprite:create(borderRes)
				self._icon:addChild(self._border)
			end
			local contentSize = self._icon:getContentSize()
			self._border:setPosition(contentSize.width/2,contentSize.height/2)
			self._border:setVisible(true)
		else
			if self._border then
				self._border:setVisible(false)
			end
		end
		self:setItemColor(cfg.color)
		self:setIconCenter()
	else
		self._icon:setVisible(false)
		self:setVisible(false)
	end
end

--必须先setItemIcon后调用
function setItemColor(self, color)
	local heroGrid = Sprite.new('grid',"res/hero/sicon/qualitybg" .. color .. ".png")
	if heroGrid then
		self:removeChildByName('grid')
		self:addChild(heroGrid)
		heroGrid:setAnchorPoint(0.5,0.5)
		heroGrid:setScale(self.size/90)
		heroGrid:setPositionX(self:getContentSize().width/2)
		heroGrid:setPositionY(self:getContentSize().height/2)
	end
end

function setItemIconBySize(self,id,size)
	if ItemConfig[id] then
		local res = "res/common/icon/item/" .. ItemConfig[id]["descIcon"].. ".png"
		self._icon:setTexture(res)
		local width = self._icon:getContentSize().width
		self.scale = size/width
		self._icon:setScale(self.scale)
		self._icon:setVisible(true)
		self:setIconCenter()
	else
		self._icon:setVisible(false)
	end
end

function setGridEffect(self,effectId)
	self:addArmatureFrame("res/common/effect/gridEffect/gridEffect.ExportJson")

	local effect = ccs.Armature:create('gridEffect')
	self._ccnode:addChild(effect,10)
	effect:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)
	effect:getAnimation():play(tostring(effectId),-1,-1)
	-- effect:setAnchorPoint(0.5)
end

function setStrengthIcon(self,id)
	if not id then
		return
	end
	local name = StrengthLabel.id2type[id]
	if name then
		local res = "res/common/icon/strength/" .. name .. ".png"
		self._icon:setTexture(res) 
		self._icon:setVisible(true)
		self._icon:setScale(40/120)
		self:setIconCenter()
	end
end

function setItemNum(self,num)
	--if not self._numBg then
	--	self:addSpriteFrames("res/bag/BagGrid.plist")
	--	self._numBg = cc.Sprite:createWithSpriteFrameName("BagGrid.numBg.png")
	--	self._ccnode:addChild(self._numBg)
	--	self._numBg:setAnchorPoint(1,0)
	--	local width = self._icon:getContentSize().width
	--	local posX = self.scale and self.scale * 6 or 6
	--	local posY = self.scale and self.scale * 6 or 6
	--	self._numBg:setPositionX(self:getContentSize().width-posX)
	--	self._numBg:setPositionY(posY)
	--end
	--if not self._num then
 	--	local skin = {name="num",type="Label",x=0,y=0,width=17,height=14,
    --	       {name="num",status="",txt="12",font="SimHei",size=14,bold=false,italic=false,color={255,255,255}},
    --	}
	--	self._num = Label.new(skin)
	--	self._num:setAnchorPoint(1,0)
	--	self._numBg:addChild(self._num._ccnode)
	--end
    --self._ccnode:reorderChild(self._numBg,1)
	--if num > 0 then
	--	self._numBg:setVisible(true)
	--	self._num:setString(num)
	--	self._numId = num
	--else
	--	self._numBg:setVisible(false)
	--end
	if not self._num then
 		local skin = {name="num",type="Label",x=22,y=0,width=17,height=14,
    	       {name="num",status="",txt="12",font="SimHei",size=16,bold=false,italic=false,color={255,255,255}},
    	}
		self._num = Label.new(skin)
		self._num:setAnchorPoint(1,0)
		local posX = self.scale and self.scale * 6 or 6
		local posY = self.scale and self.scale * 6 or 6
		self._num:setPositionX(self:getContentSize().width-posX)
		self._num:setPositionY(posY)
		self._ccnode:addChild(self._num._ccnode)
	end
	if num > 0 then
		self._num:setString(num)
	else
		self._num:setString("")
	end
end

function setHeroIcon(self, heroName,size,scale,quality)
	if not size then
		size = 's'
	end
	if not scale or type(scale) ~= 'number' then
		scale = 1
	end
	if not quality then
		quality = 1
	end
	if heroName ~= nil then
		local res = "res/hero/".. size .."icon/" .. heroName .. ".png"
		self._icon:setTexture(res)
		self._icon:setScale(scale)
		self._icon:setVisible(true)
		self:setIconCenter()
		if size == 's' then  --小英雄图标加边框3
			--if not self._border then
	    	--	self:addSpriteFrames("res/common/tb.plist")
			--	self._border = cc.Sprite:createWithSpriteFrameName("tb.headlv3.png")
			--	self._icon:addChild(self._border)
			--end
			--local contentSize = self._icon:getContentSize()
			--self._border:setPosition(contentSize.width/2,contentSize.height/2)
			if quality == 0 then
				self:removeChildByName('grid')
			else
				local heroGrid = Sprite.new('grid',"res/hero/".. size .."icon/qualitybg" .. quality .. ".png")
				if heroGrid then
					--heroGrid:setScale(scale)
					--self:removeChildByName('grid')
					--self:addChild(heroGrid)
					--heroGrid:setParentCenter()
					self:removeChildByName('grid')
					self:addChild(heroGrid)
					heroGrid:setAnchorPoint(0.5,0.5)
					heroGrid:setScale(scale)
					heroGrid:setPositionX(self:getContentSize().width/2)
					heroGrid:setPositionY(self:getContentSize().height/2)
				end
			end
		end
	else
		self._icon:setVisible(false)
	end
end

HERO_BG =
{
    Iori = "bg1",
    Terry = "bg3",
    Mai = "bg2",
    Ryo = "bg4",
}

function setHeroIcon2(self,heroName,size,quality,scale)
	if not quality then
		quality = 1
	end
	if not size then
		size = 'f'
	end
	if not scale then
		scale = 1
	end
	self:removeChildByName('grid')
	self:removeChildByName('hero')
	if heroName ~= nil then
		local heroicon = Sprite.new('hero',"res/hero/"..size.."icon/"..heroName..".png")
		if heroicon then
			self:removeChildByName('hero')
			self:addChild(heroicon)
			heroicon:setAnchorPoint(0.5,0.5)
			local s = self:getContentSize()
			heroicon:setPosition(s.width/2,s.height/2)
			heroicon:setScale(scale)
		end
		if quality == 0 then
			self:removeChildByName('grid')
		else
			local heroGrid = Sprite.new('grid',"res/hero/".. size .."icon/qualitybg" .. quality .. ".png")
			if heroGrid then
				self:removeChildByName('grid')
				self:addChild(heroGrid)
				heroGrid:setParentCenter()
			end
		end
	end
end

function setHeroIconWithBG(self,heroName,size,scale,bg,quality)
	if not bg then
		bg = HERO_BG[heroName]
		if not bg then
			bg = 'bg1'
		end
	end
	if not quality then
		quality = 1
	end
	if not size then
		size = 's'
	end
	if not scale then
		scale = 1
	end
	if heroName ~= nil then
		local heroGrid = Sprite.new('grid',"res/hero/".. size .."icon/qualitybg" .. quality .. ".png")
		if heroGrid then
			self:removeChildByName('grid')
			self:addChild(heroGrid)
			heroGrid:setParentCenter()
		end
		if size ~= 's' and bg then
			local herobg = Sprite.new('herobg',"res/hero/"..size.."icon/"..bg..".png")
			if herobg then
				self:removeChildByName('herobg')
				self:addChild(herobg)
				herobg:setParentCenter()
			end
		end
		local heroicon = Sprite.new('hero',"res/hero/"..size.."icon/"..heroName..".png")
		if heroicon then
			self:removeChildByName('hero')
			self:addChild(heroicon)
			heroicon:setAnchorPoint(0.5,0.5)

			local size = self:getContentSize()
			if size == 'm' then
				heroicon:setPosition(size.width/2+3,size.height/2+8)
			else
				heroicon:setPosition(size.width/2,size.height/2)
			end
			-- heroicon._ccnode:setScaleX(-1)
			heroicon:setScale(scale)
		end
	end
end

function setMonsterIcon(self, monsterId,size,scale)
	local conf = MonsterConfig[monsterId]
	if conf then
		self:setHeroIcon(conf.name,size,scale)
	end
end

function setSkillIcon(self,skillId,scale)
	self._id = skillId
	local conf = SkillConfig[skillId]
	local size = self:getContentSize()
	local res = string.format("res/common/icon/skill/%s.png",conf.icon)
	self._icon:setTexture(res)
	self._icon:setVisible(true)
	scale = scale or SkillIconSize / self._icon:getContentSize().width 
	self._icon:setScale(scale)
	self:setIconCenter(size)
end

function setSkillGroupIcon(self,groupId,size,scale)
	self._id = groupId
	local conf = SkillGroupConfig[groupId]
	local size = size or SkillIconSize 
	local res = string.format("res/common/icon/skill/%s.png",conf.icon)
	self._icon:setTexture(res)
	scale = scale or size / self._icon:getContentSize().width 
	self._icon:setVisible(true)
	self._icon:setScale(scale)
	self:setIconCenter()
end

--加把锁
function addLockIcon(self)
	local lock = cc.Sprite:create()
	local res = string.format("res/common/icon/lock.png")
	lock:setTexture(res)
	local size = self:getContentSize()
	lock:setAnchorPoint(0.5,0.5)
	lock:setPosition(size.width/2,size.height/2)
	self._ccnode:addChild(lock)
end

function setIconCenter(self,size)
	local size = size or self:getContentSize()
	self._icon:setAnchorPoint(0.5,0.5)
	self._icon:setPosition(size.width/2,size.height/2)
end

function setOpacity(self,val)
	self._ccnode:setOpacity(val)
	self._icon:setOpacity(val)
end

function setAnchorPoint(self,x,y)
	self._ccnode:setAnchorPoint(x,y)
	self._icon:setAnchorPoint(x,y)
end

function setPosition(self,x,y)
	self._ccnode:setPosition(x,y)
	self._icon:setPosition(x,y)
end

--货币图标
local CoinType = {
	["money"] = 1,
	["rmb"] = 1,
	["arena"] = 1,
	["phy"] = 1,
	["train"] = 1,
	["tour"] = 1,
	["peak"] = 1,
	["guild"] = 1,
	["exchange"] = 1,
	["exchangebig"] = 1,
	["moneybig"] = 1,
	["rmbbig"] = 1,
	["arenabig"] = 1,
	["phybig"] = 1,
	["trainbig"] = 1,
	["tourbig"] = 1,
	["peakbig"] = 1,
	["guildbig"] = 1,
	["skillRage"] = 1,
	["skillAssist"] = 1,
	["skillItem1"] = 1,
	["skillItem2"] = 1,
	["skillItem3"] = 1,
	["skillItem4"] = 1,
	["skillItem5"] = 1,
	["skillItem6"] = 1,
	["skillItem7"] = 1,
}
function setCoinIcon(ctrl,name)
	local res = "res/common/icon/coin/%s.png"
	local node = ctrl._ccnode or ctrl
	if CoinType[name] then
		local text = string.format(res,name)
		node:setTexture(text)
		--if name == "arena" then
		--else
		--	node:setScale(0.7)
		--end
	end
end

function setChapterIcon(self,name)
	local res = string.format("res/chapter/difficultyicon%s.png",name)
	local difficultyName = ChapterDefine.DIFFICULTY_NAME[name]
	if difficultyName then
		self._icon:setTexture(res)
		self._icon:setScale(64/82)
		self:setIconCenter()
	else
		self._icon:setVisible(false)
	end
end

return CommonGrid
