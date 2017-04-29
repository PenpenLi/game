module(..., package.seeall)

function onGCRankList(rankList)
	local rankUI = Stage.currentScene:getUI():getChild("Rank")
	if rankUI then
		rankUI:refresh(rankList)
	end
end

function onGCRankCheck(info)
	local rankUI = Stage.currentScene:getUI():getChild("Rank")
	if rankUI then
		local tb = {}
		local len = #info.fightList
		for i=1,4 do
			local record = info.fightList[i]
			if record then
				if i == len then
					tb[4] = record
				else
					tb[i] = record
				end
			end
		end
		info.fightList = tb
		rankUI:showTeamUI(info)
	end
end
