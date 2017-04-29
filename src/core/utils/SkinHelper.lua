module("SkinHelper",package.seeall)

-- 控件皮肤选择复制
-- list 需要拷贝的child名字表,child是浅拷贝
function CopyControlSkin(skin, list)
	local retSkin = {
		name = skin.name,
		type = skin.type,
		x = skin.x,
		y = skin.y,
		width = skin.width,
		height = skin.height,
		children={}
	}
	if skin.chindren then
		for k,v in ipairs(skin.children) do
			if list then
				for _,childName in ipairs(list) do 
					if v.name == childName then
						table.insert(retSkin.children, v)
					end
				end
			else
				table.insert(retSkin.children,v)
			end
		end
	end
	return retSkin
end

-- 获取child皮肤
function getChildSkin(skin, childName)
	if skin.children then
		for k, v in ipairs(skin.children) do
			if v.name == childName then
				return v
			end
		end
	end
end
