local GiftDefine = require("src/modules/gift/GiftDefine")

GiftDefine.ConditionFunc = {}

for k,v in pairs(GiftDefine.ConditionType) do
	GiftDefine.ConditionFunc[v] = k
end

GiftDefine.EffectFunc = {}
for k,v in pairs(GiftDefine.EffectType) do
	GiftDefine.EffectFunc[v] = k
end
