local M = {}
M.__index = M

function M:new(r)
    r = r or {}
    local runner = setmetatable(r, M)
    runner.current_pid = nil
    runner.queue = {}

    return runner
end

function M:run_queued_commands(event_cb)
    local argsTable = {}
    local command = table.remove(self.queue, 1)

    for token in string.gmatch(command, "[^%s]+") do
        table.insert(argsTable, token)
    end

    local path = table.remove(argsTable, 1)

    local stdout = vim.uv.new_pipe(false)
    local stderr = vim.uv.new_pipe(false)

    local handle
    local function on_exit(_, exit_code, _)
        vim.schedule(function()
            event_cb("exit", exit_code)
            if #self.queue == 0 then
                event_cb("done")
            end
        end)
        stdout:close()
        stderr:close()
        handle:close()

        if #self.queue > 0 then
            self:run_queued_commands(event_cb)
        end
    end

    vim.schedule(function() event_cb("start", { command = command }) end)

    handle = vim.uv.spawn(path, {
        args = argsTable,
        stdio = {nil, stdout, stderr}
    }, on_exit)

    local function on_read(pipe, err, data)
        assert(not err, err)
        if data then
            vim.schedule(function()
                event_cb(pipe, data)
            end)
        end
    end

    stdout:read_start(function(err, data)
        on_read("stdout", err, data)
    end)

    stderr:read_start(function(err, data)
        on_read("stderr", err, data)
    end)
end


function M:run_commands(commands, event_cb)
    -- check type of commands so raw string is put in a table
    -- check if another command is running using pid
    -- check if another command is running using queue
    -- add the {filename} and such configs
    for i, v in ipairs(commands) do
        self.queue[i] = v
    end

    self:run_queued_commands(event_cb)
end

return M
