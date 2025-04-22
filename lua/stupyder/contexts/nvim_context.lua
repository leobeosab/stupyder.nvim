local Context = require("stupyder.contexts.context")
local NvimContext = setmetatable({}, { __index = Context })
NvimContext.__index = Context
NvimContext.running = false
NvimContext.default_Config = vim.tbl_deep_extend("force", NvimContext.default_config, {})

function NvimContext:run(mode, run_info)
    run_info.config = vim.tbl_deep_extend("force", self.default_config, run_info.config)
    local config = run_info.config

    local err, code, ogp, status, result

    if self:is_running() then
        err = "Already running"

        goto rt
    end

    if run_info.block.language ~= "lua" then
        err = "Only Lua is supported for the nvim_context"
        goto rt
    end

    code, err = loadstring(run_info.block.code)
    if err or not code then
        err = "replace me with a callback"
        goto rt
    end

    self.running = true
    config.event_handlers.on_start(mode, { run_info = run_info })

    ogp = print
    print = function(...)
        -- append to buffer here
        local args = { ... }
        for i, v in ipairs(args) do
            args[i] = vim.inspect(v)
        end

        config.event_handlers.on_data(mode, {table.concat(args)}, { run_info = run_info })
    end

    status, result = pcall(code)

    ::rt::
    print = ogp or print
    self.running = false

    if err then
        print("FAIL")
        config.event_handlers.on_error(mode, {err}, { message = err, code = status, run_info = run_info })
    end

    if result then
        config.event_handlers.on_error(mode, {result}, { run_info = run_info, error = { code = status } })
    end

    config.event_handlers.on_end(mode, { data = { result_status = status }, run_info = run_info })
end

function NvimContext:is_running()
    return self.running
end

function NvimContext:cancel(force)
    print("not implemented")
end

return NvimContext
