-- file: test.lua

-- TOP

local clock = os.clock

local tinylib = require 'lib'

local function TestModRequires()
    do -- Test mod tinylib
        print(clock(), 'module tinylib:', tinylib)

        for key, value in pairs(tinylib) do
            print(clock(), key, value)
        end
    end

    if nil then -- Test `Switch` vs native *switch-case* with tables
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

        do
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

    do -- Test `Iter` iterators
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

local function TestAll()
    do
        TestModRequires()
    end
end

do
    if true then TestAll() end
end

-- BOT
