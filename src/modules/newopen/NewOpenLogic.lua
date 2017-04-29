module(...,package.seeall)

function queryTime()
	Network.sendMsg(PacketID.CG_NEW_OPEN_TIME)
	Network.sendMsg(PacketID.CG_NEW_OPEN_QUERY)
end
