module("StrengthLabel",package.seeall)
setmetatable(_M,{__index = Control})
id2type = {
	[1] = "fight",
	[2] = "defense",
	[3] = "maxhp",
	[4] = "storm",
	[5] = "assist",
	[6] = "strike"
}

function new()
	local ctrl = Control.new(require("res/strength/StrengthLabelSkin"),{"res/strength/StrengthLabel.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function init(self)
end

function setLabel(self,id,lv)
	self:setTextVisible(id,lv)
	self:setBgVisible(lv)
end

function setTextVisible(self,id,lv)
	local text = self.text
	for k,v in pairs(id2type) do
		for i = 0,4 do
			text[v]["lv"..i]:setVisible(false)
		end
		text[v]:setVisible(false)
	end
	text[id2type[id]]["lv"..lv]:setVisible(true)
	text[id2type[id]]:setVisible(true)
end

function setBgVisible(self,lv)
	local topbg = self.topbg
	for i = 1,4 do
		topbg["lvbg"..i]:setVisible(false)
	end
	local j = lv == 0 and 4 or lv
	topbg["lvbg"..j]:setVisible(true)
end

return StrengthLabel
