local M = {}
M.__index = M

function M:new(r)
    r = r or {}
    if not r.cwd then
        r.cwd = "./"
    end
    local runner = setmetatable(r, M)
    runner.pid = nil
    runner.process = nil
    runner.queue = {}

    return runner
end

function M:run_queued_commands(event_cb)
    local argsTable = {}

    local cmd = table.remove(self.queue, 1)
    local command = cmd[1]

    for token in string.gmatch(command, "[^%s]+") do
        table.insert(argsTable, token)
    end

    local path = table.remove(argsTable, 1)

    local stdout = vim.uv.new_pipe(false)
    local stderr = vim.uv.new_pipe(false)

    local function on_exit(_, exit_code, _)
        vim.schedule(function() event_cb("exit", exit_code) end)
        if #self.queue == 0 then
            -- return the last exit_code as the final status
            -- TODO could make this cumilitive and return a fail if any
            -- command failed
            vim.schedule(function() event_cb("done", exit_code) end)
        end
        stdout:close()
        stderr:close()
        self.process:close()

        if #self.queue > 0 then
            self:run_queued_commands(event_cb)
        else
            self.current_command = nil
        end
    end

    vim.schedule(function() event_cb("start", { command = command }) end)

    self.current_command = command

    self.process, self.pid = vim.uv.spawn(path, {
        cwd = self.cwd,
        args = argsTable,
        stdio = {nil, stdout, stderr}
    }, on_exit)

    local function on_read(pipe, err, data)
        assert(not err, err)
        if data then
            vim.schedule(function()
                event_cb(pipe, data, cmd)
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

function M:is_busy()
    if self.process and self.process:is_active() then
        return true
    end

    return false
end

function M:exit(force)
    force = force or false

    -- clear the queue
    self.queue = {}

    if self:is_busy() then
        if force then
            self.process:kill("sigterm")
            self.process = nil
            self.pid = nil
        else
            self.process:close(function ()
                self.process = nil
                self.pid = nil
            end)
        end
    end

    self.process = nil
    self.pid = nil
end

function M:run_commands(commands, event_cb)
    if self:is_busy() then
        print("There is currently a process running")
        return
    end

    for i, v in ipairs(commands) do
        self.queue[i] = v
    end

    self:run_queued_commands(event_cb)
end

return M
