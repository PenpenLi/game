module(..., package.seeall)

local stack = {}

function push(groupId)
	local has,index = hasGroup(groupId)
	if has == false then
		table.insert(stack, groupId)
	end
	GuideManager.dispatchEvent(GuideDefine.GUIDE_STACK_UPDATE)
end

function hasGroup(groupId)
	for index,id in pairs(stack) do
		if id == groupId then
			return true,index
		end
	end
	return false,0
end

function pop(groupId)
	local has,index = hasGroup(groupId)
	if has == true then
		table.remove(stack, index)
	end
	GuideManager.dispatchEvent(GuideDefine.GUIDE_STACK_UPDATE)
end

function getTop()
	local top = table.remove(stack)
	return top
end
