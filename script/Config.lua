module(..., package.seeall)

ISGAMESVR = true
ISTESTCLIENT = true
ISOPENMONITOR = false     --//性能监控日志
MONITOR_MS = 1           --//性能监控阀值，毫秒级人物

GAME_IO_LISTEN_PORT=20001          --// Logic接入端口
GAME_HTTP_LISTEN_PORT=12345       --// Http接入端口
--开服相关
ADMIN_KEY   = "1234567"           --管理http接口key
ADMIN_AGENT = "4399"              --代理

key = "bx32017616e8396cbfae965ba2162f32"        --登录key
payKey = "bx32017616e8396cbfae965ba2162f32"     --充值key

-- 允许访问管理接口的IP列表
ADMIN_IP_LIST = {"127.0.0.1","192.168.1.125"}

-- 正常游戏服相关字段 跨服pk服可不配置
--DBIP="172.17.6.133"
DBIP="127.0.0.1"
--DBIP="123.207.98.55"
DBNAME="wolf"
DBUSER="wolf"
DBPWD="wolf"
DBPORT=27017		--数据库端口号

SVRNAME="[01]"

MSVRIP="127.0.0.1"
MSVRPORT=20000
MSVRHTTPPORT=30000

-- 跨服pk服相关字段 正常游戏服可不配置
GSVR = {}
GSVR[1] = {svrName="[01]", ip="127.0.0.1", ioPort = 4399, httpPort = 10000, dbIP = "127.0.0.1", dbName = "jydb", dbUser="test", dbPwd = "test123"}

-- 游戏功能相关设定
ISCLOSEGMCOMMAND = 1
QQGROUP = '玩家群1  189024862'

--开服时间
newServerDate={year=2012,month=7,day=30,hour=12,min=0,sec=0}
newServerTime=os.time(newServerDate)

