module(...,package.seeall)
Config={
[1] = {id=1, name="一战百年", group={[1603001]=20,[1603002]=20,[1601028]=20,[1601001]=20}, attr={maxHp=20}, icon="13ywqs", },
[2] = {id=2, name="直传弟子", group={[1603001]=20,[1603002]=20,[1601029]=20,[1601001]=20}, attr={atk=15,finalAtk=15}, icon="32sldc", },
[3] = {id=3, name="激情白羊", group={[1603001]=20,[1603002]=20,[1601029]=20,[1601006]=20}, attr={maxHp=20}, icon="33jxqd", },
[4] = {id=4, name="烽火燎原", group={[1603001]=20,[1603002]=20,[1601016]=20,[1601001]=20}, attr={atk=15,finalAtk=15}, icon="12gdsx", },
[5] = {id=5, name="神器家族", group={[1603001]=30,[1603002]=30,[1603003]=30,[1601017]=30,[1601028]=30,[1601001]=30}, attr={atk=24,finalAtk=24}, icon="14elcs", },
[6] = {id=6, name="新日本队", group={[1603001]=30,[1603002]=30,[1603003]=30,[1601003]=30,[1601002]=30,[1601001]=30}, attr={maxHp=30}, icon="1yzbn", },
[7] = {id=7, name="雷电无双", group={[1603001]=20,[1603002]=20,[1601023]=20,[1601002]=20}, attr={maxHp=20}, icon="46chsx", },
[8] = {id=8, name="“谜”之双子", group={[1603001]=20,[1603002]=20,[1601024]=20,[1601002]=20}, attr={atk=15,finalAtk=15}, icon="3nxscdjd", },
[9] = {id=9, name="高富帅", group={[1603001]=20,[1603002]=20,[1601008]=20,[1601002]=20}, attr={atk=15,finalAtk=15}, icon="4sqjz", },
[10] = {id=10, name="轰天裂地", group={[1603001]=20,[1603002]=20,[1601022]=20,[1601003]=20}, attr={atk=15,finalAtk=15}, icon="5xrbd", },
[11] = {id=11, name="极限冲击", group={[1603001]=20,[1603002]=20,[1601021]=20,[1601003]=20}, attr={maxHp=20}, icon="6ldws", },
[12] = {id=12, name="投掷大师", group={[1603001]=20,[1603002]=20,[1601012]=20,[1601003]=20}, attr={atk=15,finalAtk=15}, icon="7htld", },
[13] = {id=13, name="帽子戏法", group={[1603001]=20,[1603002]=20,[1601004]=20,[1601012]=20}, attr={maxHp=20}, icon="8txhb", },
[14] = {id=14, name="一往情深", group={[1603001]=20,[1603002]=20,[1601016]=20,[1601005]=20}, attr={maxHp=20}, icon="9gkdd", },
[15] = {id=15, name="饿狼传说", group={[1603001]=30,[1603002]=30,[1603003]=30,[1601006]=30,[1601004]=30,[1601005]=30}, attr={maxHp=30}, icon="10jxcj", },
[16] = {id=16, name="双鱼之心", group={[1603001]=30,[1603002]=30,[1603003]=30,[1601015]=30,[1601004]=30,[1601023]=30}, attr={atk=24,finalAtk=24}, icon="11czds", },
[17] = {id=17, name="干预恋情", group={[1603001]=20,[1603002]=20,[1601027]=20,[1601006]=20}, attr={maxHp=20}, icon="18gylq", },
[18] = {id=18, name="回旋流光", group={[1603001]=20,[1603002]=20,[1601018]=20,[1601006]=20}, attr={atk=15,finalAtk=15}, icon="16hxlg", },
[19] = {id=19, name="惺惺相惜", group={[1603001]=20,[1603002]=20,[1601026]=20,[1601004]=20}, attr={maxHp=20}, icon="17xxxx", },
[20] = {id=20, name="手下败将", group={[1603001]=20,[1603002]=20,[1601027]=20,[1601004]=20}, attr={atk=15,finalAtk=15}, icon="19sxbj", },
[21] = {id=21, name="不解之缘", group={[1603001]=20,[1603002]=20,[1601018]=20,[1601007]=20}, attr={maxHp=20}, icon="24hyhg", },
[22] = {id=22, name="兄妹情深", group={[1603001]=20,[1603002]=20,[1601009]=20,[1601007]=20}, attr={atk=15,finalAtk=15}, icon="20bjzy", },
[23] = {id=23, name="怒之队", group={[1603001]=30,[1603002]=30,[1603003]=30,[1601011]=30,[1601012]=30,[1601010]=30}, attr={atk=24,finalAtk=24}, icon="21xmqs", },
[24] = {id=24, name="龙虎之拳", group={[1603001]=30,[1603002]=30,[1603003]=30,[1601009]=30,[1601008]=30,[1601007]=30}, attr={atk=24,finalAtk=24}, icon="22lhzq", },
[25] = {id=25, name="互有好感", group={[1603001]=20,[1603002]=20,[1601008]=20,[1601009]=20}, attr={maxHp=20}, icon="23hyhg", },
[26] = {id=26, name="凤凰飞燕", group={[1603001]=20,[1603002]=20,[1601019]=20,[1601009]=20}, attr={atk=15,finalAtk=15}, icon="15tfzs", },
[27] = {id=27, name="腿法宗师", group={[1603001]=20,[1603002]=20,[1601019]=20,[1601008]=20}, attr={maxHp=20}, icon="25qzbs", },
[28] = {id=28, name="力量之源", group={[1603001]=20,[1603002]=20,[1601011]=20,[1601031]=20}, attr={atk=15,finalAtk=15}, icon="26cnbl", },
[29] = {id=29, name="大蛇之血", group={[1603001]=20,[1603002]=20,[1601011]=20,[1601032]=20}, attr={maxHp=20}, icon="27ghbz", },
[30] = {id=30, name="强袭幻影", group={[1603001]=20,[1603002]=20,[1601027]=20,[1601010]=20}, attr={atk=15,finalAtk=15}, icon="28kbzx", },
[31] = {id=31, name="得意门生", group={[1603001]=20,[1603002]=20,[1601015]=20,[1601013]=20}, attr={maxHp=20}, icon="29dyms", },
[32] = {id=32, name="门派大弟子", group={[1603001]=20,[1603002]=20,[1601014]=20,[1601013]=20}, attr={atk=15,finalAtk=15}, icon="30mpddz", },
[33] = {id=33, name="守护骑士", group={[1603001]=20,[1603002]=20,[1601015]=20,[1601014]=20}, attr={maxHp=20}, icon="31shqs", },
[34] = {id=34, name="闪亮登场", group={[1603001]=20,[1603002]=20,[1601023]=20,[1601015]=20}, attr={atk=15,finalAtk=15}, icon="34xvxgdj", },
[35] = {id=35, name="荒狂稻光", group={[1603001]=20,[1603002]=20,[1601033]=20,[1601023]=20}, attr={maxHp=20}, icon="35hysj", },
[36] = {id=36, name="假想情敌", group={[1603001]=20,[1603002]=20,[1601026]=20,[1601016]=20}, attr={atk=15,finalAtk=15}, icon="36wzzz", },
[37] = {id=37, name="新女性格斗家", group={[1603001]=30,[1603002]=30,[1603003]=30,[1601017]=30,[1601018]=30,[1601016]=30}, attr={maxHp=30}, icon="37jhzq", },
[38] = {id=38, name="超能力战队", group={[1603001]=30,[1603002]=30,[1603003]=30,[1601013]=30,[1601015]=30,[1601014]=30}, attr={atk=24,finalAtk=24}, icon="38dqfb", },
[39] = {id=39, name="同病相怜", group={[1603001]=20,[1603002]=20,[1601020]=20,[1601021]=20}, attr={maxHp=20}, icon="39mdzw", },
[40] = {id=40, name="斗气风暴", group={[1603001]=20,[1603002]=20,[1601026]=20,[1601021]=20}, attr={atk=15,finalAtk=15}, icon="40tbxl", },
[41] = {id=41, name="疾风龙旋", group={[1603001]=20,[1603002]=20,[1601020]=20,[1601014]=20}, attr={maxHp=20}, icon="49hgd", },
[42] = {id=42, name="韩国队", group={[1603001]=30,[1603002]=30,[1603003]=30,[1601020]=30,[1601019]=30,[1601021]=30}, attr={atk=24,finalAtk=24}, icon="41jmdk", },
[43] = {id=43, name="鄙视至极", group={[1603001]=20,[1603002]=20,[1601022]=20,[1601025]=20}, attr={maxHp=20}, icon="42bszj", },
[44] = {id=44, name="干枯大地", group={[1603001]=20,[1603002]=20,[1601022]=20,[1601035]=20}, attr={atk=15,finalAtk=15}, icon="43yhmw", },
[45] = {id=45, name="暗杀之刃", group={[1603001]=20,[1603002]=20,[1601010]=20,[1601025]=20}, attr={maxHp=20}, icon="44ahyz", },
[46] = {id=46, name="暗黑意志", group={[1603001]=20,[1603002]=20,[1601024]=20,[1601013]=20}, attr={maxHp=20}, icon="45tbd", },
[47] = {id=47, name="特别队", group={[1603001]=30,[1603002]=30,[1603003]=30,[1601026]=30,[1601027]=30,[1601025]=30}, attr={maxHp=30}, icon="2zcdz", },
[48] = {id=48, name="地狱乐队", group={[1603001]=30,[1603002]=30,[1603003]=30,[1601024]=30,[1601023]=30,[1601022]=30}, attr={maxHp=30}, icon="48dszx", },
[49] = {id=49, name="浴火魔王", group={[1603001]=20,[1603002]=20,[1601028]=20,[1601034]=20}, attr={maxHp=20}, icon="47jcfy", },
[50] = {id=50, name="激战之夜", group={[1603001]=20,[1603002]=20,[1601007]=20,[1601031]=20}, attr={atk=15,finalAtk=15}, icon="50myzy", },
[51] = {id=51, name="神族王子", group={[1603001]=20,[1603002]=20,[1601028]=20,[1601031]=20}, attr={maxHp=20}, icon="51lzcj", },
[52] = {id=52, name="武术国粹", group={[1603001]=30,[1603002]=30,[1603003]=30,[1601003]=30,[1601019]=30,[1601006]=30}, attr={atk=24,finalAtk=24}, icon="52llzy", },
[53] = {id=53, name="黑暗之力", group={[1603001]=30,[1603002]=30,[1603003]=30,[1601011]=30,[1601013]=30,[1601031]=30}, attr={maxHp=30}, icon="53szwz", },
[54] = {id=54, name="解除封印", group={[1603001]=20,[1603002]=20,[1601032]=20,[1601025]=20}, attr={atk=15,finalAtk=15}, icon="54hazl", },
[55] = {id=55, name="命运之炎", group={[1603001]=20,[1603002]=20,[1601024]=20,[1601034]=20}, attr={maxHp=20}, icon="55zysz", },
[56] = {id=56, name="龙之惩戒", group={[1603001]=20,[1603002]=20,[1601005]=20,[1601035]=20}, attr={atk=15,finalAtk=15}, icon="14elcs", },
[57] = {id=57, name="力量之源", group={[1603001]=20,[1603002]=20,[1601012]=20,[1601035]=20}, attr={maxHp=20}, icon="1yzbn", },
[58] = {id=58, name="绝色尺咫", group={[1603001]=20,[1603002]=20,[1601017]=20,[1601033]=20}, attr={atk=15,finalAtk=15}, icon="46chsx", },
[59] = {id=59, name="成熟的诱惑", group={[1603001]=20,[1603002]=20,[1601019]=20,[1601033]=20}, attr={maxHp=20}, icon="3nxscdjd", },
[60] = {id=60, name="绝命抵抗", group={[1603001]=20,[1603002]=20,[1601020]=20,[1601032]=20}, attr={atk=15,finalAtk=15}, icon="4sqjz", },
[61] = {id=61, name="神秘任务", group={[1603001]=20,[1603002]=20,[1601017]=20,[1601029]=20}, attr={maxHp=20}, icon="5xrbd", },
[62] = {id=62, name="火龙炎弹", group={[1603001]=20,[1603002]=20,[1601005]=20,[1601034]=20}, attr={atk=15,finalAtk=15}, icon="6ldws", },
[63] = {id=63, name="关怀备至", group={[1603001]=20,[1603002]=20,[1601011]=20,[1601010]=20}, attr={maxHp=20}, icon="7htld", },
[64] = {id=64, name="幻影双击", group={[1603001]=20,[1603002]=20,[1601017]=20,[1601018]=20}, attr={atk=15,finalAtk=15}, icon="8txhb", },
[65] = {id=65, name="提携后辈", group={[1603001]=30,[1603002]=30,[1603003]=30,[1601028]=30,[1601029]=30,[1601002]=30}, attr={atk=24,finalAtk=24}, icon="9gkdd", },
[66] = {id=66, name="淬火苏醒", group={[1603001]=30,[1603002]=30,[1603003]=30,[1601034]=30,[1601035]=30,[1601033]=30}, attr={atk=24,finalAtk=24}, icon="10jxcj", },
[67] = {id=67, name="虎刹爆裂", group={[1603001]=30,[1603002]=30,[1603003]=30,[1601007]=30,[1601010]=30,[1601032]=30}, attr={maxHp=30}, icon="11czds", },
[68] = {id=68, name="暴力一击", group={[1603001]=30,[1603002]=30,[1603003]=30,[1601021]=30,[1601012]=30,[1601035]=30}, attr={maxHp=30}, icon="18gylq", },
[69] = {id=69, name="穷追不舍", group={[1603001]=30,[1603002]=30,[1603003]=30,[1601027]=30,[1601026]=30,[1601033]=30}, attr={maxHp=30}, icon="16hxlg", },
[70] = {id=70, name="燕式之影", group={[1603001]=30,[1603002]=30,[1603003]=30,[1601029]=30,[1601009]=30,[1601034]=30}, attr={maxHp=30}, icon="17xxxx", },
[71] = {id=71, name="蝶弹爆击", group={[1603001]=30,[1603002]=30,[1603003]=30,[1601016]=30,[1601005]=30,[1601031]=30}, attr={atk=24,finalAtk=24}, icon="19sxbj", },
[72] = {id=72, name="龙影永葬", group={[1603001]=30,[1603002]=30,[1603003]=30,[1601014]=30,[1601024]=30,[1601032]=30}, attr={atk=24,finalAtk=24}, icon="24hyhg", },
}
