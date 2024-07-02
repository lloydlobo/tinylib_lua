-- file: tinylib.lua

-- TOP

---
---
---
local M
M = {
    ---
    ---Empty function aka noop
    ---@package
    NoOp = function() end,

    emptyblock = [[if nil then end]],

    ------------------------------------------------------------------------------
    -- Errors
    ------------------------------------------------------------------------------

    ---Function handlers for common errors.
    ---@package
    errors = {
        ---@param context string?
        ---@param want string?
        ---@param got string?
        ---@param code integer?
        InvalidParamType = function(context, want, got, code)
            error(
                'invalid value type passed.' .. ' context: ~ ' .. context and context
                    or 'N.A.' .. ' want: ~ ' .. want and want
                    or 'N.A.' .. ' got: ~ ' .. got and got
                    or 'N.A.',
                code and code or 1
            )
        end,

        ---@param context string?
        ---@param code integer?
        StatusFailed = function(context, code) error('status failed.' .. ' context: ~ ' .. context and context or 'N.A.', code and code or 1) end,

        ---@param context string?
        ---@param code integer?
        Unimplemented = function(context, code) error('unimplemented.' .. ' context: ~ ' .. context and context or 'N.A.', code and code or 1) end,
    },

    ------------------------------------------------------------------------------
    -- Conditional Statements and Branching
    ------------------------------------------------------------------------------

    ---`Match`.
    ---@param ... unknown
    ---@return function
    ---@nodiscard
    Match = function(...)
        local args = { ... } ---@type unknown[]
        --[[
            If `index` is a number, returns all arguments after argument number
            `index`; a negative number indexes from the end (`-1` is the last
            argument). Otherwise, `index` must be the string `"#"`, and `select`
            returns the total number of extra arguments it received.
        ]]
        local argsCount = select('#', ...)
        --
        -- TODO: Use `for i = 1, #cases do ... ... elseif #case == argsCount+1 then ... end ... ... end`
        --
        print(argsCount)

        return function(cases)
            local defaultCaseExpr = nil ---@type function|unknown|nil
            local matchedCaseExpr = nil ---@type function|unknown|nil
            local foundNoMatches = nil ---@type boolean|nil

            for _, case in ipairs(cases) do
                assert(type(case) == 'table')

                if case[1] == 'default' then
                    defaultCaseExpr = case[2]
                elseif #case == #args + 1 then -- TODO: Use `argsCount` instead of `#args`
                    local match = true

                    for i = 1, #args do
                        if args[i] ~= case[i] then
                            match = false
                            break
                        end
                    end

                    if not match then
                        foundNoMatches = true -- NOTE(Lloyd): Error checking done at scope end if no default case found

                        if defaultCaseExpr ~= nil and matchedCaseExpr ~= nil then break end -- PERF: Break early
                    else
                        -- NOTE(Lloyd): Sanity check for multiple matching cases
                        assert(
                            matchedCaseExpr == nil,
                            'unimplemented: multiple matching cases are not handled yet: ~\n'
                                .. string.format('\tin #case: %s: ~\n\t{ args..., fu }: { %s, %s }', #case, table.concat(case, ', ', 1, #case - 1), case[#case])
                        )

                        foundNoMatches = false

                        matchedCaseExpr = case[#case]

                        if defaultCaseExpr ~= nil then break end -- PERF: Break early
                    end
                end
            end

            assert((defaultCaseExpr ~= nil), 'compile error: ' .. '`Match` requires a `{"default", ...}` case') -- Similar to *compile-time error*

            if matchedCaseExpr ~= nil then return type(matchedCaseExpr) == 'function' and matchedCaseExpr() or matchedCaseExpr end

            assert(foundNoMatches, 'unreachable: `Match` internal error') -- Similar to *runtime error*

            if defaultCaseExpr ~= nil then return type(defaultCaseExpr) == 'function' and defaultCaseExpr() or defaultCaseExpr end

            assert(nil, 'unreachable: `Match` internal error') -- Similar to *runtime error*
        end -- end return function(...)
    end,

    ---`Switch` statement wrapper.
    ---
    ---Ported from https://devforum.roblox.com/t/switch-case-in-lua/1758606/3
    ---@param value any
    ---@return function
    ---@nodiscard
    Switch = function(value)
        return function(cases) ---@param cases any
            return (cases[value] or cases.default)(value)
        end ---@return unknown
    end,

    ------------------------------------------------------------------------------
    -- Iterators
    ------------------------------------------------------------------------------

    ---iter
    iter = {
        ---`Iter` is a wrapper for Lua's `pairs` function.
        ---
        ---@generic T: table, K, V
        ---@param t T
        ---@return fun(table: table<K, V>, index?: K):K, V
        ---@return T
        ---@nodiscard
        Iter = function(t) return pairs(t) end,

        ---
        ---`Range` yields values from `start` to `stop` via a `coroutine`.
        ---Not so flexible as it uses `coroutine.wrap`
        ---
        ---
        ---See also: ~
        ---  • |RangePro|
        ---@param start integer
        ---@param stop integer
        ---@return fun(...):...
        ---@nodiscard
        Range = function(start, stop)
            return coroutine.wrap(function()
                for i = start, stop do
                    coroutine.yield(i) -- Suspend the execution of the calling coroutine.
                end
            end) -- `wrap` returns a function that resumes the coroutine each time it is called.
        end,

        ---
        ---`RangePro` yields values from `start` to `stop` via a `coroutine`
        ---without using `coroutine.wrap`.
        ---
        ---See also: ~
        ---  • |Range|
        ---@param start any
        ---@param stop any
        ---@return function
        ---@nodiscard
        RangePro = function(start, stop)
            local co = coroutine.create(function() M.iter.YieldCoroutineGenerator(start, stop) end) ---@type thread

            return function() -- The iterator
                local code, res = coroutine.resume(co)

                if not code then M.errors.StatusFailed('error in RangePro coroutine `Generate()` returned *falsy* on resume: ~ ' .. res .. '\n', 1) end

                return res
            end
        end,

        ---
        ---`YieldCoroutineGenerator` implements a generator function for yielding
        ---values from `start` to `stop`.
        ---@package
        ---@param start integer
        ---@param stop integer
        YieldCoroutineGenerator = function(start, stop)
            if start - stop == 0 then -- Useful for recursive `Generate` functions
                coroutine.yield(start)
            else
                for i = start, stop do
                    coroutine.yield(i)
                end
            end
        end,
    },

    ------------------------------------------------------------------------------
    -- Map
    ------------------------------------------------------------------------------
}

---@param ... unknown
---@return function
function Match(...)
    local args = { ... }

    return function(cases)
        local defaultFn
        local matchedFn

        for _, case in ipairs(cases) do
            if case[1] == 'default' then
                defaultFn = case[2]
            elseif not matchedFn and #case == #args + 1 then
                local match = true
                for i = 1, #args do
                    if args[i] ~= case[i] then
                        match = false
                        break
                    end
                end
                if match then matchedFn = case[#case] end
            end
        end

        assert(defaultFn, 'No default case provided')

        return (matchedFn or defaultFn)()
    end
end

return M

-- BOT

-- if nil then -- DEBUG
--     for key, value in pairs(cases) do
--         print('Match:', 'cases:', 'pairs:', key, value)
--         for i, val in ipairs(value) do
--             if val == 'default' then print '==========default===========' end
--             print('Match:', 'case:', 'ipairs:', i, val)
--             if val == 'default' then print '==========default===========' end
--         end
--     end
-- end
