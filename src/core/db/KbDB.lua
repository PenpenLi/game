--[[**************************************************************************** 
example:
local db = KbDB:instance()
--打开数据库
db:open("test")
--执行sql语句建表
db:execute("create table if not exists foo(id integer primary key autoincrement,name text")
--或者采用自动建表
KbDB:instance():checkTb("foo",DBStruct.foo)
--插入数据 
db:insert('foo',{name="杂碎",attr={hp=200,mp=100}})	  --insert into foo(name,attr) values("杂碎","......")
--替换数据(根据插入字段中的主键判断，如果已存在该记录则删除该记录并重新插入)
db:replace('foo',{name="杂碎",attr={hp=200,mp=100}})  --repalce into foo(name,attr) values("杂碎","......")
--更新数据 
db:update('foo',{attr={hp=300,mp=200}},{id=1})   	      --update foo set attr="....." where id=1
--查找数据
local rows = db:find("foo",{},{id=1})   		  --select * from foo where id=1
local rows = db:find("foo",{"name","id"},{id=1})  --select name,id from foo where id=1
--删除数据
db:delete('foo',{id=1})    --delete from foo where id=1
--计数
db:count('foo',{name="xxx"})  						  --select count(*) from foo where name="xxx"
--关闭数据库
db:close()
****************************************************************************]] 
module("KbDB",package.seeall)

local Instance = Instance or nil

function KbDB:instance()
	local o = Instance
	if o then return o end
	o = {
		sqlite = nil,
		dbName = nil, 
		tbName = nil, 
		opened = false,
	}
	trace("instance>>>")
	setmetatable(o,{__index=self})
	o.sqlite = KbSqlite:new()
	Instance = o
	return o
end

function KbDB:isOpen()
	return self.opened
end

function KbDB:open(dbName,dbPath)
	assert(self.dbName ~= dbName,dbName .. " had open,please call close() first")
	if not self:isOpen() then
		dbName = dbPath .. dbName 
		if self.sqlite:open(dbName) then
			self.dbName = dbName
			self.opened = true
		end
	end
	return self:isOpen()
end

function KbDB:close()
	assert(self:isOpen(),"open db first")
	self.sqlite:close()
	self.opened = false
end

function KbDB:insert(tbName,values)
	assert(self:isOpen(),"open db first")
	return self.sqlite:insert(tbName,values)
end

function KbDB:replace(tbName,values)
	assert(self:isOpen(),"open db first")
	return self.sqlite:insert(tbName,values,1)
end

function KbDB:update(tbName,fields,where)
	assert(self:isOpen(),"open db first")
	return self.sqlite:update(tbName,fields,where)
end

function KbDB:delete(tbName,where)
	assert(self:isOpen(),"open db first")
	return self.sqlite:remove(tbName,where)
end

function KbDB:count(tbName,where)
	assert(self:isOpen(),"open db first")
	return self.sqlite:count(tbName,where)
end

function KbDB:find(tbName,fields,where)
	assert(self:isOpen(),"open db first")
	return self.sqlite:find(tbName,fields,where)
end

function KbDB:checkTb(tbName,conf)
	local info = self:showTb(tbName)
	--建表
	if not info or next(info) == nil then
		return self:createTb(tbName,conf)
	--新增字段
	else
		local newable = {}
		for k,cf in pairs(conf) do
			newable[k] = true
		end
		for k,cf in pairs(conf) do
			for _,v in pairs(info) do
				if cf[1] == v.name then
					newable[k] = false
				end
			end
		end
		for k,isNew in pairs(newable) do
			if isNew then
				self:addColumn(tbName,conf[k][1],conf[k][2],conf[k][3])
			end
		end
	end
end

function KbDB:showTb(tbName)
	local sql = string.format("PRAGMA table_info(%s)",tbName)
	return self:execute(sql)
end

--@fields table {{fieldName,fieldType,constraint},{.......},.......}
function KbDB:createTb(tbName,fields)
	local createSql = string.format("create table if not exists `%s`(",tbName);
	for _,field in pairs(fields) do
		field[3] = field[3] or ''		
		createSql = createSql .. string.format("%s %s %s,",field[1],field[2],field[3])
	end
	createSql = createSql:sub(0,createSql:len()-1) .. ')'
	return self:execute(createSql)
end

function KbDB:addColumn(tbName,fieldName,fieldType,constraint)
	constraint = constraint or ''
	local addSql = string.format("alter table %s add column %s %s %s",tbName,fieldName,fieldType,constraint)
	return self:execute(addSql)
end

function KbDB:execute(sqlStr)
	assert(self:isOpen(),"open db first")
	return self.sqlite:execute(sqlStr)
end



