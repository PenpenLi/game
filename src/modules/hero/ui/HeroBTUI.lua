module("HeroBTUI", package.seeall)
setmetatable(_M, {__index = Control})
local Hero = require("src/modules/hero/Hero")
local OpenLvConfig = require("src/config/OpenLvConfig").Config

function new(name,btLv)
	local ctrl = Control.new(require("res/common/LvUpSkin"), {"res/common/LvUp.plist"})
	ctrl.name = "HeroBTUI"
	setmetatable(ctrl,{__index = _M})
	ctrl:init(name,btLv)
	return ctrl
end

function init(self,name,btLv)
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
	self.dst:setVisible(false)
	self.src:setVisible(false)
	self.arrow2:setVisible(false)




	self:addArmatureFrame("res/hero/effect/break/breakEffect.ExportJson")
	self:addArmatureFrame(string.format("res/armature/%s/small/%s.ExportJson",string.lower(name),name))
	self.arm = ccs.Armature:create(name)
	
	local px,py = self.arrow2:getPosition()
	local size = self.arrow2:getContentSize()

	local aniName = Hero.getBTAnimation(btLv)
	if aniName then
		self.ani1= ccs.Armature:create('breakEffect')
		self._ccnode:addChild(self.ani1)
		self.ani1:getAnimation():playWithNames({aniName},0,true)
		self.ani1:setPosition(px+size.width/2,py+size.height/2+20)
	end

	self.ani2= ccs.Armature:create('breakEffect')
	self._ccnode:addChild(self.ani2,2)
	self.ani2:getAnimation():playWithNames({"突破成功"},0,false)
	self.ani2:setPosition(px+size.width/2,py+size.height/2+150)

	self._ccnode:addChild(self.arm,1)
	self.arm:setPosition(px+size.width/2,py+size.height/2-68)
	self.arm:getAnimation():playWithNames({'待机'},0,true)
	self.arm:setScale(0.9)

	local attrs = {}

	for i,attr in ipairs({'atk','def','finalAtk','finalDef','maxHp'}) do
		local attrName = Hero.getAttrCName(attr)
		table.insert(attrs,{cname=attrName,src=Hero.getBTAttr(attr,btLv-1),dst=Hero.getBTAttr(attr,btLv),mtype=1})
	end
	local maxId = 0
	for i=1,5 do
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


return HeroBTUI
