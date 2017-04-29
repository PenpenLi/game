module(...,package.seeall)

local ChapterConfig = require("src/config/ChapterConfig").Config
local LevelConfig = require("src/config/LevelConfig").Config
local FBConfig = require("src/config/FBConfig").Config
local ChapterDefine = require("src/modules/chapter/ChapterDefine")

debugFlag = false

cdTime = 0
boxList = {}
Container = {}
fightHeroes = {}

openedChapter={}

lastFightLevel = {}

function getChapterId(levelId)
	local conf = LevelConfig[levelId]
	if conf then
		return conf[1].chapterId
	end
end
function isLastLevel(levelId)
	if LevelConfig[levelId+1] then
		return false
	else
		return true
	end
end


--构造Container
for cid,chapter in pairs(ChapterConfig) do
	if Container[cid] == nil then
		Container[cid] = {}
	end
	for i=1,3 do
		if ChapterConfig[i] then
			Container[cid][i] = {}
		end
	end
end
local c=Container


for levelId,level1 in pairs(LevelConfig) do
	for difficulty,level2 in pairs(level1) do
		local chapterId = getChapterId(levelId)
		if Container[chapterId][difficulty] then
			Container[chapterId][difficulty][levelId] = {levelId=levelId,opened=false,passed=false,time=0,timesForDay=0}
		end
	end
end



-- 构造boxList
for chapterId,c in pairs(ChapterConfig) do
	if boxList[chapterId] == nil then boxList[chapterId] = {} end
	for difficulty,conf in pairs(c) do
		if boxList[chapterId][difficulty] == nil then boxList[chapterId][difficulty]={} end
		for i=1,3 do
			if conf['starLimit'..i] and conf['starLimit'..i] > 0 then
				boxList[chapterId][difficulty][i] = false
			end
		end
	end
end

function getDifficultyName(difficulty)
	return ChapterDefine.DIFFICULTY_NAME[difficulty] or ChapterDefine.DIFFICULTY_NAME[1]
end




-- for chapterId,_ in pairs(ChapterConfig) do 
-- 	if getTopOpenedDifficulty(chapterId) > 0 then
-- 		openedChapter[chapterId] = true
-- 	end
-- end


function getFirstLevel(chapterId)
	if ChapterConfig[chapterId] then
		return chapterId*100 + 1
	end
end

function getLevelsWithBox(chapterId,difficulty)
	local levels = Container[chapterId][difficulty]
	local levelId = getFirstLevel(chapterId)
	local ret = {}
	while LevelConfig[levelId] do
		table.insert(ret,levels[levelId])
		levelId = levelId + 1
	end
	local boxes = ChapterConfig[chapterId][difficulty]
	for i=3,1,-1 do
		if boxes['starLimit'..i] and boxes['starLimit'..i] > 0 then
			table.insert(ret,boxes['starLimit'..i]+1,{boxId=i,chapterId=chapterId,difficulty=difficulty})
		end
	end
	local ret2 = {}
	for i,level in ipairs(ret) do
		if level.boxId and ret[i-1].opened then
			table.insert(ret2,level)
		elseif level.levelId then
			if level.opened then
				table.insert(ret2,level)
			elseif ret[i-1].opened then
				table.insert(ret2,level)
			end
		end
	end
	return ret2
end

function isBoxAvailable(chapterId,difficulty)
	if difficulty then
		local conf = ChapterConfig[chapterId][difficulty]
		local star = getStar(chapterId,difficulty)
		for i=1,3 do
			if star >= conf['boxStar'..i] and not getBox(chapterId,difficulty,i) then
				return true
			end
		end
		return false
	else
		for i=1,3 do
			if isBoxAvailable(chapterId,i) == true then
				return true
			end
		end
		return false
	end
end


function getLevels(chapterId,difficulty)
	-- 返回本章节所有关卡
	local levels = Container[chapterId][difficulty]
	local levelId = getFirstLevel(chapterId)
	local ret = {}
	while LevelConfig[levelId] do
		table.insert(ret,levels[levelId])
		levelId = levelId + 1
	end
	return ret
end

function getStar(chapterId,difficulty)
	local star = 0
	local maxStar = 0
	if difficulty == 0 or difficulty == nil then
		for d,_ in pairs(ChapterConfig[chapterId]) do 
			local s,m = getStar(chapterId,d)
			star = star + s
			maxStar = maxStar + m
		end
	else
		for levelId,level in pairs(Container[chapterId][difficulty]) do
			if level.passed then
				star = star + (level.star or 0)
			end
			maxStar = maxStar + 3
		end
	end
	return star,maxStar
end

function getAllStar()
	-- 获得所有章节的星星
	local star = 0
	for chapterId,_ in pairs(ChapterConfig) do
		star = star + getStar(chapterId)
	end
	return star
end

function getTopOpenedLevelForAll()
	local levelId,difficulty
	for i,_ in ipairs(ChapterConfig) do
		local d = getTopOpenedDifficulty(i)
		if d > 0 then
			levelId = getTopOpenedLevel(i,d)
			difficulty = d 
		else
			break
		end
	end
	return levelId,difficulty
end

function getTopOpenedLevel(chapterId,difficulty)
	-- 获得某个章节的某个难度的最后一个已开放的关卡
	local id = 0
	if ChapterConfig[chapterId] and ChapterConfig[chapterId][difficulty] then
		for levelId,level in pairs(Container[chapterId][difficulty]) do
			if levelId > id and level.opened then
				id = levelId
			end
		end
	end
	return id
end

function getTopOpenedDifficulty(chapterId)
	-- 获得某个章节已开放的最高难度
	local d = 0
	if ChapterConfig[chapterId] then
		for i=1,3 do
			if ChapterConfig[chapterId][i] then
				local lv =Master.getInstance().lv
				local limit = ChapterConfig[chapterId][i].charLevel
				if limit <= lv then
					if Container[chapterId][i] then
						for levelId,level in pairs(Container[chapterId][i]) do
							if level.opened and i > d then
								d = i
							end
						end
					end
				end
			end
		end
	end
	return d
end

function isChapterOpened(chapterId)
	if ChapterConfig[chapterId] then
		for i=1,3 do
			if ChapterConfig[chapterId][i] then
				if Container[chapterId][i] then
					for levelId,level in pairs(Container[chapterId][i]) do
						if level.opened then
							return true
						end
					end
				end
			end
		end
	end
	return false
end

function getTopOpenedChapter()
	local topChapterId = 0
	for chapterId,c in ipairs(ChapterConfig) do 
		if getTopOpenedDifficulty(chapterId) > 0 then
			topChapterId = chapterId
		else
			break
		end
	end
	return topChapterId
end

function sendLevelStart(levelId,difficulty)
	Network.sendMsg(PacketID.CG_CHAPTER_FB_START,levelId,difficulty)
end



function getBox(chapterId,difficulty,boxId)
	-- 返回该宝箱是否已领取
	local b = boxList
	if b[chapterId] and b[chapterId][difficulty] and b[chapterId][difficulty][boxId] and b[chapterId][difficulty][boxId] == 1 then
		return true
	else
		return false
	end
end

function updateBox(chapterId,difficulty,boxId)
	if ChapterConfig[chapterId]  then
		if boxList[chapterId] == nil then boxList[chapterId] = {} end
		if boxList[chapterId][difficulty] == nil then boxList[chapterId][difficulty] = {} end
		boxList[chapterId][difficulty][boxId] = 1
	end
end

function isLevelPassed(levelId, difficulty)
	local chapterId = getChapterId(levelId)
	if not Container[chapterId] then return false end
	if not Container[chapterId][difficulty] then return false end
	if not Container[chapterId][difficulty][levelId] then return false end
	return Container[chapterId][difficulty][levelId].passed
end

function getNextLevel(chapterId,difficulty,levelId)
	local last = getLastLevel(chapterId)
	if last == levelId then
		if ChapterConfig[chapterId+1] then
			local first1 = getFirstLevel(chapterId)
			local first2 = getFirstLevel(chapterId+1)

			if difficulty == 3 then
				return {{chapterId+1,difficulty,first2},}
			else
				return {{chapterId+1,difficulty,first2},{chapterId,difficulty+1,first1}}
			end
		else
			local first = getFirstLevel(chapterId)
			if difficulty == 3 then
				return {}
			else
				return {{chapterId,difficulty+1,first}}
			end
		end
	else
		return {{chapterId,difficulty,levelId+1}}
	end

	-- else
	-- 	return {{chapterId,difficulty,levelId+1},}

	-- end
	-- if LevelConfig[levelId + 1] then
	-- 	return chapterId,levelId + 1
	-- elseif ChapterConfig[chapterId+1] then
	-- 	local first = getFirstLevel(chapterId+1)
	-- 	return chapterId+1,first
	-- else
	-- 	return 
	-- end
end

function getLastLevel(chapterId)
	local first = getFirstLevel(chapterId)
	local levelId = first
	local last = levelId
	while true do
		levelId = levelId + 1
		if LevelConfig[levelId] then
			last = levelId
		else
			break
		end
	end
	return last
end
function getPrevLevel(chapterId,difficulty,levelId)
	local first = getFirstLevel(chapterId)
	if first == levelId then
		if ChapterConfig[chapterId-1] then
			local last1 = getLastLevel(chapterId)
			local last2 = getLastLevel(chapterId-1)

			if difficulty == 1 then
				return {{chapterId-1,difficulty,last2},}
			else
				return {{chapterId-1,difficulty,last2},{chapterId,difficulty-1,last1}}
			end
		else
			local last = getLastLevel(chapterId)
			if difficulty == 1 then
				return {}
			else
				return {{chapterId,difficulty-1,last}}
			end
		end
	else
		return {{chapterId,difficulty,levelId-1},}
	end




	-- local first = getFirstLevel(chapterId)
	-- if first < levelId then
	-- 	return {{chapterId,levelId - 1},}
	-- else
	-- 	if chapterId == 1 then
	-- 		return {}
	-- 	else
	-- 		return {{chapterId-1,getLastLevel(chapterId-1)},{}}
	-- 	end
	-- end

end


function checkLevelOpened(chapterId,levelId,difficulty)
	local level = Container[chapterId][difficulty][levelId]
	if level.passed then
		return
	end
	local firstLevel = getFirstLevel(chapterId)
	if difficulty > 1 then
		--噩梦地狱难度要判断本章节前一个难度的关卡
		if not Container[chapterId][difficulty-1][levelId].passed then
			return
		end
	end

	local prevChapterId,prevLevelId = getPrevLevel(chapterId,levelId)
	if prevChapterId and prevLevelId then
		if Container[prevChapterId][difficulty][prevLevelId].passed then
			level.opened = true
		end
	end
	-- if firstLevel < levelId then
	-- 	-- 不是本章节第一个关卡
	-- 	if Container[chapterId][difficulty][levelId-1].passed then
	-- 		level.opened = true
	-- 		return
	-- 	end
	-- elseif chapterId == 1 and difficulty == 1 then
	-- 	return
	-- else
	-- 	-- 是本章节第一个关卡 需要判断上一个章节最后一关
	-- 	local last = getLastLevel(chapterId - 1)
	-- 	if Container[chapterId-1][difficulty][last].passed then
	-- 		level.opened = true
	-- 		return
	-- 	end
	-- end
end

function openLevel(chapterId,levelId,difficulty)
	-- levelId这个关卡通关后，开放其他关卡
	Container[chapterId][difficulty][levelId].opened = true
	Container[chapterId][difficulty][levelId].passed = true
	if difficulty < 3 then
		checkLevelOpened(chapterId,levelId,difficulty+1)
	end

	local nextChapterId,nextLevelId = getNextLevel(chapterId,levelId)
	if nextChapterId and nextLevelId then
		checkLevelOpened(nextChapterId,nextLevelId,difficulty)
	end

end

function updateLevel(levelId,difficulty,opened,passed,lastTime,timesForDay,star,buyTimes)
	-- 更新关卡的状态
	local chapterId = getChapterId(levelId)
	if not Container[chapterId] then return end
	if not Container[chapterId][difficulty] then return end
	if not Container[chapterId][difficulty][levelId] then return end
	Container[chapterId][difficulty][levelId].levelId = levelId
	Container[chapterId][difficulty][levelId].opened = opened
	Container[chapterId][difficulty][levelId].passed = passed
	Container[chapterId][difficulty][levelId].time = lastTime
	Container[chapterId][difficulty][levelId].timesForDay = timesForDay
	Container[chapterId][difficulty][levelId].buyTimes = buyTimes
	if Container[chapterId][difficulty][levelId].star == nil or Container[chapterId][difficulty][levelId].star < star then
		Container[chapterId][difficulty][levelId].star = star
	end

	if passed then
		openedChapter[chapterId] = true
	end

	-- 如果passed，则要open相关的章节和关卡
	if passed then
		-- if levelId == 110 then
		-- 	db()
		-- end
		for _,level in ipairs(getNextLevel(chapterId,difficulty,levelId)) do
			local flag = true

			for _,le in ipairs(getPrevLevel(level[1],level[2],level[3])) do
				if not Container[le[1]][le[2]][le[3]].passed then
					flag = false
				end
			end
			if flag then
				Container[level[1]][level[2]][level[3]].opened = true
			end
		end

		-- if isLastLevel(levelId) and difficulty < 3 then
		-- 	-- 如果本关是对应章节的最后一关，则需要判断开启本章节的下一个难度第一关

		-- 	-- 下一个难度第一关的前一关是否通过
		-- 	local first = getFirstLevel(chapterId)
		-- 	local prevChapterId,prevLevelId = getPrevLevel(chapterId,first)
		-- 	if prevChapterId == nil or Container[prevChapterId][difficulty+1][prevLevelId].passed then
		-- 		Container[chapterId][difficulty+1][first].opened = true
		-- 	end
		-- end
		-- local nextChapterId,nextLevelId = getNextLevel(chapterId,levelId)
		-- if nextChapterId and nextLevelId then
		-- 	if difficulty == 1 or Container[nextChapterId][difficulty-1][nextLevelId].passed then
		-- 		Container[nextChapterId][difficulty][nextLevelId].opened = true
		-- 	end
		-- end



		-- local nextLevel = LevelConfig[levelId+1]
		-- if nextLevel then
		-- 	-- 不是本章节的最后一个关卡
		-- 	Container[chapterId][difficulty][levelId+1].opened = true
		-- else
		-- 	-- 章节的最后一个关卡
		-- 	-- 打开本章节下一个难度第一个关卡
		-- 	if Container[chapterId][difficulty+1] then
		-- 		local firstLevelId = getFirstLevel(chapterId)
		-- 		if Container[chapterId][difficulty+1][firstLevelId] then
		-- 			Container[chapterId][difficulty+1][firstLevelId].opened = true
		-- 		end
		-- 	end
		-- 	-- 打开下章节的第一个章节的对应难度
		-- 	if Container[chapterId+1] and Container[chapterId+1][difficulty] and difficulty == 1 then
		-- 		local first = getFirstLevel(chapterId+1)
		-- 		Container[chapterId+1][difficulty][first].opened = true
		-- 	end
		-- end
	end
end

function updateLevelInfo(levelId,difficulty,timesForDay)
	local chapterId = getChapterId(levelId)
	if Container[chapterId][difficulty][levelId] then
		Container[chapterId][difficulty][levelId].timesForDay = timesForDay
	end
end

updateLevel(101,1,true,false,0,0)

function getLevel(levelId,difficulty)
	local chapterId = getChapterId(levelId)
	return Container[chapterId][difficulty][levelId]
end

function buyTimes(levelId,difficulty,no)
	local level = getLevel(levelId,difficulty)
	level.buyTimes = no
	level.timesForDay = 0
end

function getLevelInfo(levelId,difficulty)
	local c = Container
	local level = getLevel(levelId,difficulty)
	if level then
		-- if not Common.isToday(level.time) then
		-- 	level.time = 0 
		-- 	level.timesForDay = 0
		-- end
		local timesForDay = level.timesForDay
		if not Common.isToday(level.time) then
			timesForDay = 0
		end
		return level.opened,level.passed,timesForDay,level.buyTimes or 0,level.star or 0
	end
end

function getLevelNo(levelId)
	-- 返回第几关
	local chapterId = getChapterId(levelId)
	local levels = getLevels(chapterId,1)
	local no = 0
	for i,level in ipairs(levels) do
		no = no + 1
		if level.levelId == levelId then
			return no
		end
	end
	return no
end

function getChapterTitle(chapterId)
	return ChapterConfig[chapterId][1].chapterTitle
end

function getLevelTitle(levelId)
	if LevelConfig[levelId] then
		return LevelConfig[levelId][1].levelTitle
	else
		return ''
	end
end

function getChapterIntro(ChapterId)
	return ChapterConfig[chapterId][1].intro
end	

function getLevelListByReward(id)
	local levelList = {}
	local sorted = {}
	local topOpenedLevelId,topOpenedDifficulty = getTopOpenedLevelForAll()

	-- for levelId,level in 
	for levelId,level in pairs(LevelConfig) do 
		for difficulty,conf in pairs(level) do 
			for itemId,_ in pairs(conf.randReward) do
				if itemId == id then
					table.insert(levelList,{levelId=levelId,difficulty=difficulty})
					break
				end
			end
			for itemId,_ in pairs(conf.cycleReward) do
				if itemId == id then
					table.insert(levelList,{levelId=levelId,difficulty=difficulty})
					break
				end
			end
		end
	end
	local function sortLevel(a,b)
		if a.levelId ~= b.levelId then
			return a.levelId < b.levelId
		else
			return a.difficulty <= b.difficulty
		end
	end
	table.sort(levelList,sortLevel)
	local no = 0
	for i,a in ipairs(levelList) do
		if a.levelId >= topOpenedLevelId and a.difficulty > topOpenedDifficulty then
			no = i 
		end
	end
	local sno = 0
	local eno = 0
	if #levelList <= 6 then
		sno = 1
		eno = #levelList
	elseif no <= 3 then
		sno = 1
		eno = no + 2
	elseif no > #levelList - 2 then
		sno = no - 3
		eno = #levelList
	else
		sno = no -3 
		eno = no + 2
	end
	local ret = {}
	for i=sno,eno do
		table.insert(ret,levelList[i])
	end
	return ret
end
-- function getFBListByReward(id)
-- 	local fbList = {}
-- 	for fbId,conf in pairs(FBConfig) do 
-- 		for itemId,_ in pairs(conf.randReward) do
-- 			if itemId == id then
-- 				table.insert(fbList,fbId)
-- 				break
-- 			end
-- 		end
-- 	end
-- 	return fbList
-- end

function setLastFightLevel(difficulty,levelId)
	local chapterId = getChapterId(levelId)
	lastFightLevel[chapterId] = {difficulty = difficulty,levelId = levelId}
end

function getLastFightLevel(chapterId)
	return lastFightLevel[chapterId]
end
