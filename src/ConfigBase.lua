module("ConfigBase",package.seeall)
--全局通用配置
PlatformName = require("src/platform/PlatformName")
local conf = require("src/platform/PlatformConfig").Config[PlatformName]
Platform =  conf.id
os = conf.os

ServerURL = conf.serverURL --获取服务器列表地址
SvrList = {}
--[[
SvrList = {
	{sid=1,name="本地服",ip="172.16.63.54",port=52520,tag=1,state=1,version=0,serverId="s1",coreVersion="1.0"}, 
	{sid=2,name="内网服",ip="172.16.63.68",port=52520,tag=1,state=1,version=0,serverId="s1"},
	{sid=3,name="外网服",ip="61.147.184.53",port=20000,tag=1,state=1,version=0,serverId="s1"},
}
--]]
--登录服务器ip 端口 等
SId = 0
SvrId = nil
SvrName = nil
ServerIP = nil		
ServerPort = nil 	
GlobalVersion = nil			--资源全局版本号
NewVersion = nil		
CoreVersion = nil	--底层版本号

Debug = conf.debug == 1


ConnectTimeout = 10
ReadTimeout = 30

--资源管理相关
CheckVersion = conf.checkVersion == 1 	--是否检查版本
ResourceURL = nil
ResourceMapFile = "filemap.json"
FileRootPath = ""  --原始资源路径
DownloadPath = cc.FileUtils:getInstance():getWritablePath() .. "/download/" --下载临时路径
ReleasePath = cc.FileUtils:getInstance():getWritablePath() .. "/release/" --资源更新路径

--是否关闭引导
--isGuideNil = true

--渠道ID
ChannelId = 0 
ChannelName = ""
--推送服务相关
PushAppId = conf.pushAppId 

--统计服务相关
StatisAppId = conf.statisAppId
StatisAppKey = conf.statisAppKey

--使用User SDK
UseUserSDK = conf.useUserSDK == 1

--错误报告
ReportURL = conf.reportURL
ReportKey = conf.reportKey


return ConfigBase


