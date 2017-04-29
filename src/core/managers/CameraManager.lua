module("CameraManager",package.seeall)

local padding = 300
function isInDragWin(x, y) --拖窗
	if x < padding or y < padding then
		return false
	end

	if x > Stage.width - padding or y > Stage.height - padding then
		return false
	end

	return true 
end

--设置摄像头中点（会出界和黑边）
function focus(x, y) 
	local px = Stage.width / 2 - x
	local py = Stage.height / 2 - y
	UnitManager.storyLayer:setPosition(px, py)
	MapManager.mapLayer:setPosition(px, py)
end

--todo 
function moveTo(x, y, speed) 
end

--镜头跟随
function follow(role) 
	local x,y = role:getPosition()
	x, y = MapManager.currentMap:mapWatch(x, y)
	watch(x, y)
--	focus(x,y)
	--[[
	if not isInDragWin(x, y) then
		watch(x, y)
	end
	]]
end

--观察点（点出现在镜头中，不会出界）
function watch(x, y)
	if x < Stage.width/2 then
		x = Stage.width/2
	elseif x > MapManager.currentMap.width - Stage.width/2 then
		x = MapManager.currentMap.width - Stage.width/2 
	end
	if y < Stage.height/2 then
		y = Stage.height/2
	elseif y > MapManager.currentMap.height - Stage.height/2 then
		y = MapManager.currentMap.height - Stage.height/2 
	end
	focus(x,y)
end

