-- file: lib.lua

-- TOP

local M

M = {
    ------------------------------------------------------------------------------
    -- Errors
    ------------------------------------------------------------------------------

    ---comment
    ---@package
    errors = {
        ---
        ---TODO!
        ---@param want string|unknown
        ---@param got string|unknown
        InvalidParamType = function(want, got) error('invalid value type passed. want ' .. want .. 'got ' .. got, 1) end,
    },

    ------------------------------------------------------------------------------
    -- Switch Case Statements
    ------------------------------------------------------------------------------

    ---Ported from https://devforum.roblox.com/t/switch-case-in-lua/1758606/3
    Switch = function(value)
        return function(cases) return (cases[value] or cases.default)(value) end
    end,

    ------------------------------------------------------------------------------
    -- Iterators
    ------------------------------------------------------------------------------

    ---comment
    iter = {
        ---`Iter` is a wrapper for Lua's `pairs` function.
        ---
        ---@generic T: table, K, V
        ---@param t T
        ---@return fun(table: table<K, V>, index?: K):K, V
        ---@return T
        Iter = function(t) return pairs(t) end,

        ---
        ---`Range` yields values from `start` to `stop` via a `coroutine`.
        ---Not so flexible as it uses `coroutine.wrap`
        ---
        ---See also: ~
        ---  • |RangePro|
        ---@param start integer
        ---@param stop integer
        ---@return fun(...):...
        Range = function(start, stop)
            --
            -- Creates a new coroutine, with body `f`; `f` must be a function.
            -- Returns a function that resumes the coroutine each time it is called.
            return coroutine.wrap(function()
                for i = start, stop do
                    coroutine.yield(i) -- Suspend the execution of the calling coroutine.
                end
            end)
        end,

        ---
        ---`RangePro` yields values from `start` to `stop` via a `coroutine` without using `coroutine.wrap`.
        ---
        ---See also: ~
        ---  • |Range|
        ---@param start any
        ---@param stop any
        ---@return function
        RangePro = function(start, stop)
            local co = coroutine.create(function() M.iter.YieldCoroutineGenerator(start, stop) end) ---@type thread

            return function() -- The iterator
                local code, res = coroutine.resume(co)

                if not code then error(string.format('error in RangePro:\tcoroutine on resuming `Generate()` returned *falsy* code: res: %s\n', res), 2) end

                return res
            end
        end,

        ---
        ---`YieldCoroutineGenerator` implements a generator function for yielding values from `start` to `stop`.
        ---@package
        ---@param a number start
        ---@param z number stop
        YieldCoroutineGenerator = function(a, z)
            if a - z == 0 then -- Useful for recursive `Generate` functions
                coroutine.yield(a)
            else
                for i = a, z do
                    coroutine.yield(i)
                end
            end
        end,
    },

    ------------------------------------------------------------------------------
    -- Map
    ------------------------------------------------------------------------------
}

return M

-- BOT
