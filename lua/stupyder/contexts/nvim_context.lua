local utils = require("stupyder.utils")
local Runner = require("stupyder.runner")

local NvimContext = {}
NvimContext.__index = NvimContext
NvimContext.runner = Runner:new()

function NvimContext:run(language, content, win, config)
    local err, code, ogp, status, result, buff

    if self:is_running() then
        err = "Currently running: " .. self.runner.current_command
        goto rt
    end

    if language ~= "lua" then
        err = "Only Lua is supported for the nvim_context"
        goto rt
    end

    code, err = loadstring(content)
    if err or not code then
        err = "replace me with a callback"
        goto rt
    end

    win:open()
    win:clear_buff()

    win:append_to_buffer( { string.format("------ Starting Lua Execution ------")})

    ogp = print
    _G.print = function(...)
        -- append to buffer here
        local args = { ... }
        for i, v in ipairs(args) do
            args[i] = vim.inspect(v)
        end

        win:append_to_buffer({table.concat(args)})
    end

    status, result = pcall(code)

    ::rt::
    _G.print = ogp
    -- TODO callback with error for error
    if err then
        if result then
            win:append_to_buffer( { string.format("Result: %s", result)})
        end
        win:append_to_buffer( { string.format("------ Failed with status: %s ------", tostring(status))})
    end

    win:append_to_buffer( { string.format("------ Completed with status: %s ------", tostring(status))})
end

function NvimContext:is_running()
    return self.runner:is_busy()
end

function NvimContext:cancel(force)
    return self.runner:exit(force)
end

return NvimContext
