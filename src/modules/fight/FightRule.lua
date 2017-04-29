module(..., package.seeall)

--状态锁规则：高状态不能被低状态替换
function lockRule(oldState, curState)
	if oldState then
	    if oldState.lock < curState.lock then
		    return true
        end
        if curState.lock == oldState.lock and oldState.canBreak then
            return true
        end
    else
        return true
    end
    return false
end

