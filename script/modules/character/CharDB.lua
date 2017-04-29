module(..., package.seeall)
local ns = "char"                --数据库表
local QueryByAccount={ account=""}     --按帐号查询
local QueryByName = { name=""}         --按角色名查询
local CommonDefine = require("core.base.CommonDefine")
local CharacterDefine = require("modules.character.CharDBDefine")
local CharDBDefine = require("modules.character.CharDBDefine")
local DB = require("core.db.DB")
local Util = require("core.utils.Util")
local BaseMath = require("modules.public.BaseMath")

function new()
	local o =   {
		svrName = 	"",	--服务器名
		account =   "",	--账号
		name    =   "",	--角色名
		pAccount = "",	--平台账号
		channelId = 0,	--渠道号
		createDate = os.time(),	--创建时间
		--default start
		rmb = 0,				--充值RMB
		money = 0,				--铜币
		sex = CharacterDefine.HUMAN_SEX_MALE, --性别 0,1
		isOnline   = 0,			--是否在线
		settings   = {
			music = 1,	
			effect = 1,
		},	
		--default end
		
		olTime = 0, 	--玩家总在线时间时长，单位秒
		olDayTime = 0, --今日登录累计在线时间
		lastDate = os.date("%Y%m%d",os.time()), --最后登录日期
		lastLogin = os.time(), --最近一次登入
		lastLogout = os.time(), --最后下线时间
		accumulateDays = 1, --累计登陆天数
		lastSaveTime = os.time(),		--最后存库时间
		ip = "", --登录IP
    }
	setmetatable(o, {__index = _M}) 
	return o;
end

function isNameExistInDB(name)
    QueryByName.name = name
    --return g_oMongoDB:Count(ns,QueryByName) > 0
    local count = DB.Count(ns,QueryByName)
    if count then 
        return count > 0
    else
        return false
    end
end

-- 直接查询db 获取离线角色的特定属性
function getCharPropertyOffLine(name, queryDescrib, isAccount)
    local query = {}
    
    if isAccount then
        query.account = name
    else
        query.name = name
    end
    
    return DB.Find(ns,query,queryDescrib)
end

-- 直接查询db 修改离线角色的特定属性
function setCharPropertyOffLine(name, oValue, isAccount)
    oValue._id = nil

    local query={}
    if isAccount then
      query.account = name
    else
      query.name=name
    end
    local modify={};
    modify["$set"]=oValue
    return DB.Update(ns,query,modify)
end

function loadByAccount(self,account)
	QueryByAccount.account = account
	return DB.Find(ns,QueryByAccount,self)
end

function loadByName(self,name)
    QueryByName.name = name;
    return DB.Find(ns,QueryByName,self)
end

function save(self,isSync)
--local nt1 =  _CurrentTime()
    local query={}
	query._id=self._id
    print("chardb save _id="..tostring(self._id))
    if type(self._id)== 'table' then
        Util.print_r(self._id)
    end 
    local ret = DB.Update(ns,query,self,isSync)
    if not ret then
        LogErr("[mongodb]","char db save fail name:" .. self.name .. "," .. self._id)
    end
--print('-human save db:',_CurrentTime() - nt1)
    return ret
end

function add(self,isSync)
    return DB.Insert(ns,self,isSync)
end

function resetMeta(self)
    setmetatable(self, {__index=_M});
end

