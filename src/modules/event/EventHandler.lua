module(...,package.seeall)



function onGCEventNotice(eventId)
	UIManager.addUI("src/modules/event/ui/EventUI",eventId)
end



