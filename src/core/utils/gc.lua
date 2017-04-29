module("gc", package.seeall) 

function start() 
	collectgarbage( "start" ) 
end 

function restart() 
	collectgarbage( "restart" ) 
end 

--完成一轮回收 
function collect() 
	collectgarbage( "collect" ) 
end 

--当前Lua内存占用byte 
function count() 
	return collectgarbage( "count" ) * 1024 
end 
