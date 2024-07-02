-- file: test.lua

-- TOP

local tinylib = require 'tinylib'

local clock = os.clock

---
---Map each item in table `arr` to string and concatenate all items into a string
---with `sep` separator.
---@package
---@param arr table
---@param sep string?
---@return string
---@nodiscard
local MapStr = function(arr, sep)
    sep = sep or ', '

    local t = {}
    for _, value in pairs(arr) do
        table.insert(t, tostring(value))
    end

    return table.concat(t, sep)
end

---
---@package
local function TestModRequires()
    if true then -- Test mod tinylib
        print(clock(), 'module tinylib:', tinylib)

        for key, value in pairs(tinylib) do
            print(clock(), key, value)
        end
    end

    if true then
        local Match = tinylib.Match
        do -- Test `Match` with multiple args
            local a, b, c = 1, 2, 3

            local args = { a, b, c }

            if true then print(clock(), a, b, c) end

            Match(a, b, c) {
                { 1, 2, 3, function() print(clock(), 'matched ' .. MapStr(args)) end },
                { 1, 2, 3, function() print(clock(), 'matched ' .. MapStr(args)) end },
                { 4, 5, 6, function() print(clock(), 'matched ' .. MapStr(args)) end },
                { 7, 8, 9, function() print(clock(), 'matched ' .. MapStr(args)) end },
                { 10, 11, 12, function() print(clock(), 'matched ' .. MapStr(args)) end },
                { 111, 222, 333, function() print(clock(), 'matched ' .. MapStr(args)) end },
                { 'default', function() print(clock(), 'matched default ' .. MapStr { a, b, c }) end },
            }

            a, b, c = 11, 0, 11
            Match(a, b, c) {
                { 1, 2, 3, function() print(clock(), 'matched ' .. MapStr(args)) end },
                { 4, 5, 6, function() print(clock(), 'matched ' .. MapStr(args)) end },
                { 7, 8, 9, function() print(clock(), 'matched ' .. MapStr(args)) end },
                { 10, 11, 12, function() print(clock(), 'matched ' .. MapStr(args)) end },
                { 111, 222, 333, function() print(clock(), 'matched ' .. MapStr(args)) end },
                { 'default', function() print(clock(), 'matched default ' .. MapStr { a, b, c }) end },
            }
        end
    end

    if true then -- Test `Switch` vs native *switch-case* with tables
        do
            local switch = tinylib.Switch
            print(clock(), 'module tinylib: Switch:', switch)

            local value = 8

            switch(value) {
                [1] = function(val) print(clock(), 'The value is ' .. val) end,
                [2] = function(val) print(clock(), 'The value is ' .. val) end,
                [3] = function(val) print(clock(), 'The value is ' .. val) end,
                [4] = function(val) print(clock(), 'The value is ' .. val) end,
                [5] = function(val) print(clock(), 'The value is ' .. val) end,
                [10] = function(val) print(clock(), 'The value is ' .. val) end,
                default = function(val) print(clock(), 'unknown value (' .. val .. ')') end,
            }
        end

        if nil then
            local value = 9

            local switch = {
                [1] = function() print(clock(), 'The value is 1') end,
                [2] = function() print(clock(), 'The value is 2') end,
                [3] = function() print(clock(), 'The value is 3') end,
                [4] = function() print(clock(), 'The value is 4') end,
                [5] = function() print(clock(), 'The value is 5') end,
                [10] = function() print(clock(), 'The value is 10') end,
                ['default'] = function() print(clock(), 'unknown value') end,
            }

            if switch[value] then
                switch[value]()
            else
                switch['default']()
            end
        end
    end

    if true then -- Test `Iter` iterators
        local iter = tinylib.iter
        print(clock(), 'module tinylib:', 'iter:', tinylib.iter)

        do --Iter
            local Iter = iter.Iter
            print(clock(), 'module tinylib:', 'iter:', 'Iter:', Iter)

            for i in Iter {} do -- Iterate on empty table list
                print(i) --> prints nothing
            end

            for i, v in Iter { -1, 0, 1, 2 } do -- Iterate over table of integers
                print(i, v) --> 1\n 2\n 3\n
            end
        end

        do -- Range
            local Range = iter.Range
            print(clock(), 'module tinylib:', 'iter:', 'Range:', Range)

            for i in Range(-1, 2) do
                print(i) --> 1\n 2\n 3\n
            end
        end

        do -- RangePro
            local RangePro = iter.RangePro
            print(clock(), 'module tinylib:', 'iter:', 'RangePro:', RangePro)

            for i in RangePro(-1, 3) do
                print(i) --> 1\n 2\n 3\n
            end
        end
    end
end

---
---@package
local function TestAll()
    do
        TestModRequires()
    end
end

-- Run All Tests
do
    if true then TestAll() end
end

-- BOT
