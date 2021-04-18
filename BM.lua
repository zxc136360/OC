-- API
component = require("component")
transpose = component.transposer
term = require("term")
rs = component.redstone
gpu = component.gpu
sides = require("sides")
colors = require("colors")

-- Debug模式
isdebug = false
-- 血魔法祭坛等级
BloodAltarTier = 5
-- 各等级石板需求量
t1slate = 64
t2slate = 64
t3slate = 64
t4slate = 64
t5slate = 64

-- 祭坛方向
altarSide = sides.back
if not altarSide then
    if isdebug then
        term.write("没有找到祭坛！\n")
    end
    os.exit()
end
-- IO方向
IOSide = sides.right
if not altarSide then
    if isdebug then
        term.write("没有输入输出箱子！\n")
    end
    os.exit()
end

-- 红石控制
rsInputSide = sides.top

-- -- 石头的格子数
-- stoneSlot = 10

-- 祭坛插槽
altarSlot = 1  
altarTank = 1

-- -- 各阶石头输出的格子
-- t1slateSlot = 1
-- t2slateSlot = 2
-- t3slateSlot = 3
-- t4slateSlot = 4
-- t5slateSlot = 5

-- 祭坛信息
altarInfo = {}

stackInfo = {}


itemInfo = {
    -- 空白的石板
    {
        name = "AWWayofTime:blankSlate",
        meter = "dreamcraft:item.ArcaneSlate",
        blood = 2000,
        tier = 1
    },
    -- 加强的石板
    {
        name = "AWWayofTime:reinforcedSlate",
        meter = "AWWayofTime:blankSlate",
        blood = 4000,
        tier = 2
    },
    -- 灌输石板
    {
        name = "AWWayofTime:imbuedSlate",
        meter = "AWWayofTime:reinforcedSlate",
        blood = 10000,
        tier = 3
    },
    -- 恶魔石板
    {
        name = "AWWayofTime:demonicSlate",
        meter = "AWWayofTime:imbuedSlate",
        blood = 20000,
        tier = 4
    },
    -- 悬幽石板
    {
        name = "AWWayofTime:bloodMagicBaseItems",
        meter = "AWWayofTime:demonicSlate",
        blood = 50000,
        tier = 5
    }   
}

---获取物品在IO中的位置
---没找到返回-1
---@param name string
---@return integer
function getItemSlotByName(name)
    local items = transpose.getAllStacks(IOSide).getAll()
    for i = 1, #(items) do
        if items[i] and items[i].name == name then
            return i
        end
    end
    return -1
end

---获取物品在IO中的位置
---如果满了返回-1
---@param name string
---@return integer
function getItemSlotOrNullSoltByName(name)
    local i = getItemSlotByName(name)
    if not i == -1 then
        if not transpose.getSlotStackSize(IOSide, i) == transpose.getSlotMaxStackSize(IOSide, i) then
            return i
        end
    end
    local items = transpose.getAllStacks(IOSide).getAll()
    for i = 1, #(items) do
        if not items[i] then
            return i
        end
    end
    return -1
end

---获取祭坛信息
function getReserveTankInfo()
    local tInfo = transpose.getFluidInTank(altarSide)
    if tInfo.n > 0 then
        altarInfo.amount = tInfo[1].amount
        altarInfo.max = tInfo[1].capacity
        altarInfo.percent = (altarInfo.amount / altarInfo.max) * 100

        if term.isAvailable() then
            term.clearLine()
            term.write(string.format("Reserve Blood Level: %.2f %%, %.0d mb / %.0d mb\n", altarInfo.percent, altarInfo.amount, altarInfo.max))
        end
    else
        if term.isAvailable() then
            term.write("没有找到祭坛\n")
        end 
    end
end

---合成指定石板
---@param slateInfo table
function createSlate(slateInfo)
    getReserveTankInfo()
    if altarInfo.amount < slateInfo.blood then
        term.write("无法合成，祭坛剩余血量不够")
        return
    end
    local creating = true
    transpose.transferItem(IOSide, altarSide, 1, getItemSlotByName(slateInfo.meter), 1)
    term.write("合成%s中\n", slateInfo.name)
    while creating do
        if transpose.getStackInSlot(altarSide, 1) == slateInfo.name then
            creating = false
            transpose.transferItem(altarInfo, IOSide, 1, 1, getItemSlotOrNullSoltByName(slateInfo.name))
        end
        os.sleep(0.5)
    end
end

createSlate(itemInfo[1])