Object = require "libraries/classic/classic"

love.load = function()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setLineStyle("rough")
    local object_files = {}
    recursiveEnumerate("objects", object_files)
    requireFiles(object_files)

    local room_files = {}
    recursiveEnumerate("rooms", room_files)
    requireFiles(room_files)

    CurrentRoom = Stage()

    resize(3)
end

love.update = function(dt)
    require("libraries/lurker/lurker").update()
    if CurrentRoom then
        CurrentRoom:update(dt)
    end
end

love.draw = function()
    if CurrentRoom then
        CurrentRoom:draw()
    end
end

function recursiveEnumerate(folder, file_list)
    local items = love.filesystem.getDirectoryItems(folder)
    for _, item in ipairs(items) do
        local file = folder .. "/" .. item
        local info = love.filesystem.getInfo(file)
        if info.type == "file" then
            table.insert(file_list, file)
        elseif info.type == "directory" then
            recursiveEnumerate(file, file_list)
        end
    end
end

function requireFiles(files)
    for _, file in ipairs(files) do
        local file = file:sub(1, -5)
        require(file)
    end
end

function resize(s)
    love.window.setMode(s * gw, s * gh)
    sx, sy = s, s
end
