local Context = require("stupyder.contexts.context")
local NvimContext = setmetatable({}, { __index = Context })
NvimContext.__index = Context
NvimContext.running = false
NvimContext.default_Config = vim.tbl_deep_extend("force", NvimContext.default_config, {})

function NvimContext:run(content, win, run_info)
    run_info.config = vim.tbl_deep_extend("force", self.default_config, run_info.config)
    local config = run_info.config

    local err, code, ogp, status, result

    if self:is_running() then
        err = "Already running"

        goto rt
    end

    if run_info.tool ~= "lua" then
        err = "Only Lua is supported for the nvim_context"
        goto rt
    end

    code, err = loadstring(content)
    if err or not code then
        err = "replace me with a callback"
        goto rt
    end

    self.running = true
    config.event_handlers.on_start(win, { run_info = run_info })

    ogp = print
    print = function(...)
        -- append to buffer here
        local args = { ... }
        for i, v in ipairs(args) do
            args[i] = vim.inspect(v)
        end

        config.event_handlers.on_data(win, { data = { lines = { table.concat(args) } } })
    end

    status, result = pcall(code)

    ::rt::
    print = ogp or print
    self.running = false

    if err then
        config.event_handlers.on_error(win, { error = { message = err, code = status } })
    end

    if result then
        config.event_handlers.on_error(win, { error = { message = result, code = status } })
    end

    config.event_handlers.on_end(win, { data = { result_status = status } })
end

function NvimContext:is_running()
    return self.running
end

function NvimContext:cancel(force)
    print("not implemented")
end

return NvimContext
