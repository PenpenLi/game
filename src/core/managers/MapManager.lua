module("MapManager",package.seeall)

mapLayer = mapLayer or nil
currentMap = currentMap or nil
mapConfig = mapConfig or nil
local _mapCtors = _mapCtors or {} --地图构造器集合

function init(config)
	assert(config, " mapConfig is invalid !")
	mapConfig = config
	local skin = {name="map",type="Container",x=0,y=0,children={}}
	skin.width = Stage.width
	skin.height= Stage.height
	mapLayer = Control.new(skin)
	mapLayer._ccnode:retain() --hold
end

--注册地图构造器
function regMapCtor(mapId, mapCtor)
	_mapCtors[mapId] = mapCtor
end

function selectMap(mapId)
	if currentMap then
		currentMap:mapExit()
	end
	local mapCtor = _mapCtors[mapId] or Map
	currentMap = mapCtor.new(mapId)
	resetMap()
	UnitManager.resetStory()
	currentMap:mapEnter()
	return currentMap
end

function resetMap()
	mapLayer:removeAllChildren()
	mapLayer:addChild(currentMap)
	mapLayer:setPosition(0,0)
	local size = CCSizeMake(currentMap.width,currentMap.height)
	mapLayer:setContentSize(size)
end

