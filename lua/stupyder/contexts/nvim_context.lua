local default_context = require("stupyder.config").contexts.default
local NvimContext = {}
NvimContext.__index = NvimContext
NvimContext.running = false

local default_config = vim.tbl_deep_extend("force", default_context, {})

function NvimContext:run(content, win, config)
    config = vim.tbl_deep_extend("force", default_config, config)
    local err, code, ogp, status, result

    if self:is_running() then
        err = "Already running"

        goto rt
    end

    if config.tool ~= "lua" then
        err = "Only Lua is supported for the nvim_context"
        goto rt
    end

    code, err = loadstring(content)
    if err or not code then
        err = "replace me with a callback"
        goto rt
    end

    self.running = true
    config.event_handlers.on_start(win, { config = config })

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
