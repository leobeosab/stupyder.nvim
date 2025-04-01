local M = {}
M.__index = M

function M:new(r)
    r = r or {}
    local runner = setmetatable(r, M)
    runner.pid = nil
    runner.process = nil
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

    local function on_exit(_, exit_code, _)
        vim.schedule(function()
            event_cb("exit", exit_code)
            if #self.queue == 0 then
                event_cb("done")
            end
        end)
        stdout:close()
        stderr:close()
        self.process:close()

        if #self.queue > 0 then
            self:run_queued_commands(event_cb)
        end
    end

    vim.schedule(function() event_cb("start", { command = command }) end)

    self.process, self.pid = vim.uv.spawn(path, {
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
