module(...,package.seeall)
beginTime = 0
endTime = 0
getEndTime = 0

function queryTime()
	Network.sendMsg(PacketID.CG_RECHARGE_TIME)
end

function setData(beginTime1,endTime1,getEndTime1)
	beginTime = beginTime1
	endTime = endTime1
	getEndTime = getEndTime1
end
