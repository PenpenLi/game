module("ChainActiveUI", package.seeall)
setmetatable(_M, {__index = Control})
local Hero = require("src/modules/hero/Hero")
local OpenLvConfig = require("src/config/OpenLvConfig").Config
local PartnerChainConfig = require("src/config/PartnerChainConfig").Config
local PartnerConfig = require("src/config/PartnerConfig").Config
local OriginalPos = OriginalPos or {}

function new(id,changeAttrs)
	local ctrl = Control.new(require("res/common/LvUpSkin"), {"res/common/LvUp.plist"})
	ctrl.name = "ChainActiveUI"
	setmetatable(ctrl,{__index = _M})
	ctrl:init(id,changeAttrs)
	return ctrl
end

function init(self,id,changeAttrs)
	self.canRemove = false
	self:addEventListener(Event.TouchEvent,function(self,event) 
		if event.etype == Event.Touch_ended then
			if self.canRemove then
				UIManager.removeUI(self)
				Master.getInstance():dispatchEvent(Event.LvUpUIEnd,{etype=Event.Touch_ended})
				GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_SUB_COMPONENT)
			end
		end
	end)
	self:addArmatureFrame("res/common/effect/lvUpDesc/LvUp.ExportJson")
	self.master = Master.getInstance()
	local cName
	cName = self.master.name 
	CommonGrid.bind(self.src.head)
	local chainCfg = PartnerChainConfig[id]
	local icon = chainCfg.icon
	local res = string.format("res/common/icon/partner/%s.png",icon)
	self.src.head._icon:setTexture(res)
	self.src.head:setPositionX(-65)
	self.src:setPositionX(self.arrow2:getPositionX())
	self.src.txtname:setAnchorPoint(0.5,0)
	self.src.txtname:setString(chainCfg.name)
	self.dst:setVisible(false)
	self.arrow2:setVisible(false)
	Common.setBtnAnimation(self.src._ccnode,"LvUp",effectName or "partner",{y=100})
	--self.src.txtname:setAnchorPoint(0.5,0)
	--self.src.txtname:setString(cName)
	--self.dst.txtname:setAnchorPoint(0.5,0)
	--self.dst.txtname:setString(cName)

	local attrs = {}
	for k,v in pairs(changeAttrs) do
		local heroName = v.name
		local cName = Hero.getCNameByName(heroName)
		local attrName = Hero.getAttrCName(v.attrname)
		local hero = Hero.heroes[heroName]
		if hero then
			table.insert(attrs,{cname = cName..attrName,src = v.preAttrVal,dst = v.attrVal,mtype = 1})
		else
			table.insert(attrs,{cname = string.format("激活%s后可获得该宿命加成",cName),src = v.preAttrVal,dst = v.attrVal,mtype = 2})
		end
	end
	table.sort(attrs,function(a,b)return a.mtype < b.mtype end)
	local maxId = 0
	local hasStarUp = false
	for i = 1,5 do
		self.src["star"..i]:setVisible(false)
		self.dst["star"..i]:setVisible(false)
		self["line"..i]:setVisible(false)
		self["line"..i].txtname:setAnchorPoint(1,0)
		self["line"..i].txtsrc:setAnchorPoint(0.5,0)
		self["line"..i].txtdst:setAnchorPoint(0.5,0)
		if attrs and attrs[i] then
			maxId = maxId + 1
			local attrName = attrs[i].cname
			if not attrName then
				attrName = Hero.getAttrCName(attrs[i].name)	
			end
			if attrs[i].mtype == 1 then
				self["line"..i].txtname:setString(attrName..":")
				self["line"..i].txtsrc:setString(attrs[i].src)
				if attrs[i].dst then
					self["line"..i].txtdst:setString(attrs[i].dst)
				else
					self["line"..i].arrow:setVisible(false)
					self["line"..i].txtdst:setVisible(false)
				end
			elseif attrs[i].mtype == 2 then
				self["line"..i].txtname:setColor(176,231,27)
				self["line"..i].txtname:setString(attrName)
				self["line"..i].txtname:setPositionX(self["line"..i].txtdst:getPositionX()+10)
				self["line"..i].txtsrc:setVisible(false)
				self["line"..i].arrow:setVisible(false)
				self["line"..i].txtdst:setVisible(false)
			end
		end
	end
	UIManager.playMusic("lvUpArt")
	local function lineMove(curId)
		if curId <= maxId then
			local line = self["line"..curId]
			line:setVisible(true)
			local callBackFuc = function()
				--if curId >= maxId then
				--	--self:dealEnd()
				--	print("lineMove end")
				--else
				--	lineMove(curId+1)
				--end
				if curId >= maxId then
					self.canRemove = true
				end
				lineMove(curId+1)
			end
			local oldx = line:getPositionX()
			line:setPositionX(oldx-line:getContentSize().width)
			local moveto = cc.MoveTo:create(0.1,cc.p(oldx,line:getPositionY()))
			local callBack=cc.CallFunc:create(callBackFuc)
			line:runAction(cc.Sequence:create({moveto,callBack}))
			UIManager.playMusic("lvUpAttr")
		else
			self.canRemove = true
		end
	end
	self:addTimer(function() 
		lineMove(1)
	end, 0.3, 1, self)
	self:openTimer()
end

function uiEffect(self)
	return UIManager.FIRST_TEMP_RAW
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
end


return ChainActiveUI
