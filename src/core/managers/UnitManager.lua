module("UnitManager",package.seeall)

storyLayer = storyLayer or nil
function init()
	local skin = {name="story",type="Container",x=0,y=0,children={}}
	skin.width = Stage.width
	skin.height= Stage.height
	storyLayer = Control.new(skin)
	storyLayer._ccnode:retain() --hold
end

function resetStory()
	storyLayer:removeAllChildren()
	storyLayer:setPosition(0,0)
	local size = CCSizeMake(MapManager.currentMap.width,MapManager.currentMap.height)
	storyLayer:setContentSize(size)
end

function addUnit(unit)
	--storyLayer:addChild(unit, unit:getPositionY())
	storyLayer:addChild(unit)
end

function getUnitByName(name)
	return storyLayer:getChild(name)
end

function getUnit(objId,objType)
	local unit
	if storyLayer._children then
		for k,v in ipairs(storyLayer._children) do
			if objType == v.uiType and objId == v.id then
				unit = v
				break
			end
		end
	end
	return unit
end

function removeUnit(unit)
	storyLayer:removeChild(unit)
end

function zOrderUnits()
	if storyLayer._children then
		for k,v in ipairs(storyLayer._children) do
			v:reorder(v:getPositionY())
		end
	end
end
