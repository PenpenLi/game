module(...,package.seeall)
Config={
[2001] = {name=2001, lock=3, action="站立轻拳", target={}, loop=0, speedX=0, isJump=false, shader="", effect="", sound="shingo/Qingquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=130, hitEvent={[1]={reac="hit_light_a",effect="轻受击",deffect="防御1",deback=20,back=15,delayA=0.04,delayB=0.04}}, noHitEvent={}, },
[2002] = {name=2002, lock=3, action="站立轻脚", target={}, loop=0, speedX=0, isJump=false, shader="", effect="", sound="shingo/Qingquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=150, hitEvent={[4]={reac="hit_light_a",effect="轻受击",deffect="防御1",deback=20,back=15,delayA=0.04,delayB=0.04}}, noHitEvent={}, },
[2003] = {name=2003, lock=3, action="站立重拳", target={}, loop=0, speedX=0, isJump=false, shader="", effect="", sound="shingo/Zhongquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=235, hitEvent={[6]={reac="hit_heavy_b",effect="重受击",deffect="防御1",deback=30,back=20,delayA=0.04,delayB=0.04}}, noHitEvent={}, },
[2004] = {name=2004, lock=3, action="站立重脚", target={}, loop=0, speedX=0, isJump=false, shader="", effect="", sound="shingo/Zhongquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=220, hitEvent={[5]={reac="hit_heavy_b",effect="重受击",deffect="防御1",deback=30,back=20,delayA=0.04,delayB=0.04}}, noHitEvent={}, },
[2005] = {name=2005, lock=3, action="跳跃轻拳", target={}, loop=0, speedX=0, isJump=true, shader="", effect="", sound="shingo/Qingquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=190, hitEvent={[7]={reac="hit_light_a",effect="轻受击",deffect="防御1",deback=20,back=15,delayA=0.04,delayB=0.04,shock=1}}, noHitEvent={}, },
[2006] = {name=2006, lock=3, action="跳跃轻脚", target={}, loop=0, speedX=0, isJump=true, shader="", effect="", sound="shingo/Qingquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=180, hitEvent={[8]={reac="hit_light_a",effect="轻受击",deffect="防御1",deback=20,back=15,delayA=0.04,delayB=0.04,shock=1}}, noHitEvent={}, },
[2007] = {name=2007, lock=3, action="跳跃重拳", target={}, loop=0, speedX=0, isJump=true, shader="", effect="", sound="shingo/Zhongquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=200, hitEvent={[6]={reac="hit_heavy_a",effect="重受击",deffect="防御1",deback=30,back=20,delayA=0.04,delayB=0.04,shock=1}}, noHitEvent={}, },
[2008] = {name=2008, lock=3, action="跳跃重脚", target={}, loop=0, speedX=0, isJump=true, shader="", effect="", sound="shingo/Zhongquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=220, hitEvent={[9]={reac="hit_heavy_a",effect="重受击",deffect="防御1",deback=30,back=20,delayA=0.04,delayB=0.04,shock=1}}, noHitEvent={}, },
[2009] = {name=2009, lock=3, action="燃烧吧！真吾", target={}, loop=0, speedX=0, isJump=false, shader="Negative", effect="", sound="shingo/Ranshaozhenwu.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=200, hitEvent={[15]={reac="hit_heavy_b",effect="重受击",deffect="防御1",deback=30,back=10,delayA=0.26,delayB=0.22,shock=7,flash=1},[23]={reac="hit_heavy_a",effect="重受击",deffect="防御1",deback=30,back=10,shock=3},[29]={reac="hit_heavy_b",effect="重受击",deffect="防御1",deback=30,back=10,delayA=0.12,delayB=0.16,shock=3},[41]={reac="hit_fly_a",effect="重受击",deffect="防御1",deback=30,delayA=0.24,delayB=0.20,shock=8,flash=1,speed=-540}}, noHitEvent={["16-18,24,30-33"]={shock=3},[42]={shock=7,flash=1},[43]={shock=6},["44-48"]={shock=3}}, },
[2010] = {name=2010, lock=1, action="外式·驱凤麟bv_释放阶段", target={}, loop=0, speedX=0, isJump=false, shader="", effect="ShingoPower", sound="", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=999, hitEvent={}, noHitEvent={}, },
[2011] = {name=2011, lock=3, action="技能荒咬", target={}, loop=0, speedX=0, isJump=false, shader="", effect="", sound="shingo/Huangyao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=120, hitEvent={[4]={reac="hit_heavy_a",effect="重受击",deffect="防御2",deback=30,back=5,delayA=0.08,delayB=0.08,shock=3}}, noHitEvent={["5,6"]={shock=3}}, },
[2012] = {name=2012, lock=3, action="毒咬", target={}, loop=0, speedX=0, isJump=false, shader="", effect="", sound="shingo/Duyao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=220, hitEvent={[5]={reac="hit_heavy_b",effect="重受击",deffect="防御2",deback=30,back=60,delayA=0.08,delayB=0.08,shock=3},[8]={reac="hit_fly_a",effect="重受击",deffect="防御2",deback=30,back=60,delayA=0.10,delayB=0.08,shock=7,speed=-420}}, noHitEvent={[6]={shock=3},[9]={shock=7},["10,11"]={shock=3}}, },
[2013] = {name=2013, lock=3, action="鬼烧", target={}, loop=0, speedX=0, isJump=false, shader="", effect="", sound="shingo/Guishao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=170, hitEvent={[2]={reac="hit_heavy_b",effect="重受击",deffect="防御2",deback=30,back=20,delayA=0.08,delayB=0.06,shock=3,flash=1},[3]={reac="hit_fly_a",effect="重受击",deffect="防御2",deback=30,delayA=0.26,delayB=0.20,shock=7,flash=1}}, noHitEvent={[4]={shock=7},[5]={shock=6},["6-8"]={shock=3}}, },
[2014] = {name=2014, lock=3, action="胧车", target={}, loop=0, speedX=0, isJump=false, shader="", effect="", sound="shingo/Longche.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=280, hitEvent={[5]={reac="hit_heavy_a",effect="重受击",deffect="防御2",deback=30,back=160,delayA=0.14,delayB=0.10,shock=3},[15]={reac="hit_heavy_b",effect="重受击",deffect="防御2",deback=30,back=160,delayA=0.14,delayB=0.14,shock=3},[27]={reac="hit_fly_a",effect="重受击",deffect="防御2",deback=30,speed=-640,delayA=0.20,delayB=0.18,shock=7,flash=1}}, noHitEvent={["6,7,16-18"]={shock=3},[28]={shock=7},["28,29"]={shock=3}}, },
[2015] = {name=2015, lock=3, action="轰斧", target={}, loop=0, speedX=0, isJump=false, shader="", effect="", sound="shingo/Waishihongfu.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=190, hitEvent={[3]={reac="hit_heavy_a",effect="重受击",deffect="防御2",deback=30,back=30,delayA=0.08,delayB=0.06,shock=3},[6]={reac="hit_heavy_b",effect="重受击",deffect="防御2",deback=30,back=25,delayA=0.12,delayB=0.08,shock=7}}, noHitEvent={[7]={shock=3}}, },
[2016] = {name=2016, lock=3, action="真唔踢", target={}, loop=0, speedX=0, isJump=false, shader="", effect="", sound="shingo/Zhenwuti.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=350, hitEvent={[6]={reac="hit_fly_a",effect="重受击",deffect="防御2",deback=30,speed=-620,delayA=0.20,delayB=0.16,shock=8,flash=1}}, noHitEvent={[7]={shock=7},["8,9"]={shock=3}}, },
[2017] = {name=2017, lock=3, action="后摔", target={}, loop=0, speedX=0, isJump=false, shader="", effect="", sound="shingo/Houshuai.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=250, hitEvent={}, noHitEvent={}, },
[2018] = {name=2018, lock=3, action="前摔", target={}, loop=0, speedX=0, isJump=false, shader="", effect="", sound="shingo/Qianshuai.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=130, hitEvent={[1]={reac="be_caught",effect="抓起",delayA=0.02,delayB=0.02},[10]={reac="hit_fly_a",effect="重受击",delayA=0.20,delayB=0.16,speed=-540,shock=3}}, noHitEvent={[12]={shock=3}}, },
[2019] = {name=2019, lock=3, action="跳跃轻拳", target={}, loop=0, speedX=360, isJump=true, shader="", effect="", sound="shingo/Qingquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=260, hitEvent={[7]={reac="hit_light_a",effect="轻受击",deffect="防御1",deback=20,back=15,delayA=0.04,delayB=0.04,shock=1}}, noHitEvent={}, },
[2020] = {name=2020, lock=3, action="跳跃轻脚", target={}, loop=0, speedX=360, isJump=true, shader="", effect="", sound="shingo/Qingquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=250, hitEvent={[8]={reac="hit_light_a",effect="轻受击",deffect="防御1",deback=20,back=15,delayA=0.04,delayB=0.04,shock=1}}, noHitEvent={}, },
[2021] = {name=2021, lock=3, action="跳跃重拳", target={}, loop=0, speedX=360, isJump=true, shader="", effect="", sound="shingo/Zhongquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=270, hitEvent={[6]={reac="hit_heavy_a",effect="重受击",deffect="防御1",deback=30,back=20,delayA=0.04,delayB=0.04,shock=1}}, noHitEvent={}, },
[2022] = {name=2022, lock=3, action="跳跃重脚", target={}, loop=0, speedX=360, isJump=true, shader="", effect="", sound="shingo/Zhongquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=290, hitEvent={[9]={reac="hit_heavy_a",effect="重受击",deffect="防御1",deback=30,back=20,delayA=0.04,delayB=0.04,shock=1}}, noHitEvent={}, },
[2023] = {name=2023, lock=3, action="跳跃轻拳", target={}, loop=0, speedX=-360, isJump=true, shader="", effect="", sound="shingo/Qingquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=190, hitEvent={[7]={reac="hit_light_a",effect="轻受击",deffect="防御1",deback=20,back=15,delayA=0.04,delayB=0.04,shock=1}}, noHitEvent={}, },
[2024] = {name=2024, lock=3, action="跳跃轻脚", target={}, loop=0, speedX=-360, isJump=true, shader="", effect="", sound="shingo/Qingquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=180, hitEvent={[8]={reac="hit_light_a",effect="轻受击",deffect="防御1",deback=20,back=15,delayA=0.04,delayB=0.04,shock=1}}, noHitEvent={}, },
[2025] = {name=2025, lock=3, action="跳跃重拳", target={}, loop=0, speedX=-360, isJump=true, shader="", effect="", sound="shingo/Zhongquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=200, hitEvent={[6]={reac="hit_heavy_a",effect="重受击",deffect="防御1",deback=30,back=20,delayA=0.04,delayB=0.04,shock=1}}, noHitEvent={}, },
[2026] = {name=2026, lock=3, action="跳跃重脚", target={}, loop=0, speedX=-360, isJump=true, shader="", effect="", sound="shingo/Zhongquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=220, hitEvent={[9]={reac="hit_heavy_a",effect="重受击",deffect="防御1",deback=30,back=20,delayA=0.04,delayB=0.04,shock=1}}, noHitEvent={}, },
[2027] = {name=2027, lock=3, action="俺式.花研", target={}, loop=0, speedX=0, isJump=false, shader="", effect="", sound="shingo/Anshihuayan.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=170, hitEvent={[4]={reac="hit_heavy_a",effect="重受击",deffect="防御1",deback=30,back=15,delayA=0.04,delayB=0.04,shock=3},[6]={reac="hit_heavy_b",effect="重受击",deffect="防御1",deback=30,back=15,delayA=0.04,delayB=0.04,shock=3},[8]={reac="hit_fly_b",effect="重受击",deffect="防御1",deback=30,speed=-90,delayA=0.12,delayB=0.16,shock=7,flash=1}}, noHitEvent={["9-11"]={shock=3},[12]={shock=1}}, },
[2028] = {name=2028, lock=3, action="近身重拳", target={}, loop=0, speedX=0, isJump=false, shader="", effect="", sound="shingo/Zhongquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=180, hitEvent={[2]={reac="hit_heavy_a",effect="重受击",deffect="防御1",deback=30,back=20,delayA=0.04,delayB=0.04}}, noHitEvent={}, },
[2029] = {name=2029, lock=3, action="外式·驱凤麟bv_攻击阶段", target={}, loop=0, speedX=0, isJump=false, shader="Blur", effect="", sound="shingo/Waishiqufenglin.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=999, hitEvent={["5-19"]={reac="hit_fly_a",effect="重受击",deffect="防御1",deback=30,speed=-540,delayA=0.20,delayB=0.18,shock=8,flash=1}}, noHitEvent={[6]={shock=7},[7]={shock=6},[8]={shock=7},["9-12"]={shock=3},["13,14"]={shock=1}}, },
["rush"] = {name="rush", lock=1, action="跑", target={}, loop=1, speedX=900, isJump=false, shader="Blur", effect="", sound="", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=999, hitEvent={}, noHitEvent={}, },
["assist"] = {name="assist", lock=1, action="加自身攻击", target={}, loop=0, speedX=0, isJump=false, shader="", effect="", sound="", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=999, hitEvent={}, noHitEvent={}, },
}