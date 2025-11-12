local SAFE_FUEL = 20
local MAX_DIAMONDS = 5
local INVENTORY_THRESHOLD = 13
local diamondCount = 0
local steps = 0

local trashBlocks = {
    ["minecraft:cobblestone"]=true,
    ["minecraft:dirt"]=true,
    ["minecraft:sand"]=true,
    ["minecraft:gravel"]=true,
    ["minecraft:stone"]=true,
    ["minecraft:marble"]=true
}

function refuel()
    for i = 1,16 do
        turtle.select(i)
        local item = turtle.getItemDetail()
        if item and (item.name == "minecraft:coal" or item.name == "minecraft:coal_block") then
            while turtle.getFuelLevel() < SAFE_FUEL do
                if not turtle.refuel(1) then break end
            end
        end
    end
end

function fuelCheck()
    local f = turtle.getFuelLevel()
    if f == "unlimited" then return end
    if f == nil then f = 0 end
    if f < SAFE_FUEL then
        refuel()
    end
end

function dumpTrash()
    local fullSlots = 0
    for i = 1,16 do
        if turtle.getItemDetail(i) then
            fullSlots = fullSlots + 1
        end
    end
    if fullSlots >= INVENTORY_THRESHOLD then
        for i = 1,16 do
            turtle.select(i)
            local item = turtle.getItemDetail()
            if item and trashBlocks[item.name] then
                turtle.drop()
            end
        end
    end
end

function countDiamonds()
    local count = 0
    for i = 1,16 do
        local item = turtle.getItemDetail(i)
        if item and item.name == "minecraft:diamond" then
            count = count + item.count
        end
    end
    return count
end

function safeForward()
    fuelCheck()
    while turtle.detect() do
        turtle.dig()
    end
    turtle.forward()
    steps = steps + 1
end

function mine2x2(length)
    for l = 1, length do
        for i = 1,2 do
            turtle.digUp()
            turtle.digDown()
            safeForward()
            dumpTrash()
        end
        turtle.turnRight()
        turtle.digUp()
        turtle.digDown()
        turtle.forward()
        turtle.turnLeft()
    end
end

function goHome()
    turtle.turnLeft()
    turtle.turnLeft()
    for i = 1, steps do
        turtle.forward()
    end
    turtle.turnLeft()
    turtle.turnLeft()
end

refuel()
while true do
    diamondCount = countDiamonds()
    if diamondCount >= MAX_DIAMONDS then
        goHome()
        break
    end
    mine2x2(5)
end
